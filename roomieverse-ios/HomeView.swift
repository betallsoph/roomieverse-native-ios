//
//  HomeView.swift
//  roomieverse-ios
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedCategory: ListingCategory? = nil
    @State private var searchText: String = ""
    @State private var selectedListing: RoomListing? = nil

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

    var featuredListings: [RoomListing] {
        MockData.listings.filter { $0.isFeatured }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Featured Section
                    if selectedCategory == nil && searchText.isEmpty {
                        featuredSection
                            .padding(.bottom, 8)
                    }

                    // Category filter
                    categoryFilter
                        .padding(.horizontal)
                        .padding(.vertical, 12)

                    // Listings
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
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Image("logo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 32)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                    } label: {
                        Image(systemName: "bell.fill")
                            .padding(6)
                    }
                    .buttonStyle(.glass)
                }
            }
            .searchable(text: $searchText, prompt: "Tìm phòng, khu vực...")
        }
    }

    // MARK: - Featured Section

    private var featuredSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Nổi bật")
                .font(.title2.bold())
                .padding(.horizontal)
                .padding(.top, 8)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(featuredListings) { listing in
                        NavigationLink(destination: ListingDetailView(listing: listing)) {
                            FeaturedCard(listing: listing)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 4)
            }
        }
    }

    // MARK: - Category Filter

    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                CategoryChip(title: "Tất cả", icon: "square.grid.2x2.fill", color: .gray, isSelected: selectedCategory == nil) {
                    withAnimation(.spring(response: 0.3)) {
                        selectedCategory = nil
                    }
                }
                ForEach(ListingCategory.allCases, id: \.rawValue) { cat in
                    CategoryChip(title: cat.displayName, icon: cat.icon, color: cat.color, isSelected: selectedCategory == cat) {
                        withAnimation(.spring(response: 0.3)) {
                            selectedCategory = (selectedCategory == cat) ? nil : cat
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Category Chip

struct CategoryChip: View {
    let title: String
    let icon: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption.weight(.semibold))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .foregroundStyle(isSelected ? color : .primary)
                .glassEffect(isSelected ? .regular.tint(color).interactive() : .regular.interactive(), in: Capsule())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Featured Card

struct FeaturedCard: View {
    let listing: RoomListing

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image placeholder with gradient
            ZStack(alignment: .bottomLeading) {
                RoundedRectangle(cornerRadius: 16)
                    .fill(listing.category.color.opacity(0.15))
                    .frame(height: 160)
                    .overlay {
                        Image(systemName: listing.category.icon)
                            .font(.system(size: 50))
                            .foregroundStyle(listing.category.color.opacity(0.4))
                    }

                LinearGradient(
                    colors: [.clear, .black.opacity(0.5)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .frame(height: 160)

                VStack(alignment: .leading, spacing: 4) {
                    Text(listing.category.displayName)
                        .font(.caption2.weight(.bold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .foregroundStyle(listing.category.color)
                        .glassEffect(.regular.tint(listing.category.color), in: Capsule())

                    Text(listing.price.priceFormatted)
                        .font(.headline.bold())
                        .foregroundStyle(.white)
                }
                .padding(12)
            }
            .frame(width: 240)

            VStack(alignment: .leading, spacing: 4) {
                Text(listing.title)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(2)
                    .foregroundStyle(.primary)

                HStack(spacing: 4) {
                    Image(systemName: "mappin.circle.fill")
                        .foregroundStyle(.secondary)
                        .font(.caption)
                    Text(listing.district)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 4)
            .padding(.vertical, 8)
        }
        .frame(width: 240)
    }
}

// MARK: - Listing Card

struct ListingCard: View {
    @EnvironmentObject var appState: AppState
    let listing: RoomListing

    var isFavorite: Bool { appState.isFavorite(listingId: listing.id) }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header row
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    // Category badge
                    Text(listing.roommateType?.displayName ?? listing.category.displayName)
                        .font(.caption2.weight(.bold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .foregroundStyle(listing.category.color)
                        .background(listing.category.color.opacity(0.12))
                        .clipShape(Capsule())

                    Text(listing.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                        .lineLimit(2)
                }

                Spacer()

                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        appState.toggleFavorite(listingId: listing.id)
                    }
                } label: {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .font(.system(size: 20))
                        .foregroundStyle(isFavorite ? .red : .secondary)
                        .symbolEffect(.bounce, value: isFavorite)
                }
                .buttonStyle(.plain)
            }

            Divider().padding(.vertical, 10)

            // Info row
            HStack(spacing: 16) {
                InfoChip(icon: "mappin.circle.fill", text: listing.district, color: .red)
                InfoChip(icon: "calendar", text: listing.moveInDate, color: .orange)
                Spacer()
                Text(listing.price.priceFormatted)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(listing.category.color)
            }

            // Amenities
            if !listing.amenities.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(listing.amenities.prefix(5), id: \.self) { amenity in
                            AmenityTag(amenity: amenity)
                        }
                    }
                    .padding(.top, 8)
                }
            }

            // Footer
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: "person.circle.fill")
                        .foregroundStyle(.secondary)
                        .font(.caption)
                    Text(listing.authorName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                HStack(spacing: 12) {
                    HStack(spacing: 3) {
                        Image(systemName: "eye.fill")
                            .font(.caption2)
                        Text("\(listing.viewCount)")
                            .font(.caption2)
                    }
                    .foregroundStyle(.secondary)
                    HStack(spacing: 3) {
                        Image(systemName: "heart.fill")
                            .font(.caption2)
                        Text("\(listing.favoriteCount)")
                            .font(.caption2)
                    }
                    .foregroundStyle(.secondary)
                }
            }
            .padding(.top, 10)
        }
        .padding(16)
        .glassEffect(in: .rect(cornerRadius: 16))
    }
}

// MARK: - Info Chip

struct InfoChip: View {
    let icon: String
    let text: String
    let color: Color

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption2)
                .foregroundStyle(color)
            Text(text)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
    }
}

// MARK: - Amenity Tag

struct AmenityTag: View {
    let amenity: String

    var amenityLabel: String {
        switch amenity {
        case "ac": return "Máy lạnh"
        case "wifi": return "Wifi"
        case "washing": return "Máy giặt"
        case "fridge": return "Tủ lạnh"
        case "parking": return "Bãi xe"
        case "elevator": return "Thang máy"
        default: return amenity
        }
    }

    var body: some View {
        Text(amenityLabel)
            .font(.caption2.weight(.medium))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .foregroundStyle(.secondary)
            .glassEffect(in: Capsule())
    }
}

// MARK: - Int Extension

extension Int {
    var priceFormatted: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = "."
        let formatted = formatter.string(from: NSNumber(value: self)) ?? "\(self)"
        return "\(formatted)đ"
    }
}

#Preview {
    HomeView()
        .environmentObject(AppState())
}
