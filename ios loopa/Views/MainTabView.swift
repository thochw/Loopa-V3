//
//  MainTabView.swift
//  ios loopa
//
//  Created by Thomas CHANG-HING-WING on 2026-01-17.
//

import SwiftUI

extension Color {
    static let appAccent = Color(hex: "fe3c5d")
    
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct MainTabView: View {
    @State private var selectedTab: AppTab = .explore
    @State private var selectedUser: User?
    @State private var selectedChat: Chat?
    @State private var showCelebration = false
    @State private var preselectedCreateType: CreateGroupEventView.CreationType? = nil
    
    var body: some View {
        ZStack {
            // Main Content with smooth transitions
            if selectedUser != nil {
                ProfileView(user: selectedUser!) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        selectedUser = nil
                    }
                }
                .transition(.move(edge: .trailing).combined(with: .opacity))
            } else if selectedChat != nil {
                ChatDetailView(chat: selectedChat!) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        selectedChat = nil
                    }
                }
                .transition(.move(edge: .trailing).combined(with: .opacity))
            } else {
                contentView(for: selectedTab)
                    .id(selectedTab) // Force view refresh on tab change
                    .transition(.opacity)
            }
            
            // Bottom Navigation Bar with safe area support
            if selectedUser == nil && selectedChat == nil {
                VStack {
                    Spacer()
                    bottomNavigationBar
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
                .ignoresSafeArea(edges: .bottom)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: selectedTab)
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .sheet(item: $preselectedCreateType) { type in
            CreateGroupEventView(
                showCelebration: $showCelebration,
                preselectedType: type
            )
            .presentationDetents([.fraction(0.65)])
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(28)
            .safeAreaPadding(.top, -100)
            .safeAreaPadding(.bottom, 16)
        }
        .celebrationOverlay(show: $showCelebration)
    }
    
    @ViewBuilder
    private func contentView(for tab: AppTab) -> some View {
        switch tab {
        case .explore:
            ExploreView(
                variant: .groups,
                onProfileClick: { user in
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        selectedUser = user
                    }
                },
                onAddGroupClick: { createType in
                    if let type = createType {
                        preselectedCreateType = type == .group ? .group : .event
                    }
                }
            )
        case .map:
            ExploreView(
                variant: .travelers,
                onProfileClick: { user in
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        selectedUser = user
                    }
                },
                onAddGroupClick: { createType in
                    if let type = createType {
                        preselectedCreateType = type == .group ? .group : .event
                    }
                }
            )
        case .housing:
            HousingView()
        case .chats:
            ChatsListView { chat in
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    selectedChat = chat
                }
            }
        }
    }
    
    private var bottomNavigationBar: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases, id: \.self) { tab in
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = tab
                    }
                }) {
                    VStack(spacing: 4) {
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: iconName(for: tab))
                                .font(.system(size: 22, weight: .bold))
                                .symbolVariant(selectedTab == tab ? .fill : .none)
                                .foregroundStyle(
                                    selectedTab == tab ? Color.appAccent : Color.black
                                )
                                .scaleEffect(selectedTab == tab ? 1.1 : 1.0)
                            
                            // Notification badge for map tab
                            if tab == .map {
                                Circle()
                                    .fill(Color.red)
                                    .frame(width: 8, height: 8)
                                    .offset(x: 8, y: -4)
                            }
                        }
                        
                        Text(tabLabel(for: tab))
                            .font(.system(size: 11, weight: selectedTab == tab ? .semibold : .medium))
                            .foregroundStyle(
                                selectedTab == tab ? Color.appAccent : Color.black
                            )
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 56) // Increased for text label
                    .contentShape(Rectangle()) // Full button area is tappable
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
        .background(
            .ultraThinMaterial,
            in: Capsule()
        )
        .glassEffect(.regular, in: Capsule())
        .shadow(color: .black.opacity(0.1), radius: 10, y: 4)
    }
    
    private func iconName(for tab: AppTab) -> String {
        switch tab {
        case .explore: return "globe.americas"
        case .map: return "person.2"
        case .housing: return "house"
        case .chats: return "message"
        }
    }
    
    private func tabLabel(for tab: AppTab) -> String {
        switch tab {
        case .explore: return "Explore"
        case .map: return "Friends"
        case .housing: return "Housing"
        case .chats: return "Messages"
        }
    }
}
