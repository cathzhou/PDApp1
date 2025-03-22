import SwiftUI
import Photos

/*#-code-walkthrough(pv.intro)*/
struct PhotoView: View {
/*#-code-walkthrough(pv.intro)*/
    /*#-code-walkthrough(pv.asset)*/
    var asset: PhotoAsset
    /*#-code-walkthrough(pv.asset)*/
    /*#-code-walkthrough(pv.cache)*/
    var cache: CachedImageManager?
    /*#-code-walkthrough(pv.cache)*/
    /*#-code-walkthrough(pv.image)*/
    @State private var image: Image?
    /*#-code-walkthrough(pv.image)*/
    @State private var imageRequestID: PHImageRequestID?
    @Environment(\.dismiss) var dismiss
    private let imageSize = CGSize(width: 1024, height: 1024)
    
    var body: some View {
        Group {
            /*#-code-walkthrough(pv.displayImage)*/
            if let image = image {
                image
                    .resizable()
                    .scaledToFit()
                /*#-code-walkthrough(pv.displayImage)*/
                    .accessibilityLabel(asset.accessibilityLabel)
            } else {
                /*#-code-walkthrough(pv.progressView)*/
                ProgressView()
                /*#-code-walkthrough(pv.progressView)*/
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
        .background(Color.secondary)
        .navigationTitle("Photo")
        .navigationBarTitleDisplayMode(.inline)
        .overlay(alignment: .bottom) {
            buttonsView()
                .offset(x: 0, y: -50)
        }
        /*#-code-walkthrough(pv.task)*/
        .task {
            guard image == nil, let cache = cache else { return }
            /*#-code-walkthrough(pv.requestImage)*/
            imageRequestID = await cache.requestImage(for: asset, targetSize: imageSize) { result in
                /*#-code-walkthrough(pv.resultClosure)*/
                Task {
                    /*#-code-walkthrough(pv.updateImage)*/
                    if let result = result {
                        self.image = result.image
                    }
                    /*#-code-walkthrough(pv.updateImage)*/
                }
                /*#-code-walkthrough(pv.resultClosure)*/
            }
            /*#-code-walkthrough(pv.requestImage)*/
        }
        /*#-code-walkthrough(pv.task)*/
    }
    
    private func buttonsView() -> some View {
        HStack(spacing: 60) {
            
            Button {
                Task {
                    await asset.setIsFavorite(!asset.isFavorite)
                }
            } label: {
                Label("Favorite", systemImage: asset.isFavorite ? "heart.fill" : "heart")
                    .font(.system(size: 24))
            }

            Button {
                Task {
                    await asset.delete()
                    await MainActor.run {
                        dismiss()
                    }
                }
            } label: {
                Label("Delete", systemImage: "trash")
                    .font(.system(size: 24))
            }
        }
        .buttonStyle(.plain)
        .labelStyle(.iconOnly)
        .padding(EdgeInsets(top: 20, leading: 30, bottom: 20, trailing: 30))
        .background(Color.secondary.colorInvert())
        .cornerRadius(15)
    }
}
