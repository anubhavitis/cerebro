import SwiftUI

struct MarkdownView: View {
    let content: String
    @State private var renderedContent: AttributedString = AttributedString("")

    var body: some View {
        ScrollView {
            Text(renderedContent)
                .textSelection(.enabled)
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .onAppear {
            renderMarkdown()
        }
        .onChange(of: content) { _ in
            renderMarkdown()
        }
    }

    private func renderMarkdown() {
        do {
            renderedContent = try AttributedString(markdown: content)
        } catch {
            renderedContent = AttributedString(
                "Error rendering markdown: \(error.localizedDescription)")
        }
    }
}
