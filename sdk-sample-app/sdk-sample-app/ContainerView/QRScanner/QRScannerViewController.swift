//
//  QRScannerViewController.swift
//  sparsa-mobile-sdk
//
//  Created by Sevak on 05.08.24.
//

import Foundation
import AVFoundation
import UIKit
import SwiftUI

class QRScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    let session = AVCaptureSession()
    
    var result: ((Result<String, Error>) -> Void)? = nil
    var onClose: (() -> Void)? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
        let overlayView = UIHostingController(rootView: QRScannerOverlayView { [weak self] in
            self?.dismiss(animated: true)
            self?.onClose?()
        })
        overlayView.view.backgroundColor = .clear
        addChild(overlayView)
        overlayView.view.frame = self.view.frame
        self.view.addSubview(overlayView.view)
        overlayView.didMove(toParent: self)
        self.view.bringSubviewToFront(overlayView.view)
    }
    
    func setupCamera() {
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        
        do {
            let input = try AVCaptureDeviceInput(device: device)
            
            let output = AVCaptureMetadataOutput()
            
            output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            
            session.addInput(input)
            session.addOutput(output)
            
            output.metadataObjectTypes = [.qr]
            
            let previewLayer = AVCaptureVideoPreviewLayer(session: session)
            previewLayer.videoGravity = .resizeAspectFill
            previewLayer.frame = view.bounds
            
            view.layer.addSublayer(previewLayer)
            
            DispatchQueue.global().async { [weak self] in
                self?.session.startRunning()
            }
            
        } catch {
            result?(.failure(NSError(domain: "Failed to open camera.", code: 1)))
        }
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
        
        guard let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              metadataObject.type == .qr,
              let stringValue = metadataObject.stringValue else {
            result?(.failure(NSError(domain: "Failed to get data", code: 0)))
            return
        }
        result?(.success(stringValue))
        session.stopRunning()
        self.dismiss(animated: true)
    }
}

struct QRScannerOverlayView: View {
    
    @State private var isFlashEnabled = false
    @State var scannerImage = "viewfinder"
    let onClose: (() -> Void)?
    
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                Image(systemName: scannerImage)
                    .resizable()
                    .font(Font.title.weight(.ultraLight))
                    .foregroundStyle(.white)
                    .aspectRatio(1, contentMode: .fit)
                    .padding(.horizontal, 30)
                Spacer()
            }
            VStack {
                HStack {
                    Button("Close") {
                        onClose?()
                    }
                    .foregroundStyle(.white)
                    .font(.system(size: 18))
                    Spacer()
                    Button("", systemImage: "bolt\(isFlashEnabled ? ".slash" : "").fill") {
                        isFlashEnabled.toggle()
                        _ = UIDevice.toggleFlashlight()
                    }
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 16)
                .frame(height: 50)
                .background(Color.black.opacity(0.5))
                Spacer()
            }
        }
        
    }
}

extension UIDevice {
    static func toggleFlashlight() -> String? {
        let device = AVCaptureDevice.default(for: AVMediaType.video)
        if let device, device.hasTorch {
            do {
                try device.lockForConfiguration()
            
            let torchOn = !device.isTorchActive
            try device.setTorchModeOn(level: 1.0)
            device.torchMode = torchOn ? AVCaptureDevice.TorchMode.on : AVCaptureDevice.TorchMode.off
            device.unlockForConfiguration()
            } catch {
                return "Failed to turn on flashlight"
            }
        }
        return nil
    }
}
