import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

struct AddEvidenceView: View {
    @StateObject private var viewModel: AddEvidenceViewModel
    @State private var isPresenting = false
    @State private var selectedType: PickerType?
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    Button {
                        selectedType = .photo
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            isPresenting = true
                        }
                    } label: {
                        Label("Upload Photos", systemImage: "photo")
                    }
                    
                    Button {
                        selectedType = .video
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            isPresenting = true
                        }
                    } label: {
                        Label("Upload Videos", systemImage: "video")
                    }
                    
                    Button {
                        selectedType = .document
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            isPresenting = true
                        }
                    } label: {
                        Label("Upload Documents", systemImage: "doc")
                    }
                }
            }
            .navigationTitle("Add Evidence")
        }
        .onChange(of: isPresenting) { presenting in
            if presenting, let type = selectedType {
                showPicker(type)
            }
        }
    }
    
    private func showPicker(_ type: PickerType) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let topVC = windowScene.windows.first?.rootViewController?.topMostViewController else {
            return
        }
        
        switch type {
        case .photo:
            var config = PHPickerConfiguration()
            config.filter = .images
            let picker = PHPickerViewController(configuration: config)
            picker.delegate = PhotoDelegate.shared
            PhotoDelegate.shared.onSelect = { image in
                viewModel.handleSelectedPhoto(image)
                isPresenting = false
            }
            topVC.present(picker, animated: true)
            
        case .video:
            let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.movie])
            picker.delegate = DocumentDelegate.shared
            DocumentDelegate.shared.onSelect = { urls in
                viewModel.handleSelectedVideos(urls)
                isPresenting = false
            }
            topVC.present(picker, animated: true)
            
        case .document:
            let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.pdf, .text])
            picker.delegate = DocumentDelegate.shared
            DocumentDelegate.shared.onSelect = { urls in
                viewModel.handleSelectedDocuments(urls)
                isPresenting = false
            }
            topVC.present(picker, animated: true)
        }
    }
}

// Helper extension to find top view controller
extension UIViewController {
    var topMostViewController: UIViewController {
        if let presented = presentedViewController {
            return presented.topMostViewController
        }
        return self
    }
}

private enum PickerType {
    case photo, video, document
}

private class PhotoDelegate: NSObject, PHPickerViewControllerDelegate {
    static let shared = PhotoDelegate()
    var onSelect: ((UIImage) -> Void)?
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        results.first?.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, _ in
            if let image = image as? UIImage {
                DispatchQueue.main.async {
                    self?.onSelect?(image)
                }
            }
        }
        picker.dismiss(animated: true)
    }
}

private class DocumentDelegate: NSObject, UIDocumentPickerDelegate {
    static let shared = DocumentDelegate()
    var onSelect: (([URL]) -> Void)?
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        onSelect?(urls)
        controller.dismiss(animated: true)
    }
} 