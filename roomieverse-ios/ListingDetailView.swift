//
//  ListingDetailView.swift
//  roomieverse-ios
//

import SwiftUI

struct ListingDetailView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    let listing: RoomListing

    var isFavorite: Bool { appState.isFavorite(listingId: listing.id) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Hero image area
                heroSection

                // Content
                VStack(alignment: .leading, spacing: 20) {
                    headerSection
                    Divider()
                    infoSection
                    if !listing.amenities.isEmpty {
                        amenitiesSection
                        Divider()
                    }
                    descriptionSection
                    if listing.introduction?.isEmpty == false {
                        introductionSection
                        Divider()
                    }
                    preferencesSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 100)
            }
        }
        .ignoresSafeArea(edges: .top)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.white)
                        .background(.black.opacity(0.3), in: Circle())
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 12) {
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            appState.toggleFavorite(listingId: listing.id)
                        }
                    } label: {
                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                            .font(.title3)
                            .foregroundStyle(isFavorite ? .red : .white)
                            .background(.black.opacity(0.3), in: Circle())
                            .padding(6)
                            .symbolEffect(.bounce, value: isFavorite)
                    }

                    Button {
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .font(.title3)
                            .foregroundStyle(.white)
                            .background(.black.opacity(0.3), in: Circle())
                            .padding(6)
                    }
                }
            }
        }
        .overlay(alignment: .bottom) {
            contactBar
        }
    }

    // MARK: - Hero

    private var heroSection: some View {
        ZStack(alignment: .bottomLeading) {
            // Background
            listing.category.color.opacity(0.2)
                .frame(height: 280)
                .overlay {
                    Image(systemName: listing.category.icon)
                        .font(.system(size: 80))
                        .foregroundStyle(listing.category.color.opacity(0.3))
                }

            // Gradient overlay
            LinearGradient(
                colors: [.clear, .black.opacity(0.6)],
                startPoint: .center,
                endPoint: .bottom
            )
            .frame(height: 280)

            VStack(alignment: .leading, spacing: 8) {
                GlassEffectContainer(spacing: 8) {
                    HStack(spacing: 8) {
                        Label(listing.category.displayName, systemImage: listing.category.icon)
                            .font(.caption.weight(.bold))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .foregroundStyle(listing.category.color)
                            .glassEffect(.regular.tint(listing.category.color), in: Capsule())

                        if let type = listing.roommateType {
                            Text(type.displayName)
                                .font(.caption.weight(.bold))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .foregroundStyle(.white)
                                .glassEffect(in: Capsule())
                        }
                    }
                }

                Text(listing.price.priceFormatted + "/tháng")
                    .font(.title.bold())
                    .foregroundStyle(.white)
            }
            .padding(20)
            .padding(.bottom, 4)
        }
        .frame(height: 280)
        .clipped()
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(listing.title)
                .font(.title2.bold())

            HStack(spacing: 6) {
                Image(systemName: "mappin.circle.fill")
                    .foregroundStyle(.red)
                Text(listing.location)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 16) {
                HStack(spacing: 4) {
                    Image(systemName: "eye.fill")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(listing.viewCount) lượt xem")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                HStack(spacing: 4) {
                    Image(systemName: "heart.fill")
                        .font(.caption)
                        .foregroundStyle(.pink)
                    Text("\(listing.favoriteCount) yêu thích")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text(listing.createdAt.timeAgo)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
    }

    // MARK: - Info

    private var infoSection: some View {
        VStack(spacing: 12) {
            InfoRow(icon: "calendar", label: "Ngày vào", value: listing.moveInDate, color: .orange)
            if let size = listing.roomSize {
                InfoRow(icon: "square.dashed", label: "Diện tích", value: "\(size)m²", color: .blue)
            }
            if let occupants = listing.currentOccupants {
                InfoRow(icon: "person.2.fill", label: "Hiện có", value: "\(occupants) người", color: .purple)
            }
            InfoRow(icon: "location.circle.fill", label: "Quận/Huyện", value: listing.district, color: .red)
        }
    }

    // MARK: - Amenities

    private var amenitiesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tiện ích")
                .font(.headline)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(listing.amenities, id: \.self) { amenity in
                    AmenityBadge(amenity: amenity)
                }
            }
        }
    }

    // MARK: - Description

    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Mô tả")
                .font(.headline)
            Text(listing.description)
                .font(.body)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: - Introduction

    private var introductionSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Giới thiệu bản thân")
                .font(.headline)
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "person.circle.fill")
                    .font(.title)
                    .foregroundStyle(listing.category.color)
                VStack(alignment: .leading, spacing: 4) {
                    Text(listing.authorName)
                        .font(.subheadline.weight(.semibold))
                    Text(listing.introduction ?? "")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(14)
            .glassEffect(in: .rect(cornerRadius: 14))
        }
    }

    // MARK: - Preferences

    private var preferencesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let gender = listing.preferredGender, !gender.isEmpty {
                Text("Yêu cầu người ở ghép")
                    .font(.headline)
                VStack(spacing: 10) {
                    if let gender = listing.preferredGender {
                        PreferenceRow(label: "Giới tính", value: preferenceDisplayName(for: gender, type: "gender"))
                    }
                    if let schedule = listing.schedule {
                        PreferenceRow(label: "Lịch sinh hoạt", value: preferenceDisplayName(for: schedule, type: "schedule"))
                    }
                    if let cleanliness = listing.cleanliness {
                        PreferenceRow(label: "Vệ sinh", value: preferenceDisplayName(for: cleanliness, type: "cleanliness"))
                    }
                    if !listing.habits.isEmpty {
                        PreferenceRow(label: "Thói quen", value: listing.habits.map { preferenceDisplayName(for: $0, type: "habits") }.joined(separator: ", "))
                    }
                    if let pets = listing.pets {
                        PreferenceRow(label: "Thú cưng", value: preferenceDisplayName(for: pets, type: "pets"))
                    }
                }
            }
        }
    }

    // MARK: - Contact Bar (Liquid Glass)

    private var contactBar: some View {
        GlassEffectContainer(spacing: 16) {
            HStack(spacing: 12) {
                // Phone button
                Button {
                } label: {
                    Label("Gọi điện", systemImage: "phone.fill")
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .foregroundStyle(listing.category.color)
                }
                .buttonStyle(.glass(Glass.regular.tint(listing.category.color).interactive()))
                .frame(maxWidth: .infinity)

                // Zalo button
                if listing.zalo != nil {
                    Button {
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "message.fill")
                            Text("Zalo")
                        }
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .foregroundStyle(.primary)
                    }
                    .buttonStyle(.glass)
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(.ultraThinMaterial)
    }

    private func preferenceDisplayName(for value: String, type: String) -> String {
        switch (type, value) {
        case ("gender", "male"): return "Nam"
        case ("gender", "female"): return "Nữ"
        case ("gender", "any"): return "Không yêu cầu"
        case ("schedule", "early"): return "Sáng sớm"
        case ("schedule", "late"): return "Cú đêm"
        case ("schedule", "flexible"): return "Linh hoạt"
        case ("cleanliness", "very-clean"): return "Rất sạch sẽ"
        case ("cleanliness", "normal"): return "Bình thường"
        case ("cleanliness", "relaxed"): return "Thoải mái"
        case ("habits", "no-smoke"): return "Không hút thuốc"
        case ("habits", "no-alcohol"): return "Không rượu bia"
        case ("habits", "flexible"): return "Linh hoạt"
        case ("pets", "no-pets"): return "Không nuôi thú"
        case ("pets", "cats-ok"): return "OK với mèo"
        case ("pets", "dogs-ok"): return "OK với chó"
        case ("pets", "any-pets"): return "OK với thú cưng"
        default: return value
        }
    }
}

// MARK: - Info Row

struct InfoRow: View {
    let icon: String
    let label: String
    let value: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(color)
                .frame(width: 28, height: 28)
                .background(color.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))

            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Spacer()

            Text(value)
                .font(.subheadline.weight(.semibold))
        }
    }
}

// MARK: - Amenity Badge

struct AmenityBadge: View {
    let amenity: String

    var amenityInfo: (String, String) {
        switch amenity {
        case "ac": return ("snowflake", "Máy lạnh")
        case "wifi": return ("wifi", "Wifi")
        case "washing": return ("washer.fill", "Máy giặt")
        case "fridge": return ("refrigerator.fill", "Tủ lạnh")
        case "parking": return ("parkingsign.circle.fill", "Bãi xe")
        case "elevator": return ("arrow.up.arrow.down", "Thang máy")
        default: return ("star.fill", amenity)
        }
    }

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: amenityInfo.0)
                .font(.title3)
                .foregroundStyle(.blue)
            Text(amenityInfo.1)
                .font(.caption2.weight(.medium))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .glassEffect(in: .rect(cornerRadius: 12))
    }
}

// MARK: - Preference Row

struct PreferenceRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline.weight(.medium))
        }
        .padding(.vertical, 2)
    }
}

// MARK: - Date Extension

extension Date {
    var timeAgo: String {
        let now = Date()
        let diff = now.timeIntervalSince(self)
        if diff < 3600 {
            return "\(Int(diff / 60)) phút trước"
        } else if diff < 86400 {
            return "\(Int(diff / 3600)) giờ trước"
        } else {
            return "\(Int(diff / 86400)) ngày trước"
        }
    }
}

#Preview {
    NavigationStack {
        ListingDetailView(listing: MockData.listings[0])
            .environmentObject(AppState())
    }
}
