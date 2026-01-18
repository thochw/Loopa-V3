//
//  TravelersFilterView.swift
//  ios loopa
//
//  Created by Thomas CHANG-HING-WING on 2026-01-17.
//

import SwiftUI

struct TravelersFilterView: View {
    @Environment(\.dismiss) private var dismiss
    
    // Filter states
    @State private var selectedGenders: Set<String> = []
    @State private var selectedAgeRange: String = "all ages"
    @State private var selectedLifestyle: String = "all lifestyles"
    
    private let genders = ["men", "women"]
    private let ageRanges = ["all ages", "18-25", "26-35", "36-45", "46-55", "56+"]
    private let lifestyles: [(name: String, emoji: String)] = [
        ("all lifestyles", "⭐️"),
        ("backpacking", "🎒"),
        ("digital nomad", "💻"),
        ("gap year", "👋"),
        ("studying abroad", "📚"),
        ("living abroad", "🏠"),
        ("au pair", "🤹")
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("filters")
                                    .font(.system(size: 34, weight: .bold))
                                    .foregroundStyle(.primary)
                                
                                Text("customize what type of travelers you see")
                                    .font(.system(size: 15, weight: .regular))
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                dismiss()
                            }) {
                                Image(systemName: "xmark")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundStyle(.primary)
                                    .frame(width: 44, height: 44)
                                    .background(Color(.systemGray6), in: Circle())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 24)
                    
                    // Filter Sections
                    ScrollView {
                        VStack(spacing: 20) {
                            // Gender Section
                            filterCard(title: "gender", currentState: getGenderState()) {
                                VStack(spacing: 12) {
                                    ForEach(genders, id: \.self) { gender in
                                        genderRow(gender: gender)
                                    }
                                }
                            }
                            
                            // Age Range Section
                            filterCard(title: "age range", currentState: selectedAgeRange == "all ages" ? "showing all ages" : "showing ages \(selectedAgeRange)") {
                                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                                    ForEach(ageRanges, id: \.self) { age in
                                        ageButton(age: age)
                                    }
                                }
                            }
                            
                            // Travel Lifestyle Section
                            filterCard(title: "travel lifestyle", currentState: selectedLifestyle == "all lifestyles" ? "showing all traveler types" : "showing \(selectedLifestyle)") {
                                VStack(spacing: 10) {
                                    ForEach(lifestyles, id: \.name) { lifestyle in
                                        lifestyleButton(lifestyle: lifestyle.name, emoji: lifestyle.emoji)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 100) // Space for bottom buttons
                    }
                    
                    // Bottom Action Buttons
                    VStack(spacing: 0) {
                        Divider()
                        
                        HStack(spacing: 16) {
                            Button(action: {
                                // Reset all filters
                                selectedGenders.removeAll()
                                selectedAgeRange = "all ages"
                                selectedLifestyle = "all lifestyles"
                            }) {
                                Text("reset")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundStyle(.red)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                            }
                            .buttonStyle(.plain)
                            
                            Button(action: {
                                // Apply filters and dismiss
                                dismiss()
                            }) {
                                Text("apply")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundStyle(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(Color.primary, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .background(Color(.systemBackground))
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    private func filterCard<Content: View>(title: String, currentState: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(.primary)
                
                Text(currentState)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(.secondary)
            }
            
            content()
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
    }
    
    private func genderRow(gender: String) -> some View {
        Button(action: {
            if selectedGenders.contains(gender) {
                selectedGenders.remove(gender)
            } else {
                selectedGenders.insert(gender)
            }
        }) {
            HStack {
                Text(gender == "men" ? "🙋‍♂️" : "🙆‍♀️")
                    .font(.system(size: 20))
                
                Text(gender)
                    .font(.system(size: 17, weight: .regular))
                    .foregroundStyle(.primary)
                
                Spacer()
                
                if selectedGenders.contains(gender) {
                    Image(systemName: "checkmark.square.fill")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(.tint)
                } else {
                    Image(systemName: "square")
                        .font(.system(size: 22, weight: .regular))
                        .foregroundStyle(.tertiary)
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
        .buttonStyle(.plain)
    }
    
    private func ageButton(age: String) -> some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedAgeRange = age
            }
        }) {
            Text(age)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(selectedAgeRange == age ? .white : .primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    selectedAgeRange == age
                        ? LinearGradient(
                            colors: [Color.blue, Color.blue.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        : LinearGradient(
                            colors: [Color.white, Color.white],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                    in: RoundedRectangle(cornerRadius: 10, style: .continuous)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .strokeBorder(
                            selectedAgeRange == age ? Color.clear : Color(.systemGray5),
                            lineWidth: 1
                        )
                )
        }
        .buttonStyle(.plain)
    }
    
    private func lifestyleButton(lifestyle: String, emoji: String) -> some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedLifestyle = lifestyle
            }
        }) {
            HStack(spacing: 12) {
                Text(emoji)
                    .font(.system(size: 20))
                
                Text(lifestyle)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(selectedLifestyle == lifestyle ? .white : .primary)
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                selectedLifestyle == lifestyle
                    ? LinearGradient(
                        colors: [Color.blue, Color.blue.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    : LinearGradient(
                        colors: [Color.white, Color.white],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                in: RoundedRectangle(cornerRadius: 12, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(
                        selectedLifestyle == lifestyle ? Color.clear : Color(.systemGray5),
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(.plain)
    }
    
    private func getGenderState() -> String {
        if selectedGenders.isEmpty {
            return "showing everybody"
        } else if selectedGenders.count == 2 {
            return "showing everybody"
        } else {
            return "showing \(selectedGenders.first ?? "")"
        }
    }
}
