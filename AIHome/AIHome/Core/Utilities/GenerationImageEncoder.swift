import UIKit

enum GenerationImageEncoder {
    static func encode(
        _ image: UIImage,
        compressionQuality: CGFloat = 0.8,
        filename: String = "image"
    ) -> HomeDesignsImageSource? {
        if let jpegData = jpegData(image, compressionQuality: compressionQuality) {
            return .jpegData(jpegData, filename: "\(filename).jpg")
        }

        guard image.size.width > 0, image.size.height > 0 else { return nil }
        let uploadImage = image.renderedInStandardRange() ?? image
        if let pngData = uploadImage.pngData() ?? image.pngData() {
            return .pngData(pngData, filename: "\(filename).png")
        }

        return nil
    }

    static func jpegData(
        _ image: UIImage,
        compressionQuality: CGFloat
    ) -> Data? {
        guard image.size.width > 0, image.size.height > 0 else { return nil }

        let standardRangeImage = image.renderedInStandardRange() ?? image
        return standardRangeImage.jpegData(compressionQuality: compressionQuality)
    }
}

private extension UIImage {
    func renderedInStandardRange() -> UIImage? {
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = scale
        format.opaque = true
        format.preferredRange = .standard

        return UIGraphicsImageRenderer(size: size, format: format).image { context in
            context.cgContext.setFillColor(UIColor.white.cgColor)
            context.cgContext.fill(CGRect(origin: .zero, size: size))
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
