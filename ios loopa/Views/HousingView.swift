//
//  HousingView.swift
//  ios loopa
//
//  Created by Thomas CHANG-HING-WING on 2026-01-17.
//

import SwiftUI

enum HousingTab: String, CaseIterable {
    case spots = "Find a Spot"
    case roommates = "Roommates"
    case swaps = "Home Swaps"
}

struct HousingView: View {
    @State private var activeTab: HousingTab = .spots
    private let data = AppData.shared
    
    var body: some View {
        VStack(spacing: 0) {
            // Enhanced Header
            VStack(spacing: 20) {
                Text("Housing")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // Enhanced Tabs with animations
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(HousingTab.allCases, id: \.self) { tab in
                            Button(action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    activeTab = tab
                                }
                            }) {
                                Text(tab.rawValue)
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundStyle(activeTab == tab ? .white : .primary)
                                    .padding(.horizontal, 18)
                                    .padding(.vertical, 10)
                                    .background(
                                        activeTab == tab ? AnyShapeStyle(Color.primary) : AnyShapeStyle(Material.ultraThinMaterial),
                                        in: Capsule()
                                    )
                                    .overlay(
                                        Capsule()
                                            .strokeBorder(
                                                activeTab == tab ? Color.clear : Color(.separator),
                                                lineWidth: 1
                                            )
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 4)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .safeAreaInset(edge: .top) {
                Color.clear.frame(height: 0)
            }
            .padding(.bottom, 20)
            .background(Color(.systemGroupedBackground))
            
            // Enhanced Content with smooth transitions
            ScrollView {
                LazyVStack(spacing: 16) {
                    switch activeTab {
                    case .spots:
                        ForEach(data.housingSpots) { spot in
                            housingSpotCard(spot: spot)
                                .transition(.opacity.combined(with: .move(edge: .bottom)))
                        }
                    case .roommates:
                        ForEach(data.roommates) { roommate in
                            roommateCard(roommate: roommate)
                                .transition(.opacity.combined(with: .move(edge: .bottom)))
                        }
                    case .swaps:
                        ForEach(data.swaps) { swap in
                            swapCard(swap: swap)
                                .transition(.opacity.combined(with: .move(edge: .bottom)))
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 100)
            }
        }
        .background(Color(.systemGroupedBackground))
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: activeTab)
    }
    
    private func housingSpotCard(spot: HousingSpot) -> some View {
        Button(action: {}) {
            VStack(spacing: 0) {
                ZStack(alignment: .topTrailing) {
                    AsyncImage(url: URL(string: spot.image)) { phase in
                        if let image = phase.image {
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } else if phase.error != nil {
                            Color(.systemGray5)
                        } else {
                            ProgressView()
                                .tint(.secondary)
                        }
                    }
                    .frame(height: 180)
                    .clipped()
                    
                    // Enhanced Rating Badge
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 12))
                            .foregroundStyle(.yellow)
                        Text(String(format: "%.1f", spot.rating))
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.primary)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        .regularMaterial,
                        in: RoundedRectangle(cornerRadius: 10, style: .continuous)
                    )
                    .padding(16)
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .top) {
                        Text(spot.title)
                            .font(.system(size: 19, weight: .semibold))
                            .foregroundStyle(.primary)
                            .lineLimit(2)
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("\(spot.currency)\(spot.price)")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundStyle(Color.appAccent)
                            Text("/\(spot.period)")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    // Enhanced Recommender Section
                    HStack(spacing: 10) {
                        AsyncImage(url: URL(string: spot.recommenderImg)) { phase in
                            if let image = phase.image {
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } else {
                                Image(systemName: "person.circle.fill")
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .frame(width: 28, height: 28)
                        .clipShape(Circle())
                        .overlay(Circle().strokeBorder(.quaternary, lineWidth: 1))
                        
                        Text("Recommended by **\(spot.recommender)**")
                            .font(.system(size: 13, weight: .regular))
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(18)
            }
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(.quaternary, lineWidth: 0.5)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
    
    private func roommateCard(roommate: Roommate) -> some View {
        Button(action: {}) {
            HStack(spacing: 16) {
                AsyncImage(url: URL(string: roommate.image)) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else if phase.error != nil {
                        Image(systemName: "person.circle.fill")
                            .foregroundStyle(.secondary)
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    } else {
                        ProgressView()
                            .tint(.secondary)
                    }
                }
                .frame(width: 84, height: 84)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(.quaternary, lineWidth: 1)
                )
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("\(roommate.name), \(roommate.age)")
                        .font(.system(size: 19, weight: .semibold))
                        .foregroundStyle(.primary)
                    
                    Text("\(roommate.location) • $\(roommate.budget)")
                        .font(.system(size: 15, weight: .regular))
                        .foregroundStyle(.secondary)
                    
                    // Enhanced Tags
                    HStack(spacing: 6) {
                        ForEach(roommate.tags, id: \.self) { tag in
                            Text(tag)
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(
                                    .ultraThinMaterial,
                                    in: Capsule()
                                )
                        }
                    }
                }
                
                Spacer()
            }
            .padding(18)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(.quaternary, lineWidth: 0.5)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
    
    private func swapCard(swap: HomeSwap) -> some View {
        VStack(spacing: 0) {
            ZStack(alignment: .bottomLeading) {
                AsyncImage(url: URL(string: swap.image)) { image in
                    image.resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color.gray.opacity(0.3)
                }
                .frame(height: 160)
                .clipped()
                
                Text(swap.homeType)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.black.opacity(0.6))
                    .clipShape(Capsule())
                    .padding(12)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(swap.title)
                    .font(.system(size: 18, weight: .bold))
                
                HStack {
                    Text(swap.dates)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    HStack(spacing: 8) {
                        Text("Owner: \(swap.owner)")
                            .font(.system(size: 11))
                            .foregroundColor(.gray)
                        
                        AsyncImage(url: URL(string: swap.ownerImg)) { image in
                            image.resizable()
                        } placeholder: {
                            Color.gray.opacity(0.3)
                        }
                        .frame(width: 24, height: 24)
                        .clipShape(Circle())
                    }
                }
            }
            .padding(16)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(radius: 2)
    }
}
