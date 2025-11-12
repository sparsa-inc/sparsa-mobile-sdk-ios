//
//  ContainerView.swift
//  sdk-sample-app
//
//  Created by Sevak on 28.06.24.
//

import SwiftUI
import Combine
import SparsaMobile

struct ContainerView: View {

    @EnvironmentObject private var viewModel: ContainerViewModel
    @State private var sheetHeight = CGFloat.zero
    var body: some View {
        NavigationView {
            mainContent
        }
    }
    
    var mainContent: some View {
        ZStack {
            VStack {
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
                        .tint(.white)
                        .foregroundStyle(.white)
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
                .background(Color.backgroundMain.opacity(0.8))
            }
        }
        .navigationTitle("Sparsa Sample App")
        .navigationBarTitleDisplayMode(.automatic)
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
                    viewModel.hideBottomSheet()
                }
            )
            .presentationDetents([.medium, .large])
        }
        .fullScreenCover(isPresented: $viewModel.uiState.showFilterSheet) {
            CredentialsFilterView()
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
        .alert("Recovery Email", isPresented: $viewModel.uiState.showEmailInput) {
            TextField("Email", text: $viewModel.state.email)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
            Button("Continue") {
                viewModel.uiState.showEmailInput = false
            }
            Button("Cancel", role: .cancel) {
                viewModel.state.email = ""
                viewModel.uiState.showEmailInput = false
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    viewModel.configureSDK()
                } label: {
                    Image(systemName: "arrow.trianglehead.2.counterclockwise.rotate.90")
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
