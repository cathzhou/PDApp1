import SwiftUI
import os.log

/*#-code-walkthrough(pcv.PhotoCollectionView)*/
struct PhotoCollectionView: View {
/*#-code-walkthrough(pcv.PhotoCollectionView)*/
    /*#-code-walkthrough(pcv.photoCollection)*/
    @ObservedObject var photoCollection : PhotoCollection
    /*#-code-walkthrough(pcv.photoCollection)*/
    
    @Environment(\.displayScale) private var displayScale
        
    private static let itemSpacing = 12.0
    private static let itemCornerRadius = 15.0
    private static let itemSize = CGSize(width: 90, height: 90)
    
    private var imageSize: CGSize {
        return CGSize(width: Self.itemSize.width * min(displayScale, 2), height: Self.itemSize.height * min(displayScale, 2))
    }
    
    /*#-code-walkthrough(pcv.columns)*/
    private let columns = [
        GridItem(.adaptive(minimum: itemSize.width, maximum: itemSize.height), spacing: itemSpacing)
    ]
    /*#-code-walkthrough(pcv.columns)*/
    /*#-code-walkthrough(pcv.belowColumns)*/
    /*#-code-walkthrough(pcv.belowColumns)*/
    
    var body: some View {
        /*#-code-walkthrough(pcv.ScrollView)*/
        ScrollView {
            /*#-code-walkthrough(pcv.LazyVGrid)*/
            LazyVGrid(columns: columns, spacing: Self.itemSpacing) {
                /*#-code-walkthrough(pcv.LazyVGrid)*/
                /*#-code-walkthrough(pcv.ForEach)*/
                ForEach(photoCollection.photoAssets) { asset in
                    /*#-code-walkthrough(pcv.NavigationLink)*/
                    NavigationLink {
                        PhotoView(asset: asset, cache: photoCollection.cache)
                        /*#-code-walkthrough(pcv.NavigationLink)*/
                    } label: {
                        /*#-code-walkthrough(pcv.photoItemView)*/
                        photoItemView(asset: asset)
                        /*#-code-walkthrough(pcv.photoItemView)*/
                    }
                    .buttonStyle(.borderless)
                    .accessibilityLabel(asset.accessibilityLabel)
                }
                /*#-code-walkthrough(pcv.ForEach)*/
            }
            /*#-code-walkthrough(pcv.padding)*/
            .padding([.vertical], Self.itemSpacing)
            /*#-code-walkthrough(pcv.padding)*/
        }
        /*#-code-walkthrough(pcv.ScrollView)*/
        .navigationTitle(photoCollection.albumName ?? "Gallery")
        .navigationBarTitleDisplayMode(.inline)
        .statusBar(hidden: false)
    }
    
    private func photoItemView(asset: PhotoAsset) -> some View {
        PhotoItemView(asset: asset, cache: photoCollection.cache, imageSize: imageSize)
            /*#-code-walkthrough(pcv.photoItemViewFrame)*/
            .frame(width: Self.itemSize.width, height: Self.itemSize.height)
            /*#-code-walkthrough(pcv.photoItemViewFrame)*/
            .clipped()
            .cornerRadius(Self.itemCornerRadius)
            .overlay(alignment: .bottomLeading) {
                if asset.isFavorite {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 1)
                        .font(.callout)
                        .offset(x: 4, y: -4)
                }
            }
            .onAppear {
                Task {
                    await photoCollection.cache.startCaching(for: [asset], targetSize: imageSize)
                }
            }
            .onDisappear {
                Task {
                    await photoCollection.cache.stopCaching(for: [asset], targetSize: imageSize)
                }
            }
    }
}
