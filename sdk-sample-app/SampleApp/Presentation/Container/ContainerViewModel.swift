//
//  ContainerViewModel.swift
//  sdk-sample-app
//
//  Created by Sevak on 28.06.24.
//

import Foundation
import Sparsa
import UIKit
import Combine
import CoreImage.CIFilter

class ContainerViewModel: NSObject, ObservableObject {

    //MARK: - Member properties
    let encoder = JSONEncoder()
    let userDefaults = UserDefaults.standard
    let baseUrl = "https://exchange-api.dev.sparsainc.com"
    var cancellables = Set<AnyCancellable>()
    var fetchedCredentialsForFilter: [Credential] = []
    var filterResult: (statuses: Set<String>, schemaIds: Set<String>)? = nil

    @Published var uiState = UIState()
    @Published var state: ValuesState = .init() {
        didSet { updateButtonStates() }
    }

    //MARK: - ViewModel initialization method
    override init() {
        super.init()
        encoder.outputFormatting = .prettyPrinted
        uiState.groups = buttonGroups
        getState()
        updateButtonStates()
        configureSDK()
    }

    //MARK: - Sparsa Configuration Methods
    func configureSDK() {
        uiState.showConfigureSheet = true
    }

    func submitSDKConfiguration() {
        execute { weakSelf in
            try await Sparsa.shared.configure(url: weakSelf.baseUrl,
                                              clientId: weakSelf.state.clientId,
                                              clientSecret: weakSelf.state.secret,
                                              onDelete: { [weak self] in
                                                  self?.clearState()
                                                  self?.updateButtonStates()
                                              })
            self.setState()
            return "Sparsa successfully initialized"
        }
    }

    //MARK: - Sparsa Authentication
    func recoverDigitalAddress() {
        execute { weakSelf in
            let result = try await Sparsa.shared.recoverDigitalAddress(weakSelf.state.qrData)
            weakSelf.runOnMainThread { wSelf in
                wSelf.state.digitalAddress = result.digitalAddress
                wSelf.state.deviceIdentifier = result.deviceIdentifier
            }
            return "Authentication succeed and device linked with digital address"
        }
    }

    func importDigitalAddress() {
        execute { weakSelf in
            let result = try await Sparsa.shared.importDigitalAddress(weakSelf.state.qrData)
            weakSelf.runOnMainThread { wSelf in
                wSelf.state.digitalAddress = result.digitalAddress
                wSelf.state.deviceIdentifier = result.deviceIdentifier
            }

            return "Registration succeed and device linked with digital address"
        }
    }
    func updateDigitalAddress() {
        uiState.showInput = true
        execute { weakSelf in
            let da = try await Sparsa.shared.getDigitalAddress()
            weakSelf.state.digitalAddress = da
            weakSelf.state.input = da
            if let digitalAddress = try await weakSelf.waitForUserInput() {
                let result = try await Sparsa.shared.updateDigitalAddress(digitalAddress)
                weakSelf.runOnMainThread { wSelf in
                    wSelf.state.digitalAddress = result
                }
                return "Digital Address updated successfully, new: \(result)"
            } else {
                return "No input found"
            }
        }
    }

    func getDigitalAddress() {
        execute { weakSelf in
            let da = try await Sparsa.shared.getDigitalAddress()
            weakSelf.state.digitalAddress = da
            return "Current Digital Address is: \(da)"
        }
    }

    func deviceBootstrappingVerification() {
        execute { weakSelf in
            do {
                let result = try await Sparsa.shared.deviceBootstrappingVerification { result in
                    guard let image = weakSelf.generateQRCode(from: result) else {
                        return
                    }
                    weakSelf.runOnMainThread { wSelf in
                        wSelf.uiState.qrImage = image
                    }
                }
                weakSelf.uiState.qrImage = nil
                weakSelf.state.digitalAddress = result.digitalAddress
                weakSelf.state.deviceIdentifier = result.deviceIdentifier
                return "Digital Address: \(result.digitalAddress) imported"
            } catch {
                weakSelf.uiState.qrImage = nil
                throw error
            }
        }
    }

    //MARK: - Sparsa Credentials
    func proofProcess() {
        execute { weakSelf in
            let qrData = try await weakSelf.getQR()
            try await Sparsa.shared.proofProcess(qrData)
            return "Process action executed"
        }
    }

    func getCredentials() {
        execute { weakSelf in
            guard let credential = try await weakSelf.selectCredential() else {
                return ""
            }
            return weakSelf.toJson(obj: credential)
        }
    }

    func getCredentialDetails() {
        execute { weakSelf in
            guard let credential = try await weakSelf.selectCredential(),
                  let identifier = credential.identifier else {
                return ""
            }
            let details = try await Sparsa.shared.getCredentialDetails(identifier: identifier)
            return weakSelf.toJson(obj: details)
        }
    }

    //MARK: - Sparsa Devices
    func getDevices() {
        execute { weakSelf in
            guard let selectedDevice = try await weakSelf.selectDevice() else {
                return ""
            }
            return weakSelf.toJson(obj: selectedDevice)
        }
    }

    func deleteDevice() {
        execute { weakSelf in
            if let selectedDevice = try await weakSelf.selectDevice() {
                _ = try await Sparsa.shared.deleteDevice(deviceIdentifier: selectedDevice.identifier)
                if selectedDevice.identifier == weakSelf.state.deviceIdentifier {
                    weakSelf.clearState()
                }
                return "Successfully deleted."
            }
            return ""
        }
    }

    //MARK: - Sparsa Emails
    func sendRecoveryEmail() {
        uiState.showInput = true
        execute { weakSelf in
            if let email = try await weakSelf.waitForUserInput() {
                _ = try await Sparsa.shared.sendRecoveryEmail(email: email)
            }
            return "Sent successfuly"
        }
    }

    func setRecoveryEmail() {
        uiState.showInput = true
        execute { weakSelf in
            if let email = try await weakSelf.waitForUserInput() {
                try await Sparsa.shared.setRecoveryEmail(email: email)
            }
            return "Email set successfully"
        }
    }

    //MARK: - Sparsa Languages
    func getLanguage() {
        execute { weakSelf in try await Sparsa.shared.getLanguage() }
    }

    func setLanguage() {
        execute { weakSelf in
            let lang = try await weakSelf.selectLanguage()
            try await Sparsa.shared.setLanguage(language: lang)
            return "Language updated successfully."
        }
    }
}
