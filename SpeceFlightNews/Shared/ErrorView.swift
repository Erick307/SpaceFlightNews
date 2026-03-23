import SwiftUI

struct ErrorView: View {

    let message: String
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 52))
                .foregroundColor(.orange)

            Text("Something went wrong")
                .font(.headline)

            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Button(action: onRetry) {
                Label("Try Again", systemImage: "arrow.clockwise")
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

#Preview {
    ErrorView(message: "The server returned an error (HTTP 503).") { }
}
