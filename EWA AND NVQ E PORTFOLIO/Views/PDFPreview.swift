import SwiftUI
import PDFKit

struct PDFPreview: View {
    let url: URL
    
    var body: some View {
        PDFKitView(url: url)
    }
}

struct PDFKitView: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        return pdfView
    }
    
    func updateUIView(_ pdfView: PDFView, context: Context) {
        if let document = PDFDocument(url: url) {
            pdfView.document = document
            pdfView.autoScales = true
            pdfView.displayMode = .singlePage
        }
    }
} 