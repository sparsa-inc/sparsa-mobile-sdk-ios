//
//  Utils.swift
//  sdk-sample-app
//
//  Created by Sevak on 12.11.25.
//

import Foundation
import SparsaMobile
import Combine
import UIKit

extension ContainerViewModel {
    
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
    
    func showBottomSheet(items: [String], selectable: Bool = false) {
        sleep(1)
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
            self?.uiState.alertMessage = message
            self?.uiState.showAlert = true
        }
    }
    
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
