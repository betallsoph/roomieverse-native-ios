# RoomieVerse iOS - Setup Guide

## API Integration Status

✅ API models and configuration created
✅ Firebase Manager skeleton implemented
✅ Listing Service with CRUD operations
✅ Authentication Service
✅ Community Service
✅ Image Upload Service

## Next Steps to Complete Integration

### 1. Add Firebase iOS SDK

Add Firebase to your project via Swift Package Manager:

1. Open Xcode project
2. Go to **File > Add Package Dependencies**
3. Enter URL: `https://github.com/firebase/firebase-ios-sdk`
4. Add these products:
   - `FirebaseAuth`
   - `FirebaseFirestore`
   - `FirebaseCore`

### 2. Add GoogleService-Info.plist

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select project: **roomieverse-antt**
3. Add iOS app with bundle ID matching your Xcode project
4. Download `GoogleService-Info.plist`
5. Drag it into Xcode project root (next to `Info.plist`)

### 3. Initialize Firebase in App

Update `roomieverse_iosApp.swift`:

```swift
import SwiftUI
import FirebaseCore

@main
struct roomieverse_iosApp: App {
    @StateObject private var appState = AppState()
    
    init() {
        // Configure Firebase
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(appState)
                .environmentObject(AuthService.shared)
        }
    }
}
```

### 4. Add Google Sign-In SDK (Optional)

For Google OAuth authentication:

1. Add package: `https://github.com/google/GoogleSignIn-iOS`
2. Update `FirebaseManager.signInWithGoogle()` implementation
3. Add URL scheme to Info.plist (get from GoogleService-Info.plist)

### 5. Update FirebaseManager Implementation

Uncomment the Firebase code in:
- `FirebaseManager.swift` - Auth methods
- `FirestoreService.swift` - Database operations

Replace placeholder errors with actual Firebase SDK calls.

### 6. Test with Mock Data

The app currently works with `MockData.swift` as fallback. When Firebase is not configured, it automatically uses mock data.

## API Endpoints

### Firebase Collections
- `listings` - Room/apartment listings
- `users` - User profiles
- `community_posts` - Community forum posts
- `community_comments` - Post comments
- `community_likes` - Like tracking
- `favorites` - User saved listings
- `reports` - Abuse reports

### Custom API Routes (Next.js Backend)
- `POST /api/upload` - Image upload to Cloudflare R2
- `POST /api/auth/promote` - Admin role promotion
- `POST /api/seed` - Seed mock data

## Environment Variables

Update `APIConfig.swift` if needed:

```swift
static let apiBaseURL = "https://roomieverse.vercel.app" // Production
static let r2PublicURL = "https://pub-fe2d599758ec4a498432d6c58ffe03b3.r2.dev"
```

## Firebase Configuration

Project: **roomieverse-antt**
- API Key: `AIzaSyB5XNQbA_hW8FhFUQq-mn29CmiEA15EGfU`
- Auth Domain: `roomieverse-antt.firebaseapp.com`
- Project ID: `roomieverse-antt`

## Features

### Authentication
- Google Sign-In with Firebase Auth
- User profile management
- Admin role checking

### Listings
- Fetch listings by category
- Create/update/delete listings
- Image upload to R2
- View count tracking
- Favorite/unfavorite

### Community
- Fetch posts by category
- Create posts
- View count tracking
- Like/comment (structure ready)

### Real-time Updates
- Firestore listeners can be added for real-time updates
- Use `.snapshotListener()` in Firestore queries

## Testing Without Firebase

The app works without Firebase setup! It will:
1. Try to connect to Firebase
2. Catch errors gracefully
3. Fall back to `MockData.swift`
4. Display mock listings and posts

This allows UI development and testing without backend.

## Security Notes

⚠️ **IMPORTANT**: Never commit sensitive files:
- `GoogleService-Info.plist`
- Firebase private keys
- API secrets

These are already in `.gitignore`.

## Support

For Firebase setup help: https://firebase.google.com/docs/ios/setup
For API questions: Contact backend team or check web project at `/Users/antt/Desktop/dev1/roomieVerse`
