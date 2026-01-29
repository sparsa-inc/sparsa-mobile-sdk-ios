//
//  BootstrappingView.swift
//  Sample App
//
//  Created by Sevak on 15.12.25.
//

import SwiftUI

struct BootstrappingView: View {

    let qr: UIImage
    @State private var timer: Timer?
    @State private var secondsRemaining: Int = 120

    let onTimeout: () -> Void
    let onCancel: () -> Void

    init(qr: UIImage, onTimeout: @escaping () -> Void, onCancel: @escaping () -> Void) {
        self.qr = qr
        self.onTimeout = onTimeout
        self.onCancel = onCancel
    }

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: onCancel) {
                    Image(systemName: "xmark")
                        .foregroundColor(.gray)
                        .font(.system(size: 18, weight: .medium))
                        .padding(8)
                }
            }
            .padding(.horizontal)

            Image(uiImage: qr)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: UIScreen.main.bounds.width * 0.5)
            Text(formattedTime)
                .font(.system(size: 24, weight: .medium, design: .monospaced))
                .foregroundColor(.gray)
                .padding(.top, 8)
            Text("1. Open the other mobile app where the digital address is imported")
            Text("2. Choose `proofProcess` to accept or reject the credential verification")
        }
        .multilineTextAlignment(.leading)
        .padding(.horizontal)
        .onAppear {
            self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
                if secondsRemaining == 0 {
                    onTimeout()
                    timer.invalidate()
                } else {
                    secondsRemaining -= 1
                }
            }
        }
        .onDisappear {
            timer?.invalidate()
            onCancel()
        }
    }

    private var formattedTime: String {
        let minutes = secondsRemaining / 60
        let secs = secondsRemaining % 60
        return String(format: "%02d:%02d", minutes, secs)
    }
}

#Preview {
//    BootstrappingView()
}
