//
//  ChooserView.swift
//  sdk-sample-app
//
//  Created by Sevak on 16.10.24.
//

import Foundation
import SwiftUI

struct ChooserView: View {

    @Environment(\.dismiss) private var dismiss
    var contentList: [String]
    var selectable: Bool
    @Binding var height: CGFloat
    var onSelect: (String) -> Void
    var onClose: () -> Void

    @State private var isPresented: Bool = true

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(Array(contentList.enumerated()), id: \.offset) { index, item in
                        ChooserItemView(item: item, selectable: selectable, onSelect: onSelect)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
        }
    }
}

struct InnerHeightPreferenceKey: PreferenceKey {
    static let defaultValue: CGFloat = .zero
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct ChooserItemView: View {
    var item: String
    var selectable: Bool
    var onSelect: (String) -> Void

    private var lines: [String] {
        item.components(separatedBy: "\n")
    }

    private var title: String {
        lines.first ?? ""
    }

    private var details: [String] {
        Array(lines.dropFirst())
    }

    var body: some View {
        Button(action: {
            if selectable {
                onSelect(item)
            }
        }) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .foregroundColor(.primary)
                        .font(.system(size: 16, weight: .semibold))
                        .multilineTextAlignment(.leading)

                    ForEach(details, id: \.self) { detail in
                        Text(detail)
                            .foregroundColor(.secondary)
                            .font(.system(size: 13, weight: .regular))
                            .multilineTextAlignment(.leading)
                    }
                }

                Spacer()

                if selectable {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.blue)
                        .font(.system(size: 14, weight: .semibold))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.blue.opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.blue.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
