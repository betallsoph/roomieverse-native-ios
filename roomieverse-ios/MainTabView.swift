//
//  MainTabView.swift
//  roomieverse-ios
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        TabView(selection: $appState.selectedTab) {
            Tab("Trang chủ", systemImage: "house", value: AppTab.home) {
                HomeView()
            }

            Tab("Cộng đồng", systemImage: "bubble.left.and.bubble.right", value: AppTab.community) {
                CommunityView()
            }

            Tab("Tôi", systemImage: "person", value: AppTab.profile) {
                ProfileView()
            }

            Tab("Đăng tin", systemImage: "plus.circle.fill", value: AppTab.post) {
                PostTypePickerView()
            }
            .tabPlacement(.pinned)

            Tab(value: AppTab.search, role: .search) {
                SearchView()
            }
        }
        .tabBarMinimizeBehavior(.onScrollDown)
        .tint(Color.brandPink)
    }
}

// MARK: - Search View

struct SearchView: View {
    @EnvironmentObject var appState: AppState
    @State private var searchText = ""
    @State private var selectedCategory: ListingCategory? = nil

    var filteredListings: [RoomListing] {
        var result = MockData.listings
        if let cat = selectedCategory {
            result = result.filter { $0.category == cat }
        }
        if !searchText.isEmpty {
            result = result.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.location.localizedCaseInsensitiveContains(searchText) ||
                $0.district.localizedCaseInsensitiveContains(searchText)
            }
        }
        return result
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            CategoryChip(title: "Tất cả", icon: "square.grid.2x2.fill", color: .gray, isSelected: selectedCategory == nil) {
                                withAnimation(.spring(response: 0.3)) { selectedCategory = nil }
                            }
                            ForEach(ListingCategory.allCases, id: \.rawValue) { cat in
                                CategoryChip(title: cat.displayName, icon: cat.icon, color: cat.color, isSelected: selectedCategory == cat) {
                                    withAnimation(.spring(response: 0.3)) {
                                        selectedCategory = (selectedCategory == cat) ? nil : cat
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical, 12)

                    if filteredListings.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 48))
                                .foregroundStyle(.secondary)
                            Text("Không tìm thấy kết quả")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 60)
                    } else {
                        LazyVStack(spacing: 14) {
                            ForEach(filteredListings) { listing in
                                NavigationLink(destination: ListingDetailView(listing: listing)) {
                                    ListingCard(listing: listing)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationTitle("Tìm kiếm")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $searchText, prompt: "Tìm phòng, quận, khu vực...")
        }
    }
}

// MARK: - Post Type Picker

struct PostTypePickerView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 12) {
                        Image("logo")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 72)
                        Text("Chọn loại tin bạn muốn đăng")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 8)

                    VStack(spacing: 12) {
                        PostTypeCard(
                            title: "Tìm bạn ở chung",
                            subtitle: "Có phòng trống hoặc đang tìm phòng ghép",
                            icon: "person.2.fill",
                            color: .roommateColor
                        )
                        PostTypeCard(
                            title: "Phòng trọ",
                            subtitle: "Cho thuê phòng trọ, căn hộ mini",
                            icon: "house.fill",
                            color: .roomshareColor
                        )
                        PostTypeCard(
                            title: "Cho thuê ngắn hạn",
                            subtitle: "Phòng theo tuần, tháng linh hoạt",
                            icon: "clock.fill",
                            color: .shortTermColor
                        )
                        PostTypeCard(
                            title: "Sang nhượng",
                            subtitle: "Chuyển nhượng hợp đồng thuê nhà",
                            icon: "key.fill",
                            color: .subleaseColor
                        )
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 40)
            }
            .navigationTitle("Đăng tin")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Post Type Card

struct PostTypeCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color

    var body: some View {
        Button {
        } label: {
            HStack(spacing: 16) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.opacity(0.15))
                    .frame(width: 48, height: 48)
                    .overlay {
                        Image(systemName: icon)
                            .font(.title3)
                            .foregroundStyle(color)
                    }

                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding(14)
            .glassEffect(in: .rect(cornerRadius: 14))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    MainTabView()
        .environmentObject(AppState())
}
