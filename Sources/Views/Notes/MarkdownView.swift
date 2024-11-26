import MarkdownUI
import SwiftUI

struct MarkdownView: View {
    let content: String

    var body: some View {
        ScrollView {
            Markdown(content)
                .textSelection(.enabled)
                .markdownTheme(.gitHub)  // Optional: use a predefined theme
                .padding()  
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
    }
}
