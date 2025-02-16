import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

// First, define the ViewModel if not already defined elsewhere
class AddEvidenceViewModel: ObservableObject {
    func handleSelectedPhoto(_ image: UIImage) {
        // Implementation should exist
    }
    
    func handleSelectedVideos(_ urls: [URL]) {
        // Implementation should exist
    }
    
    func handleSelectedDocuments(_ urls: [URL]) {
        // Implementation should exist
    }
}

struct AddEvidenceView: View {
    @StateObject private var viewModel: AddEvidenceViewModel
    @State private var isPresenting = false
    @State private var selectedType: PickerType?
    
    init(viewModel: AddEvidenceViewModel = AddEvidenceViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    Button {
                        selectedType = .photo
                        showPicker(.photo)
                    } label: {
                        Label("Upload Photos", systemImage: "photo")
                    }
                    
                    Button {
                        selectedType = .video
                        showPicker(.video)
                    } label: {
                        Label("Upload Videos", systemImage: "video")
                    }
                    
                    Button {
                        selectedType = .document
                        showPicker(.document)
                    } label: {
                        Label("Upload Documents", systemImage: "doc")
                    }
                }
            }
            .navigationTitle("Add Evidence")
        }
    }
    
    private func showPicker(_ type: PickerType) {
        DispatchQueue.main.async {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let topVC = windowScene.windows.first?.rootViewController?.topMostViewController else {
                return
            }
            
            if let presented = topVC.presentedViewController {
                presented.dismiss(animated: true) {
                    self.presentPicker(type, on: topVC)
                }
            } else {
                self.presentPicker(type, on: topVC)
            }
        }
    }
    
    private func presentPicker(_ type: PickerType, on viewController: UIViewController) {
        switch type {
        case .photo:
            var config = PHPickerConfiguration()
            config.filter = .images
            config.selectionLimit = 5
            let picker = PHPickerViewController(configuration: config)
            picker.delegate = PhotoDelegate.shared
            PhotoDelegate.shared.onSelect = { [weak self] image in
                self?.viewModel.handleSelectedPhoto(image)
                self?.isPresenting = false
            }
            viewController.present(picker, animated: true)
            
        case .video:
            let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.movie])
            picker.delegate = DocumentDelegate.shared
            DocumentDelegate.shared.onSelect = { [weak self] urls in
                self?.viewModel.handleSelectedVideos(urls)
                self?.isPresenting = false
            }
            viewController.present(picker, animated: true)
            
        case .document:
            let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.pdf, .text])
            picker.delegate = DocumentDelegate.shared
            DocumentDelegate.shared.onSelect = { [weak self] urls in
                self?.viewModel.handleSelectedDocuments(urls)
                self?.isPresenting = false
            }
            viewController.present(picker, animated: true)
        }
    }
}

private enum PickerType {
    case photo, video, document
}

private class PhotoDelegate: NSObject, PHPickerViewControllerDelegate {
    static let shared = PhotoDelegate()
    var onSelect: ((UIImage) -> Void)?
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        results.first?.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, _ in
            if let image = image as? UIImage {
                DispatchQueue.main.async {
                    self?.onSelect?(image)
                }
            }
        }
    }
}

private class DocumentDelegate: NSObject, UIDocumentPickerDelegate {
    static let shared = DocumentDelegate()
    var onSelect: (([URL]) -> Void)?
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        controller.dismiss(animated: true)
        self.onSelect?(urls)
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true)
    }
}

extension UIViewController {
    var topMostViewController: UIViewController {
        if let presented = presentedViewController {
            return presented.topMostViewController
        }
        return self
    }
} 