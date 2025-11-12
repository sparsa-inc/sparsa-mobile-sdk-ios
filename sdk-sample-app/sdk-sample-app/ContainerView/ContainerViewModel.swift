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
            try await SparsaMobile.configure(url: "BASE_URL",
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
