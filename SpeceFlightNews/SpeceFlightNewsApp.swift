import SwiftUI

@main
struct SpeceFlightNewsApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ArticleListView()
            }
        }
    }
}
