//
//  UIState.swift
//  Sample App
//
//  Created by Sevak on 17.12.25.
//
import UIKit

struct ValuesState: Codable {
    var digitalAddress = ""
    var entityId = ""
    var qrData = ""
    var deviceIdentifier = ""
    var input = ""
    var clientId = ""
    var secret = ""
}

struct UIState {
        var showInput = false
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
        var qrImage: UIImage?

        func copy(
            showInput: Bool? = nil,
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
                showInput: showInput ?? self.showInput,
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
