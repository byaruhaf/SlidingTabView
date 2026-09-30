import SwiftUI
import SlidingTabView

@available(iOS 15.0, macOS 12.0, *)
struct TestTruncationFix: View {
    @State private var selectedTab = 0

    var body: some View {
        VStack {
            Text("Fixed Tab Layout (Default)")
            SlidingTabView(
                selection: $selectedTab,
                tabs: ["Articles", "Highlights", "Notes", "Summaries"],
                activeAccentColor: .red,
                selectionBarColor: .red
            ) {
                Text("Articles Content")
                Text("Highlights Content")
                Text("Notes Content")
                Text("Summaries Content")
            }

            Divider()
                .padding()

            Text("Dynamic Width Layout (Recommended)")
            SlidingTabView(
                selection: $selectedTab,
                tabs: ["Articles", "Highlights", "Notes", "Summaries"],
                activeAccentColor: .red,
                selectionBarColor: .red,
                allowDynamicTabWidth: true // This allows tabs to size based on content
            ) {
                Text("Articles Content")
                Text("Highlights Content")
                Text("Notes Content")
                Text("Summaries Content")
            }

            Divider()
                .padding()

            Text("Scrollable Layout (For Many Tabs)")
            SlidingTabView(
                selection: $selectedTab,
                tabs: ["Articles", "Highlights", "Notes", "Summaries"],
                activeAccentColor: .red,
                selectionBarColor: .red,
                isScrollable: true
            ) {
                Text("Articles Content")
                Text("Highlights Content")
                Text("Notes Content")
                Text("Summaries Content")
            }
        }
        .padding()
    }
}

#Preview {
    TestTruncationFix()
}