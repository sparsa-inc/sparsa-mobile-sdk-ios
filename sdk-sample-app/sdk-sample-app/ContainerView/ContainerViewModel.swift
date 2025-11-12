//
//  ContainerViewModel.swift
//  sdk-sample-app
//
//  Created by Sevak on 28.06.24.
//

import Foundation
import SparsaMobile
import UIKit
import Combine

internal enum EnvironmentMode: String, Codable, CaseIterable {
    case qa
    case dev
    case authid
    case stage
    
    var env: String {
        self.rawValue
    }
}


class ContainerViewModel: NSObject, ObservableObject {
    
    struct State: Codable {
        var digitalAddress = ""
        var entityId = ""
        var qrData = ""
        var linkDeviceId = ""
        var transactionId = ""
        var credentialVerificationStarted = false
        var templateFieldData = ""
        var email = ""
        var clientId = ""
        var secret = ""
    }

    struct UIState {
        var showEmailInput = false
        var groups: [ButtonsGroup] = []
        var chooserList: [String] = []
        var selectableItems: Bool = false
        var selectedItem: String? = nil
        var showBottomSheet = false
        var showFilterSheet = false
        var showAlert = false
        var requesting = false
        var alertMessage = ""
        var showConfigureSheet = false

        func copy(
            showEmailInput: Bool? = nil,
            groups: [ButtonsGroup]? = nil,
            chooserList: [String]? = nil,
            selectableItems: Bool? = nil,
            selectedItem: String?? = nil,
            showBottomSheet: Bool? = nil,
            showAlert: Bool? = nil,
            requesting: Bool? = nil,
            alertMessage: String? = nil,
            showConfigureSheet: Bool? = nil
        ) -> UIState {
            return UIState(
                showEmailInput: showEmailInput ?? self.showEmailInput,
                groups: groups ?? self.groups,
                chooserList: chooserList ?? self.chooserList,
                selectableItems: selectableItems ?? self.selectableItems,
                selectedItem: (selectedItem != nil ? selectedItem! : self.selectedItem),
                showBottomSheet: showBottomSheet ?? self.showBottomSheet,
                showAlert: showAlert ?? self.showAlert,
                requesting: requesting ?? self.requesting,
                alertMessage: alertMessage ?? self.alertMessage,
                showConfigureSheet: showConfigureSheet ?? self.showConfigureSheet
            )
        }
    }
    
    private var cancellables = Set<AnyCancellable>()
    private let encoder = JSONEncoder()
    private let userDefaults = UserDefaults.standard
    
    @Published var uiState = UIState()
    @Published var state: ContainerViewModel.State = .init() {
        didSet { updateButtonStates() }
    }
    
    var fetchedCredentialsForFilter: [Credential] = []
    var filterResult: (statuses: Set<String>, schemaIds: Set<String>)? = nil
    
        
    override init() {
        super.init()
        encoder.outputFormatting = .prettyPrinted
        uiState.groups = buttonGroups
        getState()
        updateButtonStates()
        configureSDK()
    }
    
    func configureSDK() {
        uiState.showConfigureSheet = true
    }

    func submitSDKConfiguration() {
        execute { weakSelf in
            try await SparsaMobile.configure(url: "https://exchange-api.dev.sparsainc.com",
                                             clientId: weakSelf.state.clientId,
                                             clientSecret: weakSelf.state.secret)
            self.setState()
            return "Sparsa successfully initialized"
        }
    }
    
    func authUser() {
        execute { weakSelf in
            let result = try await SparsaMobile.recoverDigitalAddress(weakSelf.state.qrData)
            weakSelf.runOnMainThread { wSelf in
                wSelf.state.digitalAddress = result.digitalAddress
                wSelf.state.linkDeviceId = result.linkDeviceId
            }
            return "Authentication succeed and device linked with digital address"
        }
    }
    
    func regUser() {
        execute { weakSelf in
            let result = try await SparsaMobile.importDigitalAddress(weakSelf.state.qrData)
            weakSelf.runOnMainThread { wSelf in
                wSelf.state.digitalAddress = result.digitalAddress
                wSelf.state.linkDeviceId = result.linkDeviceId
            }
            
            return "Registration succeed and device linked with digital address"
        }
    }
    
    func proofProcess() {
        execute { weakSelf in
            let qrData = try await weakSelf.getQR()
            try await SparsaMobile.proofProcess(qrData)
            return "Process action executed"
        }
    }
    
    func getDevices() {
        getDeviceDetails()
    }
    
    func getDeviceDetails() {
        execute { weakSelf in
            let devices = try await SparsaMobile.getDevices()
            weakSelf.showBottomSheet(items: devices.map { $0.name + " - " + $0.identifier }, selectable: true)
            if let selectedDeviceName = await weakSelf.waitForUserSelection() {
                if let selectedDevice = devices.first(where: { $0.name + " - " + $0.identifier == selectedDeviceName }) {
                    return weakSelf.toJson(obj: selectedDevice)
                }
            }
            return ""
        }
    }
    
    func deleteDevice() {
        execute { weakSelf in
            let devices = try await SparsaMobile.getDevices()
            weakSelf.showBottomSheet(items: devices.map { $0.name + " - " + $0.identifier }, selectable: true)
            if let selectedDeviceName = await weakSelf.waitForUserSelection() {
                if let selectedDevice = devices.first(where: { $0.name + " - " + $0.identifier == selectedDeviceName }) {
                    try await SparsaMobile.deleteDevice(deviceIdentifier: selectedDevice.identifier)
                    if selectedDevice.identifier == weakSelf.state.linkDeviceId {
                        weakSelf.clearState()
                    }
                    return "Successfully deleted."
                }
            }
            return "Failed to delete device."
        }
    }
    
    func sendRecoveryEmail() {
        uiState.showEmailInput = true
        execute { weakSelf in
            if let email = try await weakSelf.waitForUserInput() {
                _ = try await SparsaMobile.sendRecoveryEmail(email: email)
            }
            return "Sent successfuly"
        }
    }
    
    func setRecoveryEmail() {
        uiState.showEmailInput = true
        execute { weakSelf in
            if let email = try await weakSelf.waitForUserInput() {
                try await SparsaMobile.setRecoveryEmail(email: email)
            }
            return "Set successfuly"
        }
    }
    
    func getCredentials() {
        execute { weakSelf in
            var credentials = try await SparsaMobile.getCredentials()
            guard let (statuses, types) = try await weakSelf.presentCredentialsFilter(with: credentials) else {
                return "Failed to get credentails"
            }
            credentials = try await SparsaMobile.getCredentials(with: statuses, and: types)
            if credentials.isEmpty {
                return "No credentials found with statuses: \(statuses) and types: \(types)"
            }
            weakSelf.showBottomSheet(items: credentials.compactMap { $0.schema }, selectable: true)
            if let selectedCredentialName = await weakSelf.waitForUserSelection() {
                if let selectedCredential = credentials.first(where: { $0.schema == selectedCredentialName }) {
                    return weakSelf.toJson(obj: selectedCredential)
                }
            }
            return "Failed to get credentails"
        }
    }
    
    func getCredentialDetails() {
        execute { weakSelf in
            var credentials = try await SparsaMobile.getCredentials()
            if let (statuses, types) = try await weakSelf.presentCredentialsFilter(with: credentials) {
                credentials = try await SparsaMobile.getCredentials(with: statuses, and: types)
                
            }
            weakSelf.showBottomSheet(items: credentials.compactMap { $0.schema }, selectable: true)
            if let selectedCredentialName = await weakSelf.waitForUserSelection() {
                if let selectedCredential = credentials.first(where: { $0.schema == selectedCredentialName }) {
                    return weakSelf.toJson(obj: selectedCredential)
                }
            }
            return "Failed to get credentails"
        }
    }
    
    func getLanguage() {
        execute { weakSelf in try await SparsaMobile.getLanguage() }
    }
    
    func setLanguage() {
        execute { weakSelf in
            let languages = ["Japan", "English"]
            weakSelf.showBottomSheet(items: languages, selectable: true)
            if let selectedLanguage = await weakSelf.waitForUserSelection() {
                let lang = selectedLanguage == "Japan" ? "ja" : "en"
                let result = try await SparsaMobile.setLanguage(language: lang)
                return result
            } else {
                return "Failed to set language."
            }
        }
    }
    
    func startCredentialVerificationProcess() {
        execute { weakSelf in
            
            let result = try await SparsaMobile.startCredentialVerificationProcess(transactionId: weakSelf.state.transactionId)
            weakSelf.runOnMainThread { wSelf in
                wSelf.state.credentialVerificationStarted = true
            }
            return [result.questionTitle, "Status: " + result.status].joined(separator: ", ")
        }
    }
    
    func acceptProof() {
        execute { weakSelf in
            let credentials = try await SparsaMobile.getCredentials()
            weakSelf.showBottomSheet(items: credentials.map { $0.schema }, selectable: true)
            if let selectedCredentialName = await weakSelf.waitForUserSelection() {
                if let selectedCredential = credentials.first(where: { $0.schema == selectedCredentialName }),
                   let identifier = selectedCredential.identifier {
                    let result = try await SparsaMobile.acceptProof(transactionId: weakSelf.state.transactionId,
                                                                    credentialIdentifier: identifier)
                    weakSelf.runOnMainThread { wSelf in
                        wSelf.state.credentialVerificationStarted = false
                        wSelf.state.transactionId = ""
                    }
                    return [result.identifier + " accepted", "\nStatus: " + result.status].joined(separator: ", ")
                }
            }
            return "Failed to accept proof"
        }
    }
    
    func rejectProof() {
        execute { weakSelf in
            let result = try await SparsaMobile.rejectProof(transactionId: weakSelf.state.transactionId)
            weakSelf.runOnMainThread { wSelf in
                wSelf.state.credentialVerificationStarted = false
                wSelf.state.transactionId = ""
            }
            return [result.identifier + " rejected", "\nStatus: " + result.status].joined(separator: ", ")
        }
    }
    
    func deviceBootstrappingVerification() {
        execute { weakSelf in
            let result = try await SparsaMobile.deviceBootstrappingVerification()
            weakSelf.runOnMainThread { wSelf in
                wSelf.state.transactionId = result.identifier
            }
            return result.identifier + "\nStatus is: " + result.status
        }
    }
    
    func checkBootstrappingStatus() {
        execute { weakSelf in
            let result = try await SparsaMobile.checkBootstrappingStatus(with: weakSelf.state.transactionId)
            return "Status is: " + result.status
        }
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
    
    func execute(_ block: @escaping (ContainerViewModel) async throws -> String) {
        Task { @MainActor [weak self] in
            guard let self = self else { return }
            
            do {
                self.uiState.requesting = true
                self.showAlert(with: try await block(self))
                self.uiState.requesting = false
            } catch {
                self.showAlert(with: error.localizedDescription)
                self.uiState.requesting = false
            }
        }
    }
    
    func showAlert(with message: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
            self?.uiState.alertMessage = message
            self?.uiState.showAlert = true
        }
    }
    
    var buttonGroups: [ButtonsGroup] {
        return [
            .init(name: "Authentication",
                  buttons: [
                    .init(.authUser, action: authUser),
                    .init(.regUser, action: regUser),
                    .init(.deleteDevice, action: deleteDevice),
                    .init(.proofProcess, action: proofProcess)
                  ]),
            .init(name: "Email", buttons: [
                .init(.sendRecoveryEmail, disabled: false, action: sendRecoveryEmail),
                .init(.setRecoveryEmail, disabled: false, action: setRecoveryEmail)
            ]),
            .init(name: "Digital Address Dependent",
                  buttons: [
                    .init(.getCredentials, action: getCredentials),
                    .init(.getCredentialDetails, action: getCredentialDetails),
                    .init(.getDevices, action: getDevices),
                    .init(.getDeviceDetails, action: getDeviceDetails),
                    .init(.setLanguage, action: setLanguage),
                    .init(.getLanguage, action: getLanguage)
                  ]),
            .init(name: "Bootstrapping, Credential Verification", buttons: [
                .init(.deviceBootstrappingVerification, disabled: false, action: deviceBootstrappingVerification),
                .init(.checkBootstrappingStatus, action: checkBootstrappingStatus),
                .init(.startCredentialVerificationProcess, action: startCredentialVerificationProcess),
                .init(.acceptProof, action: acceptProof),
                .init(.rejectProof, action: rejectProof)
            ])
        ]
    }
    
    private func updateButtonStates() {
        setState()
        for group in uiState.groups {
            for button in group.buttons {
                button.disabled = switch button.item {
                case .authUser, .regUser:
                    state.qrData.isEmpty || !state.digitalAddress.isEmpty
                case .sendRecoveryEmail:
                    false
                case .startCredentialVerificationProcess:
                    state.digitalAddress.isEmpty ||
                    state.transactionId.isEmpty ||
                    state.credentialVerificationStarted
                case .getCredentials, .getDevices,
                    .getDeviceDetails, .getCredentialDetails,
                    .getLanguage, .setLanguage,
                    .deviceBootstrappingVerification, .deleteDevice,
                    .proofProcess, .setRecoveryEmail:
                    state.digitalAddress.isEmpty
                case .checkBootstrappingStatus:
                    state.transactionId.isEmpty
                case .acceptProof, .rejectProof:
                    !state.credentialVerificationStarted
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
    
    func waitForUserSelection() async -> String? {
        await withCheckedContinuation { continuation in
            var cancellable: AnyCancellable?
            cancellable = self.$uiState.sink { state in
                if let selectedItem = state.selectedItem, !selectedItem.isEmpty {
                    continuation.resume(returning: selectedItem)
                    cancellable?.cancel()
                }
            }
            cancellable?.store(in: &cancellables)
        }
    }
    
    func waitForUserInput() async throws -> String? {
        try await withCheckedThrowingContinuation { continuation in
            var cancellable: AnyCancellable?
            cancellable = self.$uiState.sink { state in
                if !state.showEmailInput  {
                    if !self.state.email.isEmpty {
                        continuation.resume(returning: self.state.email)
                        cancellable?.cancel()
                    } else {
                        continuation.resume(throwing: NSError(domain: "Action cancelled by user action", code: 0))
                        cancellable?.cancel()
                    }
                }
            }
            cancellable?.store(in: &cancellables)
        }
    }
    
    func showBottomSheet(items: [String], selectable: Bool = false) {
        DispatchQueue.main.async { [weak self] in
            self?.uiState.chooserList = items
            self?.uiState.selectableItems = selectable
            self?.uiState.showBottomSheet = true
        }
    }
    
    func hideBottomSheet() {
        DispatchQueue.main.async { [weak self] in
            self?.uiState.chooserList = []
            self?.uiState.selectedItem = nil
            self?.uiState.showBottomSheet = false
            self?.uiState.requesting = false
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
    
    func toJson(obj: [String: Any]) -> String {
        if let jsonData = try? JSONSerialization.data(withJSONObject: obj, options: .prettyPrinted),
           let result = String(data: jsonData, encoding: .utf8) {
            return result
        }
        return ""
    }
    
    func fromJson(_ json: String) -> [String: Any] {
        guard let jsonData = json.data(using: .utf8) else { return [:] }
        do {
            return (try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any]) ?? [:]
        }
    }
    
    func clearState() {
        runOnMainThread { weakSelf in
            weakSelf.state = State()
        }
        
        self.setState()
    }
    
    func getState() {
        if let data = userDefaults.data(forKey: "state") {
            self.state = (try? JSONDecoder().decode(State.self, from: data)) ?? State()
        }
    }
    
    func setState() {
        let data = try? encoder.encode(state)
        userDefaults.setValue(data, forKey: "state")
    }
}


extension ContainerViewModel {
    
    func presentCredentialsFilter(with credentials: [Credential]) async throws -> (Set<String>, Set<String>)? {
        runOnMainThread { vm in
            vm.fetchedCredentialsForFilter = credentials
            vm.uiState.showFilterSheet = true
        }
        sleep(1)
        let result = try await waitForFilterSelection()
        runOnMainThread { vm in
            vm.uiState.showFilterSheet = false
        }
        return result
    }
    
    func waitForFilterSelection() async throws -> (Set<String>, Set<String>)? {
        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<(Set<String>, Set<String>)?, Error>) in
            guard !Task.isCancelled else {
                continuation.resume(throwing: CancellationError())
                return
            }

            var cancellable: AnyCancellable?
            var didResume = false

            cancellable = self.$uiState
                .receive(on: DispatchQueue.main)
                .sink { [weak self] state in
                    guard let self else { return }
                    guard !didResume else { return }

                    if !state.showFilterSheet {
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
