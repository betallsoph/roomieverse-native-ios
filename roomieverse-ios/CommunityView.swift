//
//  CommunityView.swift
//  roomieverse-ios
//

import SwiftUI

struct CommunityView: View {
    @StateObject private var communityService = CommunityService.shared
    @State private var selectedCategory: CommunityCategory? = nil
    @State private var selectedPost: CommunityPost? = nil

    var filteredPosts: [CommunityPost] {
        guard let cat = selectedCategory else { return communityService.posts }
        return communityService.posts.filter { $0.category == cat }
    }
    
    var hotPosts: [CommunityPost] {
        communityService.posts.filter { $0.isHot }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Hot posts horizontal scroll
                    if selectedCategory == nil {
                        hotSection
                            .padding(.bottom, 8)
                    }

                    // Category filter
                    communityFilter
                        .padding(.horizontal)
                        .padding(.vertical, 12)

                    // Posts
                    if communityService.isLoading {
                        ProgressView("Đang tải...")
                            .padding(.top, 40)
                    } else if filteredPosts.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "bubble.left.and.bubble.right.fill")
                                .font(.system(size: 48))
                                .foregroundStyle(.secondary)
                            Text("Chưa có bài viết nào")
                                .font(.headline)
                                .foregroundStyle(.secondary)
                            if let error = communityService.errorMessage {
                                Text(error)
                                    .font(.caption)
                                    .foregroundStyle(.red)
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 60)
                    } else {
                        LazyVStack(spacing: 14) {
                            ForEach(filteredPosts) { post in
                                NavigationLink(destination: CommunityPostDetail(post: post)) {
                                    CommunityPostCard(post: post)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationTitle("Cộng đồng")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                    } label: {
                        Image(systemName: "square.and.pencil")
                            .padding(6)
                    }
                    .buttonStyle(.glass)
                }
            }
            .onAppear {
                Task {
                    await communityService.fetchPosts(category: selectedCategory, hot: nil)
                }
            }
        }
    }

    // MARK: - Hot Section

    private var hotSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "flame.fill")
                    .foregroundStyle(.orange)
                Text("Đang hot")
                    .font(.title2.bold())
            }
            .padding(.horizontal)
            .padding(.top, 8)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(hotPosts) { post in
                        NavigationLink(destination: CommunityPostDetail(post: post)) {
                            HotPostCard(post: post)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 4)
            }
        }
    }

    // MARK: - Community Filter

    private var communityFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                CategoryChip(title: "Tất cả", icon: "square.grid.2x2.fill", color: .gray, isSelected: selectedCategory == nil) {
                    withAnimation(.spring(response: 0.3)) {
                        selectedCategory = nil
                    }
                }
                ForEach(CommunityCategory.allCases, id: \.rawValue) { cat in
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

// MARK: - Hot Post Card

struct HotPostCard: View {
    let post: CommunityPost

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 14)
                    .fill(post.category.color.opacity(0.15))
                    .frame(height: 100)
                    .overlay {
                        Image(systemName: post.category.icon)
                            .font(.system(size: 36))
                            .foregroundStyle(post.category.color.opacity(0.4))
                    }

                Text("HOT")
                    .font(.caption2.weight(.black))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .foregroundStyle(.orange)
                    .glassEffect(.regular.tint(.orange), in: Capsule())
                    .padding(8)
            }

            VStack(alignment: .leading, spacing: 4) {
                Label(post.category.displayName, systemImage: post.category.icon)
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(post.category.color)

                Text(post.title)
                    .font(.caption.weight(.semibold))
                    .lineLimit(2)
                    .foregroundStyle(.primary)

                HStack(spacing: 10) {
                    Label("\(post.likes)", systemImage: "heart.fill")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Label("\(post.comments)", systemImage: "bubble.left.fill")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 4)
        }
        .frame(width: 200)
    }
}

// MARK: - Community Post Card

struct CommunityPostCard: View {
    let post: CommunityPost

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Author + category
            HStack(alignment: .center) {
                Image(systemName: post.authorAvatar)
                    .font(.title3)
                    .foregroundStyle(post.category.color)

                VStack(alignment: .leading, spacing: 2) {
                    Text(post.authorName)
                        .font(.caption.weight(.semibold))
                    Text(post.createdAt.timeAgo)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }

                Spacer()

                Text(post.category.displayName)
                    .font(.caption2.weight(.bold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .foregroundStyle(post.category.color)
                    .background(post.category.color.opacity(0.12))
                    .clipShape(Capsule())
            }

            // Title
            Text(post.title)
                .font(.subheadline.weight(.semibold))
                .lineLimit(2)

            // Preview
            Text(post.preview)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(3)

            // Stats
            HStack(spacing: 16) {
                HStack(spacing: 4) {
                    Image(systemName: "heart.fill")
                        .font(.caption2)
                        .foregroundStyle(.red)
                    Text("\(post.likes)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                HStack(spacing: 4) {
                    Image(systemName: "bubble.left.fill")
                        .font(.caption2)
                        .foregroundStyle(.blue)
                    Text("\(post.comments)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                HStack(spacing: 4) {
                    Image(systemName: "eye.fill")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text("\(post.views)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if post.isHot {
                    Label("Hot", systemImage: "flame.fill")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.orange)
                }
            }
        }
        .padding(16)
        .glassEffect(in: .rect(cornerRadius: 16))
    }
}

// MARK: - Community Post Detail

struct CommunityPostDetail: View {
    @Environment(\.dismiss) private var dismiss
    let post: CommunityPost
    @State private var isLiked = false
    @State private var likeCount: Int

    init(post: CommunityPost) {
        self.post = post
        self._likeCount = State(initialValue: post.likes)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 16) {
                    // Category
                    Label(post.category.displayName, systemImage: post.category.icon)
                        .font(.caption.weight(.bold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .foregroundStyle(post.category.color)
                        .background(post.category.color.opacity(0.12))
                        .clipShape(Capsule())

                    Text(post.title)
                        .font(.title2.bold())

                    HStack(spacing: 10) {
                        Image(systemName: post.authorAvatar)
                            .font(.title2)
                            .foregroundStyle(post.category.color)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(post.authorName)
                                .font(.subheadline.weight(.semibold))
                            Text(post.createdAt.timeAgo)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }

                    // Stats bar with glass effect
                    HStack(spacing: 20) {
                        HStack(spacing: 6) {
                            Image(systemName: "eye.fill")
                                .foregroundStyle(.secondary)
                            Text("\(post.views) lượt đọc")
                                .foregroundStyle(.secondary)
                        }
                        .font(.caption)

                        HStack(spacing: 6) {
                            Image(systemName: "bubble.left.fill")
                                .foregroundStyle(.blue)
                            Text("\(post.comments) bình luận")
                                .foregroundStyle(.secondary)
                        }
                        .font(.caption)
                    }
                }
                .padding(20)

                Divider()

                // Content
                Text(LocalizedStringKey(post.content))
                    .font(.body)
                    .lineSpacing(6)
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Spacer().frame(height: 80)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .overlay(alignment: .bottom) {
            // Liquid Glass action bar
            GlassEffectContainer(spacing: 12) {
                HStack(spacing: 12) {
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            isLiked.toggle()
                            likeCount += isLiked ? 1 : -1
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: isLiked ? "heart.fill" : "heart")
                                .symbolEffect(.bounce, value: isLiked)
                            Text("\(likeCount)")
                                .font(.subheadline.weight(.semibold))
                        }
                        .foregroundStyle(isLiked ? .red : .primary)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                    }
                    .buttonStyle(isLiked ? .glass(Glass.regular.tint(.red).interactive()) : .glass)

                    Button {
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "bubble.left")
                            Text("Bình luận")
                                .font(.subheadline.weight(.semibold))
                        }
                        .foregroundStyle(.primary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    }
                    .buttonStyle(.glass)

                    Spacer()

                    Button {
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundStyle(.primary)
                            .padding(12)
                    }
                    .buttonStyle(.glass)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(.ultraThinMaterial)
        }
    }
}

#Preview {
    CommunityView()
        .environmentObject(AppState())
}
