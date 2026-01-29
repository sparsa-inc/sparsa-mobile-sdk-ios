//
//  Helpers.swift
//  Sample App
//
//  Created by Sevak on 17.12.25.
//

import Foundation
import Sparsa
import UIKit
import SwiftUI
import Combine

extension ContainerViewModel {
    
    func execute(_ block: @escaping (ContainerViewModel) async throws -> String) {
        Task { @MainActor [weak self] in
            guard let self = self else { return }

            do {
                self.uiState.requesting = true
                let result = try await block(self)
                if !result.isEmpty {
                    self.showAlert(with: result)
                }
                self.uiState.requesting = false
            } catch {
                let message = error.localizedDescription
                if !message.lowercased().contains("cancel") {
                    self.showAlert(with: message)
                }
                self.uiState.requesting = false
            }
        }
    }

    func selectDevice() async throws -> Device? {
        let devices = try await Sparsa.shared.getDevices()
        let currentDeviceId = state.deviceIdentifier
        self.showBottomSheet(items: devices.map { device in
            let thisDeviceLabel = device.identifier == currentDeviceId ? " (this device)" : ""
            return "\(device.name)\(thisDeviceLabel)\n\(device.createdDate)"
        }, selectable: true)
        guard let substrings = await self.waitForUserSelection()?.split(separator: "\n"),
              substrings.count > 1 else { return nil }
        let date = substrings[1]
        return devices.first(where: { $0.createdDate == String(date) })
    }
    
    func selectLanguage() async throws -> String {
        let languages = ["Japan", "English"]
        self.showBottomSheet(items: languages, selectable: true)
        let selectedLanguage = await self.waitForUserSelection()
        let lang = selectedLanguage == "Japan" ? "ja" : "en"
        return lang
    }
    
    func selectCredential() async throws -> Credential? {
        var credentials = try await Sparsa.shared.getCredentials()
        guard let (statuses, types) = try await self.presentCredentialsFilter(with: credentials) else {
            return nil
        }
        credentials = try await Sparsa.shared.getCredentials(with: statuses, and: types)
        if credentials.isEmpty {
            return nil
        }
        self.showBottomSheet(items: credentials.compactMap { credential in
            let issuer = credential.issuer ?? ""
            let dateOnly = formatDateOnly(credential.issueDate ?? "")
            return "\(credential.schema)\nIssuer: \(issuer)\nType: \(credential.schema)\nDate: \(dateOnly)"
        }, selectable: true)
        guard let identifier = await self.waitForUserSelection()?.prefix(while: { !$0.isNewline }) else { return nil }
        return credentials.first(where: { $0.schema == identifier })
    }

    private func formatDateOnly(_ dateString: String) -> String {
        let parts = dateString.split(whereSeparator: { $0 == " " || $0 == "T" })
        return parts.first.map(String.init) ?? dateString
    }
    
    @MainActor
    func getQR() async throws -> String {
        return try await withUnsafeThrowingContinuation { continuation in
            guard let root = UIApplication.shared.keyWindowPresentedController else {
                continuation.resume(throwing: NSError(domain: "Cannot open QR scanner", code: 0))
                return
            }
            let vc = QRScannerViewController()
            
            vc.onClose = { [weak self] in
                self?.runOnMainThread { weakSelf in
                    weakSelf.uiState.requesting = false
                }
            }
            vc.result = { result in
                vc.dismiss(animated: true) {
                    switch result {
                    case let .success(result):
                        continuation.resume(returning: result)
                    case let .failure(error):
                        continuation.resume(throwing: error)
                    }
                }
            }
            vc.modalPresentationStyle = .fullScreen
            vc.modalTransitionStyle = .coverVertical
            root.present(vc, animated: true)
        }
    }
    
    func detectQR() {
        execute { weakSelf in
            let result = try await weakSelf.getQR()
            weakSelf.runOnMainThread { wSelf in
                wSelf.state.qrData = result
            }
            return weakSelf.toJson(obj: result)
        }
    }
    
    func showAlert(with message: String) {
        guard !message.isEmpty else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
            self?.uiState.alertMessage = message
            self?.uiState.showAlert = true
        }
    }
    
    var buttonGroups: [ButtonsGroup] {
        return [
            .init(
                name: "Authentication",
                buttons: [
                    .init(.authUser, action: recoverDigitalAddress),
                    .init(.regUser, action: importDigitalAddress),
                    .init(.deviceBootstrappingVerification, disabled: false, action: deviceBootstrappingVerification),
                    .init(.updateDigitalAddress, action: updateDigitalAddress),
                    .init(.getDigitalAddress, action: getDigitalAddress)
                ]
            ),
            .init(name: "Credentials", buttons: [
                .init(.proofProcess, action: proofProcess),
                .init(.getCredentials, action: getCredentials),
                .init(.getCredentialDetails, action: getCredentialDetails),
            ]),
            .init(name: "Devices", buttons: [
                .init(.getDevices, action: getDevices),
                .init(.deleteDevice, action: deleteDevice),
            ]),
            .init(name: "Email", buttons: [
                .init(.sendRecoveryEmail, disabled: false, action: sendRecoveryEmail),
                .init(.setRecoveryEmail, disabled: false, action: setRecoveryEmail)
            ]
            ),
            .init(name: "Languages",
                  buttons: [
                    .init(.setLanguage, action: setLanguage),
                    .init(.getLanguage, action: getLanguage)
                  ])
        ]
    }
    
    func updateButtonStates() {
        setState()
        for group in uiState.groups {
            for button in group.buttons {
                button.disabled = switch button.item {
                case .authUser, .regUser:
                    state.qrData.isEmpty || !state.digitalAddress.isEmpty
                case .deviceBootstrappingVerification: !state.digitalAddress.isEmpty
                case .updateDigitalAddress, .getDigitalAddress: state.digitalAddress.isEmpty
                case .sendRecoveryEmail:
                    false
                case .getCredentials, .getCredentialDetails,
                        .getDevices, .getLanguage,
                        .setLanguage, .deleteDevice,
                        .proofProcess, .setRecoveryEmail:
                    state.digitalAddress.isEmpty
                }
            }
        }
    }
}

extension ContainerViewModel {
    
    func runOnMainThread(_ block: @escaping (ContainerViewModel) -> Void) {
        if Thread.isMainThread {
            block(self)
        } else {
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                block(self)
            }
        }
    }
}

extension ContainerViewModel {
    
    func showBottomSheet(items: [String], selectable: Bool = false) {
        DispatchQueue.main.async { [weak self] in
            self?.uiState.selectedItem = nil
            self?.uiState.chooserList = items
            self?.uiState.showBottomSheet = true
            self?.uiState.selectableItems = selectable
        }
    }
    
    func hideBottomSheet() {
        DispatchQueue.main.async { [weak self] in
            self?.uiState.chooserList = []
            self?.uiState.selectedItem = nil
            self?.uiState.showBottomSheet = false
            self?.uiState.showFilterSheet = false
            self?.uiState.qrImage = nil
        }
    }
    
    func toJson(obj: Codable) -> String {
        let jsonData = try? encoder.encode(obj)
        
        if let jsonData,
           let jsonString = String(data: jsonData, encoding: .utf8) {
            return jsonString
        }
        return ""
    }
    
    func getState() {
        if let data = userDefaults.data(forKey: "state") {
            self.state = (try? JSONDecoder().decode(ValuesState.self, from: data)) ?? ValuesState()
        }
    }
    
    func setState() {
        let data = try? encoder.encode(state)
        userDefaults.setValue(data, forKey: "state")
    }
    
    func clearState() {
        let clientId = self.state.clientId
        let secret = self.state.secret
        runOnMainThread { weakSelf in
            weakSelf.state = ValuesState()
            weakSelf.state.clientId = clientId
            weakSelf.state.secret = secret
        }
        
        self.setState()
    }
}


extension ContainerViewModel {
    
    func presentCredentialsFilter(
        with credentials: [Credential]
    ) async throws -> (Set<String>, Set<String>)? {
        runOnMainThread { vm in
            vm.fetchedCredentialsForFilter = credentials
            vm.uiState.showFilterSheet = true
        }
        let result = try await waitForFilterSelection()
        runOnMainThread { vm in
            vm.hideBottomSheet()
        }

        try await Task.sleep(nanoseconds: 300_000_000)
        return result
    }
    
    func generateQRCode(from data: Bootstrapping) -> UIImage? {
        let jsonData = try? JSONEncoder().encode(data)
        guard let jsonData,
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            return nil
        }
        let data = jsonString.data(using: String.Encoding.ascii)

        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            filter.setValue("M", forKey: "inputCorrectionLevel")

            if let outputImage = filter.outputImage {
                let transform = CGAffineTransform(scaleX: 10, y: 10)
                let scaledCIImage = outputImage.transformed(by: transform)

                let context = CIContext()
                if let cgImage = context.createCGImage(scaledCIImage, from: scaledCIImage.extent) {
                    return UIImage(cgImage: cgImage)
                }
            }
        }
        return nil
    }
    
    func waitForUserSelection() async -> String? {
        await withCheckedContinuation { continuation in
            var cancellable: AnyCancellable?
            var didResume = false
            var sheetWasShown = false
            cancellable = self.$uiState
                .receive(on: DispatchQueue.main)
                .sink { [weak self] state in
                    guard self != nil else { return }
                    guard !didResume else { return }
                    if let selectedItem = state.selectedItem, !selectedItem.isEmpty {
                        didResume = true
                        continuation.resume(returning: selectedItem)
                        cancellable?.cancel()
                    } else if state.showBottomSheet {
                        sheetWasShown = true
                    } else if !state.showBottomSheet && sheetWasShown {
                        didResume = true
                        continuation.resume(returning: nil)
                        cancellable?.cancel()
                    }
                }
            cancellable?.store(in: &cancellables)
        }
    }
    
    func waitForUserInput() async throws -> String? {
        try await withCheckedThrowingContinuation { continuation in
            var cancellable: AnyCancellable?
            var didResume = false
            var inputWasShown = false
            cancellable = self.$uiState
                .receive(on: DispatchQueue.main)
                .sink { [weak self] state in
                    guard let self else { return }
                    guard !didResume else { return }
                    if state.showInput {
                        inputWasShown = true
                    } else if !state.showInput && inputWasShown {
                        didResume = true
                        cancellable?.cancel()
                        if !self.state.input.isEmpty {
                            continuation.resume(returning: self.state.input)
                        } else {
                            continuation.resume(throwing: NSError(domain: "Action cancelled by user action", code: 0))
                        }
                    }
                }
            cancellable?.store(in: &cancellables)
        }
    }
    
    func waitForFilterSelection() async throws -> (Set<String>, Set<String>)? {
        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<(Set<String>, Set<String>)?, Error>) in
            guard !Task.isCancelled else {
                continuation.resume(throwing: CancellationError())
                return
            }

            var cancellable: AnyCancellable?
            var didResume = false
            var sheetWasShown = false

            cancellable = self.$uiState
                .receive(on: DispatchQueue.main)
                .sink { [weak self] state in
                    guard let self else { return }
                    guard !didResume else { return }

                    if state.showFilterSheet {
                        sheetWasShown = true
                    } else if !state.showFilterSheet && sheetWasShown {
                        didResume = true
                        cancellable?.cancel()

                        let result = self.filterResult
                        self.filterResult = nil
                        continuation.resume(returning: result)
                    }
                }

            cancellable?.store(in: &self.cancellables)
        }
    }
}
