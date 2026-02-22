//
//  ProfileView.swift
//  roomieverse-ios
//

import SwiftUI

enum ProfileTab {
    case listings, favorites
}

struct ProfileView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var listingService = ListingService.shared
    @StateObject private var authService = AuthService.shared
    @State private var profileTab: ProfileTab = .listings
    @State private var favoriteListings: [RoomListing] = []
    @State private var userListings: [RoomListing] = []

    var userName: String {
        authService.currentUser?.displayName ?? "User"
    }
    
    var userEmail: String {
        authService.currentUser?.email ?? ""
    }
    
    var userOccupation: String {
        authService.currentUser?.occupation ?? "Chưa cập nhật"
    }
    
    let userBio = "Yêu thích sự gọn gàng, ngăn nắp. Thích nấu ăn và đọc sách. Đang tìm bạn ở ghép tại Sài Gòn."

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Profile header
                    profileHeader

                    // Stats row
                    statsRow
                        .padding(.horizontal, 20)
                        .padding(.top, 20)

                    Divider().padding(.vertical, 20).padding(.horizontal, 20)

                    // Lifestyle tags
                    lifestyleSection
                        .padding(.horizontal, 20)

                    Divider().padding(.vertical, 20).padding(.horizontal, 20)

                    // Listings / Favorites tab switcher
                    contentSection
                        .padding(.horizontal, 20)

                    Divider().padding(.vertical, 20).padding(.horizontal, 20)

                    // Settings menu
                    settingsSection
                        .padding(.horizontal, 20)

                    // Version & branding
                    VStack(spacing: 6) {
                        Image("logo")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 48)
                        Text("Phiên bản 1.0.0")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 30)
                }
            }
            .navigationTitle("Tôi")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .padding(6)
                    }
                    .buttonStyle(.glass)
                }
            }
            .onAppear {
                loadUserData()
            }
        }
    }
    
    private func loadUserData() {
        // Load favorites
        appState.loadFavorites()
        
        Task {
            guard let userId = authService.currentUser?.uid else { return }
            
            // Load user's listings
            let allListings = try? await FirestoreService.shared.fetchListings(category: nil, status: .active)
            let myListings = allListings?.filter { $0.userId == userId } ?? []
            
            await MainActor.run {
                self.userListings = myListings.compactMap { listingService.convertToAppModel($0) }
            }
            
            // Load favorite listings
            let favorites = await listingService.fetchUserFavorites(userId: userId)
            
            await MainActor.run {
                self.favoriteListings = favorites
            }
        }
    }

    // MARK: - Profile Header

    private var profileHeader: some View {
        ZStack(alignment: .bottom) {
            LinearGradient(
                colors: [Color.brandPink.opacity(0.3), Color.roommateColor.opacity(0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: 160)

            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.brandPink.opacity(0.2))
                        .frame(width: 80, height: 80)
                        .overlay {
                            Circle().strokeBorder(.white, lineWidth: 3)
                        }
                    Image(systemName: "person.fill")
                        .font(.system(size: 36))
                        .foregroundStyle(Color.brandPink)
                }
                .shadow(radius: 8)

                VStack(spacing: 4) {
                    Text(userName)
                        .font(.title2.bold())
                    Text(userOccupation)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.bottom, 20)
        }
    }

    // MARK: - Stats

    private var statsRow: some View {
        HStack {
            StatBox(value: "\(appState.favoriteListingIds.count)", label: "Yêu thích", icon: "heart.fill", color: Color.brandPink)
            Divider().frame(height: 40)
            StatBox(value: "2", label: "Bài đăng", icon: "doc.fill", color: .roommateColor)
            Divider().frame(height: 40)
            StatBox(value: "24", label: "Lượt xem", icon: "eye.fill", color: .subleaseColor)
        }
        .padding(.vertical, 16)
        .glassEffect(in: .rect(cornerRadius: 16))
    }

    // MARK: - Lifestyle

    private var lifestyleSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Phong cách sống")
                .font(.headline)

            Text(userBio)
                .font(.body)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    LifestyleTag(icon: "moon.stars.fill", text: "Cú đêm", color: .indigo)
                    LifestyleTag(icon: "sparkles", text: "Sạch sẽ", color: .roommateColor)
                    LifestyleTag(icon: "flame.slash.fill", text: "Không hút thuốc", color: .shortTermColor)
                    LifestyleTag(icon: "cat.fill", text: "OK với mèo", color: Color.brandPink)
                }
            }
        }
    }

    // MARK: - Profile Tab Button

    @ViewBuilder
    private func profileTabButton(tab: ProfileTab, icon: String, label: String, color: Color) -> some View {
        let isActive = profileTab == tab
        Button {
            withAnimation(.spring(response: 0.3)) { profileTab = tab }
        } label: {
            Text(label)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(isActive ? color : Color.secondary)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
        }
        .buttonStyle(isActive
            ? .glass(Glass.regular.tint(color).interactive())
            : .glass(Glass.regular.interactive()))
    }

    // MARK: - Content Section (Listings + Favorites)

    private var contentSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Tab switcher
            GlassEffectContainer(spacing: 4) {
                HStack(spacing: 4) {
                    profileTabButton(
                        tab: .listings,
                        icon: "doc.fill",
                        label: "Bài đăng",
                        color: .roommateColor
                    )
                    profileTabButton(
                        tab: .favorites,
                        icon: "heart.fill",
                        label: "Yêu thích",
                        color: .brandPink
                    )
                }
            }

            // Content
            if profileTab == .listings {
                myListingsContent
            } else {
                favoritesContent
            }
        }
    }

    private var myListingsContent: some View {
        VStack(spacing: 10) {
            if userListings.isEmpty {
                Text("Chưa có bài đăng nào")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 30)
            } else {
                ForEach(userListings) { listing in
                    NavigationLink(destination: ListingDetailView(listing: listing)) {
                        HStack(spacing: 12) {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(listing.category.color.opacity(0.15))
                                .frame(width: 50, height: 50)
                                .overlay {
                                    Image(systemName: listing.category.icon)
                                        .foregroundStyle(listing.category.color)
                                }

                            VStack(alignment: .leading, spacing: 4) {
                                Text(listing.title)
                                    .font(.subheadline.weight(.semibold))
                                    .lineLimit(1)
                                HStack(spacing: 8) {
                                    Text(listing.price.priceFormatted + "/th")
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(listing.category.color)
                                    Label("\(listing.viewCount)", systemImage: "eye")
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                        .padding(12)
                        .glassEffect(in: .rect(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                }
            }

            Button {
                appState.selectedTab = .post
            } label: {
                Text("Đăng tin mới")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.brandPink)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.glass(Glass.regular.tint(Color.brandPink).interactive()))
        }
    }

    private var favoritesContent: some View {
        Group {
            if favoriteListings.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "heart.slash.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(.secondary)
                    Text("Chưa có bài đăng yêu thích")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                VStack(spacing: 10) {
                    ForEach(favoriteListings) { listing in
                        NavigationLink(destination: ListingDetailView(listing: listing)) {
                            HStack(spacing: 12) {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(listing.category.color.opacity(0.15))
                                    .frame(width: 50, height: 50)
                                    .overlay {
                                        Image(systemName: listing.category.icon)
                                            .foregroundStyle(listing.category.color)
                                    }

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(listing.title)
                                        .font(.subheadline.weight(.semibold))
                                        .lineLimit(1)
                                    HStack(spacing: 8) {
                                        Text(listing.price.priceFormatted + "/th")
                                            .font(.caption.weight(.semibold))
                                            .foregroundStyle(listing.category.color)
                                        Text(listing.district)
                                            .font(.caption2)
                                            .foregroundStyle(.secondary)
                                    }
                                }

                                Spacer()

                                Button {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                        appState.toggleFavorite(listingId: listing.id)
                                    }
                                } label: {
                                    Image(systemName: "heart.fill")
                                        .foregroundStyle(Color.brandPink)
                                        .symbolEffect(.bounce, value: appState.isFavorite(listingId: listing.id))
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(12)
                            .glassEffect(in: .rect(cornerRadius: 12))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    // MARK: - Settings Section

    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Cài đặt")
                .font(.headline)
                .padding(.bottom, 14)

            VStack(spacing: 0) {
                SettingsRow(icon: "person.fill", label: "Chỉnh sửa hồ sơ", color: .roommateColor)
                Divider().padding(.leading, 48)
                SettingsRow(icon: "heart.fill", label: "Sở thích sống", color: Color.brandPink)
                Divider().padding(.leading, 48)
                SettingsRow(icon: "bell.fill", label: "Thông báo", color: .shortTermColor)
                Divider().padding(.leading, 48)
                SettingsRow(icon: "lock.fill", label: "Quyền riêng tư", color: .secondary)
                Divider().padding(.leading, 48)
                SettingsRow(icon: "questionmark.circle.fill", label: "Hỗ trợ", color: .subleaseColor)
                Divider().padding(.leading, 48)
                Button {
                    authService.signOut()
                } label: {
                    HStack(spacing: 14) {
                        Image(systemName: "rectangle.portrait.and.arrow.right.fill")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Color.communityDrama)
                            .frame(width: 30, height: 30)
                            .background(Color.communityDrama.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 8))

                        Text("Đăng xuất")
                            .font(.subheadline)
                            .foregroundStyle(.primary)

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
                .buttonStyle(.plain)
            }
            .glassEffect(in: .rect(cornerRadius: 16))
        }
    }
}

// MARK: - Stat Box

struct StatBox: View {
    let value: String
    let label: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .foregroundStyle(color)
                .font(.title3)
            Text(value)
                .font(.title2.bold())
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Lifestyle Tag

struct LifestyleTag: View {
    let icon: String
    let text: String
    let color: Color

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption.weight(.semibold))
                .foregroundStyle(color)
            Text(text)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.primary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 7)
        .glassEffect(.regular.tint(color).interactive(), in: Capsule())
    }
}

// MARK: - Settings Row

struct SettingsRow: View {
    let icon: String
    let label: String
    let color: Color

    var body: some View {
        Button {
        } label: {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(color)
                    .frame(width: 30, height: 30)
                    .background(color.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                Text(label)
                    .font(.subheadline)
                    .foregroundStyle(.primary)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ProfileView()
        .environmentObject(AppState())
}
