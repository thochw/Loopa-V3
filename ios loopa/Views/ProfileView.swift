//
//  ProfileView.swift
//  ios loopa
//
//  Created by Thomas CHANG-HING-WING on 2026-01-17.
//

import SwiftUI

struct ProfileView: View {
    let user: User
    let onBack: () -> Void
    
    private let age = 24
    private let location = "CANADA"
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 0) {
                    // Hero Image
                    ZStack(alignment: .bottom) {
                        AsyncImage(url: URL(string: user.image)) { image in
                            image.resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Color.gray.opacity(0.3)
                        }
                        .frame(height: geometry.size.height * 0.65)
                        .clipped()
                        
                        // Overlays
                        LinearGradient(
                            colors: [.black.opacity(0.5), .clear],
                            startPoint: .top,
                            endPoint: .center
                        )
                        .frame(height: 120)
                        .offset(y: -geometry.size.height * 0.65 + 120)
                    
                    LinearGradient(
                        colors: [.clear, .black.opacity(0.9), .black.opacity(0.4)],
                        startPoint: .center,
                        endPoint: .bottom
                    )
                    .frame(height: 250)
                    
                    // Header Buttons
                    HStack {
                        Button(action: onBack) {
                            Image(systemName: "arrow.left")
                                .font(.system(size: 20))
                                .foregroundColor(.white)
                                .frame(width: 40, height: 40)
                                .background(Color.white.opacity(0.2))
                                .clipShape(Circle())
                        }
                        
                        Spacer()
                        
                        Button(action: {}) {
                            Image(systemName: "ellipsis")
                                .font(.system(size: 20))
                                .foregroundColor(.white)
                                .frame(width: 40, height: 40)
                                .background(Color.white.opacity(0.2))
                                .clipShape(Circle())
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 50)
                    .frame(maxWidth: .infinity, alignment: .top)
                    
                    // Hero Info
                    VStack(spacing: 8) {
                        HStack(spacing: 8) {
                            Text("\(user.name), \(age)")
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(.white)
                            
                            ZStack {
                                Circle()
                                    .fill(Color.blue)
                                Image(systemName: "checkmark")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            .frame(width: 24, height: 24)
                        }
                        
                        HStack(spacing: 6) {
                            Text(user.flag)
                                .font(.system(size: 18))
                            Text(location)
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white.opacity(0.9))
                        }
                        
                        // Pagination dots
                        HStack(spacing: 6) {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 6, height: 6)
                            Circle()
                                .fill(Color.white.opacity(0.4))
                                .frame(width: 6, height: 6)
                        }
                        .padding(.top, 8)
                    }
                    .padding(.bottom, 40)
                }
                
                // Content Sheet
                VStack(spacing: 0) {
                    // Drag indicator
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 40, height: 4)
                        .padding(.top, 12)
                    
                    VStack(alignment: .leading, spacing: 24) {
                        // Action Buttons
                        HStack(spacing: 12) {
                            actionButton(icon: "person.badge.plus", text: "Add Friend")
                            actionButton(icon: "message.fill", text: "Message")
                        }
                        
                        // About Me
                        section(title: "About Me") {
                            Text("\(user.name) hasn't shared anything yet 🙄")
                                .font(.system(size: 15))
                                .foregroundColor(.gray)
                        }
                        
                        // Badges
                        section(title: "Badges") {
                            HStack {
                                ZStack {
                                    Circle()
                                        .fill(Color.blue)
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(.white)
                                }
                                .frame(width: 24, height: 24)
                                
                                Text("Verified")
                                    .font(.system(size: 14, weight: .bold))
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Color.gray.opacity(0.05))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                            )
                        }
                        
                        // Upcoming Trips
                        section(title: "Upcoming Trips") {
                            HStack(spacing: 16) {
                                Text("🇵🇹")
                                    .font(.system(size: 24))
                                    .frame(width: 48, height: 48)
                                    .background(Color.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .shadow(radius: 2)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Lisbon")
                                        .font(.system(size: 16, weight: .bold))
                                    Text("4 Mar - 16 Mar, 2026")
                                        .font(.system(size: 14))
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                            }
                            .padding(16)
                            .background(Color.gray.opacity(0.05))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        
                        // Travel Stats
                        section(title: "Travel Stats", action: "See More") {
                            VStack(spacing: 16) {
                                // World Map placeholder
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.gray.opacity(0.1))
                                    .frame(height: 180)
                                    .overlay(
                                        Text("🗺️")
                                            .font(.system(size: 48))
                                    )
                                
                                HStack(spacing: 40) {
                                    VStack(spacing: 4) {
                                        Text("7")
                                            .font(.system(size: 32, weight: .bold))
                                            .foregroundColor(.blue)
                                        Text("Countries")
                                            .font(.system(size: 11))
                                            .foregroundColor(.gray)
                                    }
                                    
                                    VStack(spacing: 4) {
                                        ZStack {
                                            Circle()
                                                .stroke(Color.gray.opacity(0.2), lineWidth: 4)
                                            Circle()
                                                .trim(from: 0, to: 0.03)
                                                .stroke(Color.blue, lineWidth: 4)
                                                .rotationEffect(.degrees(-90))
                                            Text("3%")
                                                .font(.system(size: 14, weight: .bold))
                                                .foregroundColor(.blue)
                                        }
                                        .frame(width: 48, height: 48)
                                        
                                        Text("World")
                                            .font(.system(size: 11))
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                        }
                        
                        // Interests
                        section(title: "Interests") {
                            FlowLayout(spacing: 8) {
                                interestTag(icon: "bag.fill", text: "Fashion & Shopping", color: .pink)
                                interestTag(icon: "building.2.fill", text: "Nightlife", color: .blue)
                                interestTag(icon: "tent.fill", text: "Off-Grid Spots", color: .orange)
                                interestTag(icon: "airplane", text: "Spontaneous Trips", color: .blue)
                                interestTag(icon: "briefcase.fill", text: "Living Abroad", color: .brown)
                            }
                        }
                        
                        // Languages
                        section(title: "Languages") {
                            Text("English, French, Mandarin Chinese")
                                .font(.system(size: 14, weight: .bold))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(Color.gray.opacity(0.05))
                                .clipShape(Capsule())
                                .overlay(
                                    Capsule()
                                        .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                                )
                        }
                        
                        Spacer()
                            .frame(height: 100)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 32)
                }
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
                .offset(y: -32)
                }
            }
            .background(Color.white)
            .ignoresSafeArea()
        }
    }
    
    private func actionButton(icon: String, text: String) -> some View {
        Button(action: {}) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                Text(text)
                    .font(.system(size: 15, weight: .bold))
            }
            .foregroundColor(.black)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.gray.opacity(0.05))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
    }
    
    private func section<Content: View>(title: String, action: String? = nil, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title)
                    .font(.system(size: 18, weight: .bold))
                
                Spacer()
                
                if let action = action {
                    Button(action: {}) {
                        Text(action)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.blue)
                    }
                }
            }
            
            content()
        }
    }
    
    private func interestTag(icon: String, text: String, color: Color) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(color)
            Text(text)
                .font(.system(size: 14, weight: .bold))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.gray.opacity(0.05))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
        .clipShape(Capsule())
    }
}

// Flow Layout helper for interests
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        var totalHeight: CGFloat = 0
        var currentRowWidth: CGFloat = 0
        var maxWidth: CGFloat = 0
        
        for size in sizes {
            if currentRowWidth + size.width + spacing > proposal.width ?? 0, currentRowWidth > 0 {
                totalHeight += size.height + spacing
                currentRowWidth = size.width
            } else {
                currentRowWidth += size.width + (currentRowWidth > 0 ? spacing : 0)
            }
            maxWidth = max(maxWidth, currentRowWidth)
        }
        totalHeight += sizes.first?.height ?? 0
        
        return CGSize(width: maxWidth, height: totalHeight)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var currentX = bounds.minX
        var currentY = bounds.minY
        var rowHeight: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            
            if currentX + size.width > bounds.maxX, currentX > bounds.minX {
                currentX = bounds.minX
                currentY += rowHeight + spacing
                rowHeight = 0
            }
            
            subview.place(at: CGPoint(x: currentX, y: currentY), proposal: .unspecified)
            currentX += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}
