//
//  App.swift
//  sdk-sample-app
//
//  Created by Sevak on 28.06.24.
//

import SwiftUI

@main
struct SparsaApp: App {

    @ObservedObject private var viewModel: ContainerViewModel = .init()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    init() {
        self.viewModel =  self.appDelegate.viewModel
    }

    var body: some Scene {
        WindowGroup {
            ContainerView()
                .environmentObject(viewModel)
        }
    }
}
