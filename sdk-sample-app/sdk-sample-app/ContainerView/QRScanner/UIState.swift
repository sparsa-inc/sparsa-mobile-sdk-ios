//
//  UIState.swift
//  sdk-sample-app
//
//  Created by Sevak on 12.11.25.
//


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