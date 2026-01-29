//
//  ButtonModel.swift
//  sdk-sample-app
//
//  Created by Sevak on 07.08.24.
//

import Foundation

enum SparsaButton: CaseIterable {
    case authUser
    case regUser
    case updateDigitalAddress
    case getDigitalAddress
    case deleteDevice
    case getCredentials
    case getCredentialDetails
    case getDevices
    case getLanguage
    case setLanguage
    case sendRecoveryEmail
    case setRecoveryEmail
    case deviceBootstrappingVerification
    case proofProcess
    
    var title: String {
        switch self {
        case .authUser:
            "Recover Digital Address"
        case .regUser:
            "Import Digital Address"
        case .updateDigitalAddress:
            "Update Digital Address"
        case .getDigitalAddress:
            "Get Digital Address"
        case .deleteDevice:
            "Delete Device"
        case .getCredentials:
            "Get Credentials"
        case .getCredentialDetails:
            "Get Credential Details"
        case .getDevices:
            "Get Devices"
        case .getLanguage:
            "Get Language"
        case .setLanguage:
            "Set Language"
        case .sendRecoveryEmail:
            "Send Recovery Email"
        case .setRecoveryEmail:
            "Set Recovery Email"
        case .deviceBootstrappingVerification:
            "Use Registered Device"
        case .proofProcess:
            "Proof Process"
        }
    }
}

class SparsaButtonItem: Identifiable, ObservableObject {
    var id = UUID()
    let item: SparsaButton
    @Published var disabled: Bool
    @Published var hidden: Bool
    let action: () -> Void
    
    init(_ item: SparsaButton, disabled: Bool = true, hidden: Bool = false, action: @escaping () -> Void) {
        self.item = item
        self.disabled = disabled
        self.hidden = hidden
        self.action = action
    }
}

class ButtonsGroup: Identifiable, ObservableObject {
    var id = UUID()
    var name: String
    @Published var buttons: [SparsaButtonItem]
    
    init(name: String, buttons: [SparsaButtonItem]) {
        self.name = name
        self.buttons = buttons
    }
}
