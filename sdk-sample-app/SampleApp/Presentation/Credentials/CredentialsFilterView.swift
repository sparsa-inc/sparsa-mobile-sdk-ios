//
//  CredentialsFilterView.swift
//  sdk-sample-app
//
//  Created by Sevak on 13.10.25.
//

import SwiftUI

struct CredentialsFilterView: View {
    private let all = "All"
    private let statuses = ["All", "Active", "Revoked"]
    
    @EnvironmentObject private var viewModel: ContainerViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedStatuses: Set<String> = ["All"]
    @State private var selectedSchemaIds: Set<String> = ["All"]

    private var schemaOptions: [String] {
        var options = ["All"]
        options += Array(viewModel.fetchedCredentialsForFilter.reduce(Set<String>()) { partialResult, credential in
            var res = partialResult
            res.insert(credential.schema)
            return res
        }).sorted(by: <)
        return options
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Section {
                    List(statuses, id: \.self, selection: $selectedStatuses) { status in
                        Text(status)
                    }
                    .environment(\.editMode, .constant(.active))
                    .onChange(of: selectedStatuses) { [selectedStatuses] newValue in
                        let oldValue = selectedStatuses
                        if newValue.contains(all) && !oldValue.contains(all) {
                            self.selectedStatuses = [all]
                        } else if oldValue.contains(all) && newValue.count > 1 {
                            self.selectedStatuses.remove(all)
                        }
                    }
                } header: {
                    Text("Status")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                }
                
                Section {
                    List(schemaOptions, id: \.self, selection: $selectedSchemaIds) { option in
                        Text(option)
                    }
                    .environment(\.editMode, .constant(.active))
                    .onChange(of: selectedSchemaIds) { [selectedSchemaIds] newValue in
                        let oldValue = selectedSchemaIds
                        if newValue.contains(all) && !oldValue.contains(all) {
                            self.selectedSchemaIds = [all]
                        } else if oldValue.contains(all) && newValue.count > 1 {
                            self.selectedSchemaIds.remove(all)
                        }
                    }
                } header: {
                    Text("Type")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                }
                Spacer()
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        cancel()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Apply") {
                        apply()
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Filter Credentials")
        }
       
    }

    private func cancel() {
        viewModel.runOnMainThread { vm in
            vm.uiState.showFilterSheet = false
        }
        dismiss()
    }

    private func apply() {
        let statuses = Set(selectedStatuses.map(\.localizedLowercase))
        let schemaIds = Set(
            viewModel.fetchedCredentialsForFilter
                .filter {
                    selectedSchemaIds.contains($0.schema)
                }
                .map(\.schemaIdentifier)
        )
        viewModel.uiState.showFilterSheet = false
        viewModel.filterResult = (statuses, schemaIds)
        dismiss()
    }
}

#Preview {
    CredentialsFilterView()
        .environmentObject(ContainerViewModel())
}
