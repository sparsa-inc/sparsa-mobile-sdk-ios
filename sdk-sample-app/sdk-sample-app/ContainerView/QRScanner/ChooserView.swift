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
        VStack {
            List(contentList, id: \.self) { item in
                ChooserItemView(item: item, selectable: selectable, onSelect: onSelect)
            }
        }
        .onDisappear {
            onClose()
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
    
    var body: some View {
        Button(action: {
            if selectable {
                onSelect(item)
            }
        }) {
            HStack {
                Text(item)
                    .foregroundColor(Color.blue)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                if selectable {
                    Image(systemName: "chevron.right")
                        .foregroundColor(Color.blue)
                }
            }
        }
        .padding(.horizontal, 20)
    }
}
