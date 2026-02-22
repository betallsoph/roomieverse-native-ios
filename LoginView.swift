//
//  LoginView.swift
//  roomieverse-ios
//
//  Authentication screen with Google Sign-In
//

import SwiftUI

struct LoginView: View {
    @StateObject private var authService = AuthService.shared
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color.brandPink.opacity(0.2),
                    Color.roommateColor.opacity(0.15)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Logo and branding
                VStack(spacing: 16) {
                    Image("logo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 120)
                        .shadow(radius: 10)
                    
                    Text("RoomieVerse")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundStyle(Color.brandPink)
                    
                    Text("Tìm bạn cùng phòng - Tìm phòng trọ")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                Spacer()
                
                // Sign in section
                VStack(spacing: 24) {
                    if authService.isLoading {
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(Color.brandPink)
                    } else {
                        // Google Sign In Button
                        Button {
                            Task {
                                await authService.signInWithGoogle()
                            }
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "g.circle.fill")
                                    .font(.title2)
                                
                                Text("Đăng nhập với Google")
                                    .font(.headline)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .foregroundStyle(.white)
                            .background(Color.brandPink)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .shadow(color: Color.brandPink.opacity(0.3), radius: 8, y: 4)
                        }
                        
                        // Note about Firebase setup
                        VStack(spacing: 8) {
                            Text("⚠️ Cần setup Firebase để đăng nhập")
                                .font(.caption)
                                .foregroundStyle(.orange)
                            
                            Text("Xem hướng dẫn trong SETUP.md")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    
                    // Error message
                    if let error = authService.errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red)
                            .multilineTextAlignment(.center)
                            .padding()
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
                .padding(.horizontal, 32)
                
                Spacer()
                
                // Footer
                VStack(spacing: 4) {
                    Text("Bằng việc đăng nhập, bạn đồng ý với")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    
                    HStack(spacing: 4) {
                        Button("Điều khoản sử dụng") {}
                            .font(.caption2)
                            .foregroundStyle(Color.brandPink)
                        
                        Text("và")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        
                        Button("Chính sách bảo mật") {}
                            .font(.caption2)
                            .foregroundStyle(Color.brandPink)
                    }
                }
                .padding(.bottom, 32)
            }
        }
    }
}

#Preview {
    LoginView()
}
