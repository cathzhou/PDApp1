import SwiftUI
import Vision

struct CameraView: View {
    @StateObject private var model = DataModel()
    @State private var showingCapturedImage = false
    @State private var capturedImage: UIImage?

    private static let barHeightFactor = 0.15

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                if showingCapturedImage, let image = capturedImage {
                    VStack {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: geometry.size.height * (1 - (Self.barHeightFactor * 2)))
                            .background(Color.black)
                        
                        HStack(spacing: 60) {
                            Button("Retake") {
                                showingCapturedImage = false
                                capturedImage = nil
                            }
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                            
                            Button("Use Scan") {
                                if let image = capturedImage {
                                    recognizeText(from: image)
                                }
                            }
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        }
                        .padding(.bottom, 20)
                    }
                } else {
                    ViewfinderView(image: $model.viewfinderImage)
                        .overlay(alignment: .top) {
                            Color.black
                                .opacity(0.75)
                                .frame(height: geometry.size.height * Self.barHeightFactor)
                        }
                        .overlay(alignment: .bottom) {
                            buttonsView()
                                .frame(height: geometry.size.height * Self.barHeightFactor)
                                .background(.black.opacity(0.75))
                        }
                        .overlay(alignment: .center) {
                            Color.clear
                                .frame(height: geometry.size.height * (1 - (Self.barHeightFactor * 2)))
                                .accessibilityElement()
                                .accessibilityLabel("View Finder")
                                .accessibilityAddTraits([.isImage])
                        }
                        .background(.black)
                }
            }
            .task {
                await model.camera.start()
                await model.loadPhotos()
                await model.loadThumbnail()
            }
            .navigationTitle("Camera")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarHidden(true)
            .ignoresSafeArea()
            .statusBar(hidden: true)
        }
    }

    private func buttonsView() -> some View {
        HStack(spacing: 60) {
            Spacer()
            
            NavigationLink(destination: PhotoCollectionView(photoCollection: model.photoCollection)
                .onAppear {
                    model.camera.isPreviewPaused = true
                }
                .onDisappear {
                    model.camera.isPreviewPaused = false
                }
            ) {
                Label {
                    Text("Gallery")
                } icon: {
                    ThumbnailView(image: model.thumbnailImage)
                }
            }
            
            Button(action: {
                model.camera.takePhoto { image in
                    capturedImage = image
                    showingCapturedImage = true
                }
            }) {
                Text("Scan")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            
            Button(action: {
                model.camera.switchCaptureDevice()
            }) {
                Label("Switch Camera", systemImage: "arrow.triangle.2.circlepath")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Spacer()
        }
        .buttonStyle(.plain)
        .labelStyle(.iconOnly)
        .padding()
    }

    private func recognizeText(from image: UIImage) {
        guard let cgImage = image.cgImage else { return }
        let request = VNRecognizeTextRequest { request, error in
            guard let observations = request.results as? [VNRecognizedTextObservation], error == nil else { return }
            
            let extractedText = observations.compactMap { $0.topCandidates(1).first?.string }.joined(separator: "\n")
            
            print("Extracted Text: \(extractedText)")
            UserDefaults.standard.set(extractedText, forKey: "extractedText")
        }
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        try? handler.perform([request])
    }
}