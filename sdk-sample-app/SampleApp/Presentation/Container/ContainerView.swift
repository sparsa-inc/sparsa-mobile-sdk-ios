//
//  ContainerView.swift
//  sdk-sample-app
//
//  Created by Sevak on 28.06.24.
//

import SwiftUI
import Combine
import SparsaSDK
import UIKit

struct ContainerView: View {

    @EnvironmentObject private var viewModel: ContainerViewModel
    @State private var sheetHeight = CGFloat.zero
    var body: some View {
        ZStack {
            NavigationView {
                mainContent
            }
            if viewModel.uiState.showAlert {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)

                VStack(spacing: 10) {
                    Text("Sparsa SDK")
                        .font(.headline)
                    Divider()
                    if viewModel.uiState.alertMessage.contains("{") {
                        ScrollViewReader { scrollProxy in
                            ScrollView([.vertical, .horizontal], showsIndicators: false) {
                                Text(viewModel.uiState.alertMessage)
                                    .id("alertText")
                                    .padding()
                            }
                            .onAppear {
                                scrollProxy.scrollTo("alertText", anchor: .topLeading)
                            }
                        }
                    } else {
                        ScrollView {
                            Text(viewModel.uiState.alertMessage)
                                .multilineTextAlignment(.leading)
                                .frame(minHeight: 100)
                                .truncationMode(.tail)
                                .lineLimit(100)
                        }
                    }
                    Divider()
                    Button {
                        viewModel.uiState.showAlert = false
                    } label: {
                        Text("OK")
                            .frame(width: 100)
                    }
                }
                .ignoresSafeArea()
                .padding()
                .frame(minWidth: UIScreen.main.bounds.width * 0.6,
                       maxWidth: UIScreen.main.bounds.width - 60,
                       maxHeight: UIScreen.main.bounds.height - 200)
                .fixedSize()
                .padding()
                .background(.background)
                .cornerRadius(15)
                .shadow(color: .gray, radius: 10)
                .transition(.scale)
            }
            if viewModel.uiState.requesting {
                VStack {
                    Spacer()
                    ProgressView("Requesting...")
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
                .background(Color.backgroundMain.opacity(0.8))
            }
        }
    }

    var mainContent: some View {
        VStack(spacing: 0) {
            if !viewModel.state.digitalAddress.isEmpty {
                DigitalAddressCard(
                    digitalAddress: viewModel.state.digitalAddress,
                    onCopy: {
                        UIPasteboard.general.string = viewModel.state.digitalAddress
                    }
                )
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
            List(viewModel.uiState.groups) { group in
                Section(group.name) {
                    ForEach(group.buttons.filter { !$0.hidden }) { button in
                        Button(button.item.title, action: button.action)
                            .foregroundStyle(button.disabled ? .gray : .blue)
                            .disabled(button.disabled)
                    }
                }
            }
            .listStyle(.sidebar)
        }
        .navigationTitle("Sparsa Sample App")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarHidden(false)
        .sheet(isPresented: $viewModel.uiState.showBottomSheet) {
            ChooserView(
                contentList: viewModel.uiState.chooserList,
                selectable: viewModel.uiState.selectableItems,
                height: $sheetHeight,
                onSelect: { selectedItem in
                    viewModel.uiState = viewModel.uiState.copy(selectedItem: selectedItem)
                    viewModel.hideBottomSheet()
                },
                onClose: {
                    sheetHeight = .zero
                    viewModel.hideBottomSheet()
                }
            )
            .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: $viewModel.uiState.showFilterSheet) {
            CredentialsFilterView()
                .presentationDetents([.fraction(0.8)])
        }
        .sheet(isPresented: $viewModel.uiState.showConfigureSheet) {
            VStack(alignment: .leading, spacing: 16) {
                Text("SDK Configuration")
                    .font(.title2)
                    .bold()

                TextField("Client ID", text: $viewModel.state.clientId)
                    .textFieldStyle(.roundedBorder)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)

                TextField("Client Secret", text: $viewModel.state.secret)
                    .textFieldStyle(.roundedBorder)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)

                HStack {
                    Spacer()
                    Button("Submit") {
                        viewModel.uiState.showConfigureSheet = false
                        viewModel.submitSDKConfiguration()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding()
            .presentationDetents([.height(250)])
        }
        .sheet(item: $viewModel.uiState.qrImage) { image in
            BootstrappingView(
                qr: image,
                onTimeout: {
                    viewModel.uiState.qrImage = nil
                    viewModel.uiState.requesting = false
                    viewModel.showAlert(with: "Bootstrapping timed out")
                },
                onCancel: {
                    viewModel.uiState.qrImage = nil
                    viewModel.uiState.requesting = false
                    viewModel.showAlert(with: "Bootstrapping cancelled")
                }
            )
            .presentationDetents([.medium])
        }
        .alert("Input Value", isPresented: $viewModel.uiState.showInput) {
            TextField("Input", text: $viewModel.state.input)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
            Button("Continue") {
                viewModel.uiState.showInput = false
            }
            Button("Cancel", role: .cancel) {
                viewModel.state.input = ""
                viewModel.uiState.showInput = false
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    viewModel.configureSDK()
                } label: {
                    Image(systemName: "arrow.triangle.2.circlepath")
                }
            }
            
            ToolbarItem(placement: .topBarLeading) {
                Button("", systemImage: "qrcode.viewfinder") {
                    viewModel.detectQR()
                }
            }
        }
    }
}

#Preview {
    ContainerView()
}

extension UIImage: @retroactive Identifiable {
    public var id: String { return self.description }
}

struct DigitalAddressCard: View {
    let digitalAddress: String
    let onCopy: () -> Void

    @State private var showCopied = false

    var body: some View {
        ZStack(alignment: .trailing) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Digital Address")
                    .font(.caption)
                    .foregroundColor(.gray)
                Text(digitalAddress)
                    .font(.body)
                    .foregroundColor(.blue)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if showCopied {
                Text("Copied!")
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.green)
                    .cornerRadius(4)
                    .transition(.opacity)
            }
        }
        .onTapGesture {
            onCopy()
            withAnimation {
                showCopied = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation {
                    showCopied = false
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.blue, lineWidth: 1)
        )
    }
}
