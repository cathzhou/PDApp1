import SwiftUI

/*#-code-walkthrough(vfv.intro)*/
struct ViewfinderView: View {
/*#-code-walkthrough(vfv.intro)*/
    /*#-code-walkthrough(vfv.image)*/
    @Binding var image: Image?
    /*#-code-walkthrough(vfv.image)*/
    
    var body: some View {
        GeometryReader { geometry in
            if let image = image {
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
    }
}

struct ViewfinderView_Previews: PreviewProvider {
    static var previews: some View {
        ViewfinderView(image: .constant(Image(systemName: "pencil")))
    }
}
