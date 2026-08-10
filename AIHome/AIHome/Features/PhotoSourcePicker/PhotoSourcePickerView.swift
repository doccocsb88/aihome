import SwiftUI
import PhotosUI
import UIKit

struct PhotoSourcePickerView: View {
    @Bindable var viewModel: PhotoSourcePickerViewModel
    var hideCTA: Bool = false
    var onContinue: ((UIImage) -> Void)?
    @State private var isShowingCameraUnavailableAlert = false
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                if !viewModel.title.isEmpty {
                    Text(viewModel.title)
                        .font(FontFamily.Roboto.bold.swiftUIFont(size: 24))
                        .foregroundColor(.DesignSystem.textPrimary)
                }
                
                if let subtitle = viewModel.subtitle, !subtitle.isEmpty {
                    Text(subtitle)
                        .font(FontFamily.Roboto.regular.swiftUIFont(size: 15))
                        .foregroundColor(.gray)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
            
            if let selectedImage = viewModel.selectedImage {
                PhotoSelectedImagePreviewView(
                    image: selectedImage,
                    onRemove: {
                        viewModel.selectedImage = nil
                    }
                )
            } else {
                VStack(spacing: 24) {
                    VStack(spacing: 12) {
                        Image("ic_picker_image")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 52, height: 51)
                        
                        Text(L10n.PhotoSource.instruction)
                            .font(FontFamily.Inter24pt.regular.swiftUIFont(size: 14))
                            .foregroundColor(Color.DesignSystem.coolGray)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 16)
                    
                    VStack(spacing: 16) {
                        PhotosPicker(selection: $viewModel.imageSelection, matching: .images) {
                            HStack {
                                Image("ic_picker_gallery")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 16, height: 16)
                                Text(L10n.PhotoSource.gallery)
                                    .font(FontFamily.Inter24pt.semiBold.swiftUIFont(size: 15))
                                    .foregroundColor(.white)

                            }
                            .foregroundColor(.DesignSystem.background)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.DesignSystem.textPrimary)
                            .cornerRadius(12)
                        }
                        
                        Button(action: {
                            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                                viewModel.showCamera = true
                            } else {
                                isShowingCameraUnavailableAlert = true
                            }
                        }) {
                            HStack {
                                Image("ic_picker_camera")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 16, height: 16)
                                Text(L10n.PhotoSource.camera)
                                    .font(FontFamily.Inter24pt.semiBold.swiftUIFont(size: 15))
                                    .foregroundColor(.DesignSystem.slateGray)
                            }
                            .foregroundColor(.DesignSystem.textPrimary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.DesignSystem.background)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.DesignSystem.platinum, lineWidth: 1)
                            )
                        }
                    }
                }
                .padding(24)
                .background(Color.DesignSystem.background)
                .cornerRadius(24)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(style: StrokeStyle(lineWidth: 1, dash: [6]))
                        .foregroundColor(Color.gray.opacity(0.3))
                )
                .padding(.horizontal, 24)
            }
            
            if !hideCTA {
                Spacer()

                InteriorCTAButton(
                    title: viewModel.ctaTitle,
                    isEnabled: viewModel.canContinue,
                    action: {
                        if let image = viewModel.selectedImage {
                            onContinue?(image)
                        }
                    }
                )
                .padding(.horizontal, 32)
                .padding(.bottom, 36)
            }
        }
        .fullScreenCover(isPresented: $viewModel.showCamera) {
            CameraPickerView { image in
                viewModel.selectedImage = image
                viewModel.onSourceSelected?(.camera)
            }
            .ignoresSafeArea()
        }
        .alert(L10n.PhotoSource.CameraUnavailable.title, isPresented: $isShowingCameraUnavailableAlert) {
            Button(L10n.Common.ok, role: .cancel) {}
        } message: {
            Text(L10n.PhotoSource.CameraUnavailable.message)
        }
    }
}

private struct CameraPickerView: UIViewControllerRepresentable {
    @Environment(\.dismiss) private var dismiss
    let onImagePicked: (UIImage) -> Void

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        picker.allowsEditing = false
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    final class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        private let parent: CameraPickerView

        init(parent: CameraPickerView) {
            self.parent = parent
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            if let image = info[.originalImage] as? UIImage {
                parent.onImagePicked(image)
            }
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}
