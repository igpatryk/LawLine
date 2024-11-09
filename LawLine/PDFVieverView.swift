import SwiftUI
import PDFKit

struct PDFViewerView: View {
    let pdfURL: URL
    @StateObject private var searchController = PDFSearchController()
    @State private var showSearchBar = false
    @State private var searchText = ""
    
    var body: some View {
        ZStack(alignment: .bottom) {
            PDFKitRepresentedView(pdfURL, searchController: searchController)
            
            if showSearchBar {
                searchView
                    .transition(.move(edge: .bottom))
            }
        }
        .overlay(
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        withAnimation {
                            showSearchBar.toggle()
                            if !showSearchBar {
                                searchController.clearSearch()
                                searchText = ""
                            }
                        }
                    }) {
                        Image(systemName: showSearchBar ? "xmark.circle.fill" : "magnifyingglass")
                            .font(.system(size: 22))
                            .foregroundColor(.blue)
                    }
                    .padding()
                }
                Spacer()
            }
        )
    }
    
    private var searchView: some View {
        VStack(spacing: 0) {
            HStack {
                TextField("Wyszukaj w dokumencie...", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onChange(of: searchText) { newValue in
                        searchController.search(for: newValue)
                    }
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchController.findNext()
                    }) {
                        Image(systemName: "arrow.down.circle.fill")
                            .foregroundColor(.blue)
                    }
                    
                    Button(action: {
                        searchController.findPrevious()
                    }) {
                        Image(systemName: "arrow.up.circle.fill")
                            .foregroundColor(.blue)
                    }
                }
            }
            .padding()
            .background(Color(.systemBackground))
            
            if let selection = searchController.currentSelection {
                Text("\(selection.current) z \(selection.total)")
                    .font(.caption)
                    .padding(.bottom, 8)
                    .foregroundColor(.secondary)
            }
        }
        .background(Color(.systemBackground).shadow(radius: 2))
    }
}

class PDFSearchController: ObservableObject {
    @Published var currentSelection: (current: Int, total: Int)?
    
    private var pdfView: PDFView?
    private var searchResults: [PDFSelection] = []
    private var currentSelectionIndex = 0
    
    func setPDFView(_ view: PDFView) {
        self.pdfView = view
    }
    
    func search(for text: String) {
        guard let pdfView = pdfView, let document = pdfView.document else { return }
        
        // Clear previous search
        clearSearch()
        
        if text.isEmpty { return }
        
        // Perform new search
        searchResults = document.findString(text, withOptions: .caseInsensitive)
        
        if !searchResults.isEmpty {
            currentSelectionIndex = 0
            highlightCurrentSelection()
            updateSelectionCount()
        }
    }
    
    func findNext() {
        guard !searchResults.isEmpty else { return }
        currentSelectionIndex = (currentSelectionIndex + 1) % searchResults.count
        highlightCurrentSelection()
        updateSelectionCount()
    }
    
    func findPrevious() {
        guard !searchResults.isEmpty else { return }
        currentSelectionIndex = currentSelectionIndex > 0 ? currentSelectionIndex - 1 : searchResults.count - 1
        highlightCurrentSelection()
        updateSelectionCount()
    }
    
    func clearSearch() {
        searchResults.removeAll()
        currentSelectionIndex = 0
        currentSelection = nil
        pdfView?.clearSelection()
    }
    
    private func highlightCurrentSelection() {
        guard !searchResults.isEmpty else { return }
        let selection = searchResults[currentSelectionIndex]
        pdfView?.setCurrentSelection(selection, animate: true)
        pdfView?.currentSelection?.color = .yellow
        
        // Scroll to the selection
        if let page = selection.pages.first {
            pdfView?.go(to: selection.bounds(for: page), on: page)
        }
    }
    
    private func updateSelectionCount() {
        currentSelection = (currentSelectionIndex + 1, searchResults.count)
    }
}

struct PDFKitRepresentedView: UIViewRepresentable {
    let url: URL
    let searchController: PDFSearchController
    
    init(_ url: URL, searchController: PDFSearchController) {
        self.url = url
        self.searchController = searchController
    }
    
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = PDFDocument(url: url)
        pdfView.autoScales = true
        searchController.setPDFView(pdfView)
        return pdfView
    }
    
    func updateUIView(_ uiView: PDFView, context: Context) {
        // No update needed
    }
}
