//
//  ContainerViewModel.swift
//  sdk-sample-app
//
//  Created by Sevak on 28.06.24.
//

import Foundation
import SparsaSDK
import UIKit
import Combine

class ContainerViewModel: NSObject, ObservableObject {
    
    struct State: Codable {
        var digitalAddress = ""
        var qrData = ""
        var linkDeviceId = ""
        var transactionId = ""
        var credentialVerificationStarted = false
        var email = ""
        var clientId = ""
        var secret = ""
    }
    
    internal var cancellables = Set<AnyCancellable>()
    internal let encoder = JSONEncoder()
    internal let userDefaults = UserDefaults.standard
    
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
            try await Sparsa.shared.configure(url: "BASE_URL",
                                             clientId: weakSelf.state.clientId,
                                             clientSecret: weakSelf.state.secret,
                                             onDelete: { })
            self.setState()
            return "Sparsa successfully initialized"
        }
    }
    
    func authUser() {
        execute { weakSelf in
            let result = try await Sparsa.shared.recoverDigitalAddress(weakSelf.state.qrData)
            weakSelf.runOnMainThread { wSelf in
                wSelf.state.digitalAddress = result.digitalAddress
                wSelf.state.linkDeviceId = result.deviceIdentifier
            }
            return "Authentication succeed and device linked with digital address"
        }
    }
    
    func regUser() {
        execute { weakSelf in
            let result = try await Sparsa.shared.importDigitalAddress(weakSelf.state.qrData)
            weakSelf.runOnMainThread { wSelf in
                wSelf.state.digitalAddress = result.digitalAddress
                wSelf.state.linkDeviceId = result.deviceIdentifier
            }
            
            return "Registration succeed and device linked with digital address"
        }
    }
    
    func proofProcess() {
        execute { weakSelf in
            let qrData = try await weakSelf.getQR()
            try await Sparsa.shared.proofProcess(qrData)
            return "Process action executed"
        }
    }
    
    func getDevices() {
        getDeviceDetails()
    }
    
    func getDeviceDetails() {
        execute { weakSelf in
            let devices = try await Sparsa.shared.getDevices()
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
            let devices = try await Sparsa.shared.getDevices()
            weakSelf.showBottomSheet(items: devices.map { $0.name + " - " + $0.identifier }, selectable: true)
            if let selectedDeviceName = await weakSelf.waitForUserSelection() {
                if let selectedDevice = devices.first(where: { $0.name + " - " + $0.identifier == selectedDeviceName }) {
                    try await Sparsa.shared.deleteDevice(deviceIdentifier: selectedDevice.identifier)
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
                _ = try await Sparsa.shared.sendRecoveryEmail(email: email)
            }
            return "Sent successfuly"
        }
    }
    
    func setRecoveryEmail() {
        uiState.showEmailInput = true
        execute { weakSelf in
            if let email = try await weakSelf.waitForUserInput() {
                try await Sparsa.shared.setRecoveryEmail(email: email)
            }
            return "Set successfuly"
        }
    }
    
    func getCredentials() {
        execute { weakSelf in
            var credentials = try await Sparsa.shared.getCredentials()
            guard let (statuses, types) = try await weakSelf.presentCredentialsFilter(with: credentials) else {
                return "Failed to get credentails"
            }
            credentials = try await Sparsa.shared.getCredentials(with: statuses, and: types)
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
            var credentials = try await Sparsa.shared.getCredentials()
            if let (statuses, types) = try await weakSelf.presentCredentialsFilter(with: credentials) {
                credentials = try await Sparsa.shared.getCredentials(with: statuses, and: types)
                
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
        execute { weakSelf in try await Sparsa.shared.getLanguage() }
    }
    
    func setLanguage() {
        execute { weakSelf in
            let languages = ["Japan", "English"]
            weakSelf.showBottomSheet(items: languages, selectable: true)
            if let selectedLanguage = await weakSelf.waitForUserSelection() {
                let lang = selectedLanguage == "Japan" ? "ja" : "en"
                try await Sparsa.shared.setLanguage(language: lang)
                return "Language set to \(lang)"
            } else {
                return "Failed to set language."
            }
        }
    }
    
    // TODO: Re-enable when these methods are added to the SDK
    // func startCredentialVerificationProcess() { ... }
    // func acceptProof() { ... }
    // func rejectProof() { ... }
    
    func deviceBootstrappingVerification() {
        execute { weakSelf in
            let result = try await Sparsa.shared.deviceBootstrappingVerification { bootstrapping in
                print("Bootstrapping data: \(bootstrapping.identifier) - \(bootstrapping.status)")
            }
            weakSelf.runOnMainThread { wSelf in
                wSelf.state.digitalAddress = result.digitalAddress
                wSelf.state.linkDeviceId = result.deviceIdentifier
            }
            return "Device bootstrapping completed. Digital address: \(result.digitalAddress)"
        }
    }
    
    // TODO: Re-enable when checkBootstrappingStatus is added to the SDK
    // func checkBootstrappingStatus() { ... }
    
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
            .init(name: "Bootstrapping", buttons: [
                .init(.deviceBootstrappingVerification, disabled: false, action: deviceBootstrappingVerification)
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
                case .getCredentials, .getDevices,
                    .getDeviceDetails, .getCredentialDetails,
                    .getLanguage, .setLanguage,
                    .deviceBootstrappingVerification, .deleteDevice,
                    .proofProcess, .setRecoveryEmail:
                    state.digitalAddress.isEmpty
                }
            }
        }
    }
}
