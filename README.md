# SpeceFlightNews 🚀

An iOS app built with **SwiftUI** that lets users browse and search space flight news articles, powered by the [Spaceflight News API](https://api.spaceflightnewsapi.net/v4/docs/).

---

## Features

- **Article List** — Browse the latest space flight news with infinite scroll pagination
- **Search** — Real-time article search with debouncing (500 ms) to avoid redundant requests
- **Article Detail** — Full article view with hero image, summary, publication date, and a "Read Full Article" button that opens the original source in Safari
- **Share** — Native share sheet to share article links directly from the detail screen
- **Pull to Refresh** — Reload articles on both the list and detail screens
- **Empty & Error States** — Dedicated views for loading failures, empty search results, and no content
- **Rotation Support** — All screens adapt correctly to portrait and landscape orientations

---

## Architecture

The project follows the **MVI (Model–View–Intent)** pattern, keeping state management unidirectional and predictable.

```
┌──────────┐   Intent   ┌───────────┐   async   ┌────────────┐
│   View   │ ─────────► │ ViewModel │ ─────────► │ Repository │
│ (SwiftUI)│            │           │            │  (Network) │
│          │ ◄───────── │           │            │            │
└──────────┘   State    └───────────┘            └────────────┘
```

| Layer | Role |
|---|---|
| **State** | Immutable `struct` — single source of truth for the UI |
| **Intent** | `enum` — all possible user actions |
| **ViewModel** | `@MainActor ObservableObject` — handles intents, calls repository, publishes new state |
| **Repository** | Abstracts data access behind a protocol; concrete impl calls `NetworkClient` |
| **NetworkClient** | Thin `URLSession` wrapper with logging via `OSLog` |

---

## API

The app consumes the public **Spaceflight News API v4**:

| Endpoint | Usage |
|---|---|
| `GET /v4/articles/?limit=20&offset=N` | Paginated article list |
| `GET /v4/articles/?search=query` | Search articles by keyword |
| `GET /v4/articles/{id}/` | Single article detail |

`NetworkClient` handles ISO 8601 date decoding (with and without fractional seconds), HTTP status validation, and structured error mapping via `NetworkError`.

---

## Error Handling

**Developer-facing:**
- All errors are mapped to typed `NetworkError` cases (`invalidURL`, `serverError`, `decodingError`, `unknown`)
- `OSLog` is used throughout (`NetworkClient`, `ArticleRepository`, ViewModels) for structured, category-based logging

**User-facing:**
- Full-screen `ErrorView` with a retry button when the initial load fails
- Inline error banner on the detail screen when a background refresh fails (without losing the cached article)
- Empty state views distinguish between "no search results" and "no content available"

---

## Testing

Unit tests are written using **Swift Testing** (`@Test`, `@Suite`) and cover the `ArticleListViewModel` and `ArticleDetailViewModel` through a `MockArticleRepository`.

**ArticleList coverage:**
- Initial state is idle and empty
- Successful load populates articles and updates `hasMore`
- Failed load surfaces an error message
- `loadMore` appends the next page and stops when `hasMore` is false
- `search` debounces, resets results, and passes the correct query to the repository
- `clearSearch` resets the query and reloads without a search term
- Duplicate concurrent `loadArticles` calls are suppressed

Run tests in Xcode with `⌘U` or via:

```bash
xcodebuild test -scheme SpeceFlightNews -destination 'platform=iOS Simulator,name=iPhone 16'
```

---

## Getting Started

1. Clone the repository
2. Open `SpeceFlightNews.xcodeproj` in Xcode
3. Select a simulator or device running iOS 17+
4. Press `⌘R` to build and run

No API keys or additional setup required — the Spaceflight News API is open and public.
