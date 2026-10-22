
import SwiftUI
import AVFoundation

struct ContentView: View {
    @State private var scannedCode: String?
    @State private var showScanner = true
    @State private var cameraDenied = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 22) {
                    Text("QR kodunu çerçevenin içine yerleştir.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    ZStack {
                        if showScanner && !cameraDenied {
                            QRScannerView { code in
                                scannedCode = code
                                showScanner = false
                            }
                            .frame(height: 330)
                            .clipShape(RoundedRectangle(cornerRadius: 24))
                        } else {
                            RoundedRectangle(cornerRadius: 24)
                                .fill(Color.black)
                                .frame(height: 330)
                                .overlay {
                                    VStack(spacing: 12) {
                                        Image(systemName: "camera.fill")
                                            .font(.system(size: 40))
                                        Text(
                                            cameraDenied
                                            ? "Kamera izni gerekli"
                                            : "Tarama duraklatıldı"
                                        )
                                        .font(.headline)
                                    }
                                    .foregroundStyle(.white)
                                }
                        }

                        RoundedRectangle(cornerRadius: 18)
                            .stroke(.green, lineWidth: 3)
                            .frame(width: 220, height: 220)
                            .allowsHitTesting(false)
                    }

                    if let scannedCode {
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Tarama Sonucu", systemImage: "checkmark.circle.fill")
                                .font(.headline)
                                .foregroundStyle(.green)

                            Text(scannedCode)
                                .textSelection(.enabled)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                                .background(.secondary.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 12))

                            HStack {
                                Button {
                                    UIPasteboard.general.string = scannedCode
                                } label: {
                                    Label("Kopyala", systemImage: "doc.on.doc")
                                }
                                .buttonStyle(.bordered)

                                if let url = validURL(from: scannedCode) {
                                    Link(destination: url) {
                                        Label("Bağlantıyı Aç", systemImage: "safari")
                                    }
                                    .buttonStyle(.borderedProminent)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    Button {
                        scannedCode = nil
                        cameraDenied = false
                        checkCameraPermission()
                    } label: {
                        Label(
                            "Yeniden Tara",
                            systemImage: "arrow.clockwise"
                        )
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                }
                .padding()
            }
            .navigationTitle("QRScan")
            .onAppear {
                checkCameraPermission()
            }
        }
    }

    private func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            showScanner = true
            cameraDenied = false

        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    cameraDenied = !granted
                    showScanner = granted
                }
            }

        case .denied, .restricted:
            cameraDenied = true
            showScanner = false

        @unknown default:
            cameraDenied = true
            showScanner = false
        }
    }

    private func validURL(from text: String) -> URL? {
        guard let url = URL(string: text),
              let scheme = url.scheme?.lowercased(),
              ["http", "https"].contains(scheme),
              url.host != nil else {
            return nil
        }

        return url
    }
}

#Preview {
    ContentView()
}
