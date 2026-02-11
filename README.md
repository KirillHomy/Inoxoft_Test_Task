📱 Reddit iOS Client (Test Assignment)

iOS application that displays top posts from Reddit with pagination, offline-first caching, search functionality, and detailed post view.

The project is implemented using UIKit, Clean Architecture, and modern iOS best practices.

⸻

✨ Features

📰 Posts Feed
	•	Fetches Top posts from a selected subreddit
	•	Displays:
	•	Title
	•	Author
	•	Score
	•	Comments count
	•	Preview image (if available)
	•	Smooth scrolling with dynamic cell height

🔄 Pagination
	•	Infinite scroll using Reddit after token
	•	Automatic loading when approaching the bottom of the list
	•	Protection against duplicate requests (inFlight, canLoadMore)

📦 Offline-First Caching
	•	Implemented with Realm
	•	First page is cached with TTL (10 minutes)
	•	Cached data is restored instantly on app launch
	•	Network request is skipped if cached data is still valid
	•	Pagination pages are appended correctly

🔍 Search
	•	Search posts by query within subreddit
	•	Debounced input (prevents excessive network calls)
	•	Independent pagination for search results
	•	Seamless reset to main feed when search is cleared

🖼 Image Loading
	•	Implemented using Kingfisher
	•	Memory + disk caching
	•	Placeholder images
	•	Fade-in animation
	•	Safe handling of invalid or missing image URLs

📄 Post Details Screen
	•	Displays full post information:
	•	Title
	•	Author
	•	Subreddit
	•	Date
	•	Score & comments
	•	Image (if available)
	•	Scrollable layout
	•	Button to open the post directly in Reddit (Safari)

🔄 Pull-to-Refresh
	•	UIRefreshControl on main feed
	•	Reloads first page and updates cache

⸻

🧱 Architecture

The project follows Clean Architecture principles with clear separation of concerns.

View (UIKit)
↓
ViewModel
↓
UseCase
↓
Repository
↓
API Client / Cache (Realm)

Layers:
	•	View: UIViewController, UITableViewCell
	•	ViewModel: State management, pagination logic
	•	UseCase: Business logic (Top posts, Search)
	•	Repository: Data source abstraction (API + Cache)
	•	Domain Models: Pure models used across the app
	•	DTO Mapping: API models mapped to domain models

⸻

🛠 Technologies Used
	•	UIKit
	•	Swift Concurrency (async/await)
	•	Realm – local cache
	•	Kingfisher – image loading & caching
	•	SnapKit – layout
	•	Then – cleaner UI initialization
	•	SafariServices – opening Reddit links

⸻

🧠 Key Design Decisions
	•	Offline-first approach for better UX
	•	No singletons — all dependencies injected
	•	Coordinator pattern for navigation
	•	Safe pagination with request state control
	•	Memory-conscious image handling
	•	Reusable and test-friendly architecture

⸻

🚀 Possible Improvements (Out of Scope)
	•	Unit tests
	•	Background refresh
	•	Multiple subreddit selection
	•	Video playback
	•	SwiftUI version

⸻

📌 Summary

This project demonstrates:
	•	Modern UIKit development
	•	Clean Architecture
	•	Asynchronous networking
	•	Local caching strategy
	•	Scalable and maintainable codebase

![Task](https://github.com/KirillHomy/Inoxoft_Test_Task/blob/main/Test%20assignment%20(iOS).jpg)
