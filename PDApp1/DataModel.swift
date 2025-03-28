import AVFoundation
import SwiftUI
import os.log

/*#-code-walkthrough(dm.observableObject)*/
final class DataModel: ObservableObject {
    /*#-code-walkthrough(dm.observableObject)*/
    /*#-code-walkthrough(dm.camera)*/
    let camera = Camera()
    /*#-code-walkthrough(dm.camera)*/
    /*#-code-walkthrough(dm.photoCollection)*/
    let photoCollection = PhotoCollection(smartAlbum: .smartAlbumUserLibrary)
    /*#-code-walkthrough(dm.photoCollection)*/
    
    /*#-code-walkthrough(dm.viewfinderImage)*/
    /*#-code-walkthrough(dm.published)*/@Published/*#-code-walkthrough(dm.published)*/ var viewfinderImage: Image?
    /*#-code-walkthrough(dm.viewfinderImage)*/
    /*#-code-walkthrough(dm.thumbnailImage)*/
    @Published var thumbnailImage: Image?
    /*#-code-walkthrough(dm.thumbnailImage)*/
    
    var isPhotosLoaded = false
    
    init() {
        /*#-code-walkthrough(previewflow.taskHandlePreviews)*/
        Task {
            await handleCameraPreviews()
        }
        /*#-code-walkthrough(previewflow.taskHandlePreviews)*/
        
        /*#-code-walkthrough(photoflow.taskHandlePhotos)*/
        Task {
            await handleCameraPhotos()
        }
        /*#-code-walkthrough(photoflow.taskHandlePhotos)*/
    }
    
    /*#-code-walkthrough(previewflow.handleCameraPreviews)*/
    func handleCameraPreviews() async {
        /*#-code-walkthrough(previewflow.imageStream)*/
        let imageStream = camera.previewStream
        /*#-code-walkthrough(previewflow.handleCameraPreviews)*/
            /*#-code-walkthrough(previewflow.map)*/
            .map { $0.image }
        /*#-code-walkthrough(previewflow.imageStream)*/
            /*#-code-walkthrough(previewflow.map)*/

        /*#-code-walkthrough(previewflow.forAwait)*/
        for await image in imageStream {
            Task { @MainActor in
                /*#-code-walkthrough(previewflow.updateViewfinderImage)*/
                viewfinderImage = image
                /*#-code-walkthrough(previewflow.updateViewfinderImage)*/
            }
        }
        /*#-code-walkthrough(previewflow.forAwait)*/
    }
    
    /*#-code-walkthrough(photoflow.unpackedPhotoStream)*/
    func handleCameraPhotos() async {
        let unpackedPhotoStream = camera.photoStream
        /*#-code-walkthrough(photoflow.unpackedPhotoStream)*/
            /*#-code-walkthrough(photoflow.compactMap)*/
            .compactMap { self.unpackPhoto($0) }
            /*#-code-walkthrough(photoflow.compactMap)*/
        
        /*#-code-walkthrough(photoflow.forAwait)*/
        for await photoData in unpackedPhotoStream {
            Task { @MainActor in
                /*#-code-walkthrough(photoflow.updateThumbnailImage)*/
                thumbnailImage = photoData.thumbnailImage
                /*#-code-walkthrough(photoflow.updateThumbnailImage)*/
            }
            /*#-code-walkthrough(photoflow.callSavePhoto)*/
            savePhoto(imageData: photoData.imageData)
            /*#-code-walkthrough(photoflow.callSavePhoto)*/
        }
        /*#-code-walkthrough(photoflow.forAwait)*/
    }
    
    /*#-code-walkthrough(photoflow.unpackPhoto)*/
    private func unpackPhoto(_ photo: AVCapturePhoto) -> PhotoData? {
        /*#-code-walkthrough(photoflow.unpackPhoto)*/
        guard let imageData = photo.fileDataRepresentation() else { return nil }

        guard let previewCGImage = photo.previewCGImageRepresentation(),
           let metadataOrientation = photo.metadata[String(kCGImagePropertyOrientation)] as? UInt32,
              let cgImageOrientation = CGImagePropertyOrientation(rawValue: metadataOrientation) else { return nil }
        let imageOrientation = Image.Orientation(cgImageOrientation)
        let thumbnailImage = Image(decorative: previewCGImage, scale: 1, orientation: imageOrientation)
        
        let photoDimensions = photo.resolvedSettings.photoDimensions
        let imageSize = (width: Int(photoDimensions.width), height: Int(photoDimensions.height))
        let previewDimensions = photo.resolvedSettings.previewDimensions
        let thumbnailSize = (width: Int(previewDimensions.width), height: Int(previewDimensions.height))
        
        return PhotoData(thumbnailImage: thumbnailImage, thumbnailSize: thumbnailSize, imageData: imageData, imageSize: imageSize)
    }
    
    /*#-code-walkthrough(photoflow.savePhoto)*/
    func savePhoto(imageData: Data) {
        Task {
            do {
                try await photoCollection.addImage(imageData)
                logger.debug("Added image data to photo collection.")
            } catch let error {
                logger.error("Failed to add image to photo collection: \(error.localizedDescription)")
            }
        }
    }
    /*#-code-walkthrough(photoflow.savePhoto)*/
    
    func loadPhotos() async {
        guard !isPhotosLoaded else { return }
        
        let authorized = await PhotoLibrary.checkAuthorization()
        guard authorized else {
            logger.error("Photo library access was not authorized.")
            return
        }
        
        do {
            try await self.photoCollection.load()
            isPhotosLoaded = true
        } catch let error {
            logger.error("Failed to load photo collection: \(error.localizedDescription)")
        }
    }
    
    func loadThumbnail() async {
        guard let asset = photoCollection.photoAssets.first  else { return }
        await photoCollection.cache.requestImage(for: asset, targetSize: CGSize(width: 256, height: 256))  { result in
            if let result = result {
                Task { @MainActor in
                    self.thumbnailImage = result.image
                }
            }
        }
    }
}

fileprivate struct PhotoData {
    var thumbnailImage: Image
    var thumbnailSize: (width: Int, height: Int)
    var imageData: Data
    var imageSize: (width: Int, height: Int)
}

fileprivate extension CIImage {
    var image: Image? {
        let ciContext = CIContext()
        guard let cgImage = ciContext.createCGImage(self, from: self.extent) else { return nil }
        return Image(decorative: cgImage, scale: 1, orientation: .up)
    }
}

fileprivate extension Image.Orientation {

    init(_ cgImageOrientation: CGImagePropertyOrientation) {
        switch cgImageOrientation {
        case .up: self = .up
        case .upMirrored: self = .upMirrored
        case .down: self = .down
        case .downMirrored: self = .downMirrored
        case .left: self = .left
        case .leftMirrored: self = .leftMirrored
        case .right: self = .right
        case .rightMirrored: self = .rightMirrored
        }
    }
}

fileprivate let logger = Logger(subsystem: "com.apple.swiftplaygroundscontent.capturingphotos", category: "DataModel")
