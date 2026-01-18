//
//  ExploreView.swift
//  ios loopa
//
//  Created by Thomas CHANG-HING-WING on 2026-01-17.
//

import SwiftUI
import MapKit
import CoreLocation

struct City: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
    let flag: String
}

struct ExploreView: View {
    enum Variant {
        case groups
        case travelers
    }
    
    let variant: Variant
    let onProfileClick: (User) -> Void
    let onAddGroupClick: (CreateType?) -> Void
    
    @State private var isSheetOpen = true
    @State private var groupsViewType: GroupsViewType = .groups
    @StateObject private var locationManager = LocationManager()
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 45.5017, longitude: -73.5673),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    @State private var showCitySearch = false
    @State private var currentCity = "Montréal, Canada"
    @State private var selectedCity: City?
    @State private var showTeleportConfirmation = false
    @State private var showFilters = false
    @State private var selectedLifestyleFilter: String? = nil
    @State private var showCreateOptions = false
    @State private var selectedCreateType: CreateType? = nil
    
    enum CreateType {
        case group
        case event
    }
    
    // Cities database with coordinates
    private let cities: [City] = [
        City(name: "Montréal, Canada", coordinate: CLLocationCoordinate2D(latitude: 45.5017, longitude: -73.5673), flag: "🇨🇦"),
        City(name: "Toronto, Canada", coordinate: CLLocationCoordinate2D(latitude: 43.6532, longitude: -79.3832), flag: "🇨🇦"),
        City(name: "Vancouver, Canada", coordinate: CLLocationCoordinate2D(latitude: 49.2827, longitude: -123.1207), flag: "🇨🇦"),
        City(name: "New York, USA", coordinate: CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060), flag: "🇺🇸"),
        City(name: "Los Angeles, USA", coordinate: CLLocationCoordinate2D(latitude: 34.0522, longitude: -118.2437), flag: "🇺🇸"),
        City(name: "San Francisco, USA", coordinate: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), flag: "🇺🇸"),
        City(name: "Paris, France", coordinate: CLLocationCoordinate2D(latitude: 48.8566, longitude: 2.3522), flag: "🇫🇷"),
        City(name: "London, UK", coordinate: CLLocationCoordinate2D(latitude: 51.5074, longitude: -0.1278), flag: "🇬🇧"),
        City(name: "Tokyo, Japan", coordinate: CLLocationCoordinate2D(latitude: 35.6762, longitude: 139.6503), flag: "🇯🇵"),
        City(name: "Sydney, Australia", coordinate: CLLocationCoordinate2D(latitude: -33.8688, longitude: 151.2093), flag: "🇦🇺"),
        City(name: "Berlin, Germany", coordinate: CLLocationCoordinate2D(latitude: 52.5200, longitude: 13.4050), flag: "🇩🇪"),
        City(name: "Barcelona, Spain", coordinate: CLLocationCoordinate2D(latitude: 41.3851, longitude: 2.1734), flag: "🇪🇸"),
        City(name: "Rome, Italy", coordinate: CLLocationCoordinate2D(latitude: 41.9028, longitude: 12.4964), flag: "🇮🇹"),
        City(name: "Amsterdam, Netherlands", coordinate: CLLocationCoordinate2D(latitude: 52.3676, longitude: 4.9041), flag: "🇳🇱"),
        City(name: "Lisbon, Portugal", coordinate: CLLocationCoordinate2D(latitude: 38.7223, longitude: -9.1393), flag: "🇵🇹"),
        City(name: "Bangkok, Thailand", coordinate: CLLocationCoordinate2D(latitude: 13.7563, longitude: 100.5018), flag: "🇹🇭"),
        City(name: "Dubai, UAE", coordinate: CLLocationCoordinate2D(latitude: 25.2048, longitude: 55.2708), flag: "🇦🇪"),
        City(name: "Singapore", coordinate: CLLocationCoordinate2D(latitude: 1.3521, longitude: 103.8198), flag: "🇸🇬"),
        City(name: "Seoul, South Korea", coordinate: CLLocationCoordinate2D(latitude: 37.5665, longitude: 126.9780), flag: "🇰🇷"),
        City(name: "Mexico City, Mexico", coordinate: CLLocationCoordinate2D(latitude: 19.4326, longitude: -99.1332), flag: "🇲🇽")
    ]
    
    enum GroupsViewType: String, CaseIterable {
        case groups = "Groups"
        case events = "Events"
    }
    
    private let data = AppData.shared
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Map
                Map(coordinateRegion: $region, showsUserLocation: true, annotationItems: annotations) { item in
                    MapAnnotation(coordinate: item.coordinate) {
                        annotationView(for: item)
                    }
                }
                .ignoresSafeArea()
                .onAppear {
                    locationManager.requestLocationPermission()
                    locationManager.startUpdatingLocation()
                }
                .onChange(of: locationManager.location) { oldValue, newValue in
                    if let newLocation = newValue, region.center.latitude == 45.5017 && region.center.longitude == -73.5673 {
                        // Only update if we're still at the default location
                        withAnimation {
                            region.center = newLocation.coordinate
                        }
                    }
                }
                
                // Header
                VStack {
                    headerView
                    Spacer()
                }
                
                // Bottom Sheet
                VStack {
                    Spacer()
                    bottomSheet
                        .frame(height: isSheetOpen ? sheetHeight(for: geometry.size.height) : 0)
                        .offset(y: isSheetOpen ? 0 : sheetHeight(for: geometry.size.height))
                        .padding(.horizontal, 16) // Match navigation bar width
                }
                .ignoresSafeArea(edges: .bottom)
                
                // Tap to dismiss pastilles (behind buttons but above map)
                if showCreateOptions && variant == .groups {
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                showCreateOptions = false
                            }
                        }
                        .ignoresSafeArea()
                }
                
                // Floating Action Buttons (Right Side) - Only for Groups variant
                if variant == .groups {
                    HStack(spacing: 12) {
                        // Create Options Pills (Groups/Events) - Vertical Stack
                        if showCreateOptions {
                            VStack(spacing: 8) {
                                // Groups Pill
                                Button(action: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        selectedCreateType = .group
                                        showCreateOptions = false
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                            onAddGroupClick(.group)
                                        }
                                    }
                                }) {
                                    Text("Create group")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 10)
                                        .background(Color.appAccent, in: Capsule())
                                        .shadow(color: Color.appAccent.opacity(0.4), radius: 8, y: 4)
                                }
                                .buttonStyle(.plain)
                                
                                // Events Pill
                                Button(action: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        selectedCreateType = .event
                                        showCreateOptions = false
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                            onAddGroupClick(.event)
                                        }
                                    }
                                }) {
                                    Text("Create event")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 10)
                                        .background(Color.appAccent, in: Capsule())
                                        .shadow(color: Color.appAccent.opacity(0.4), radius: 8, y: 4)
                                }
                                .buttonStyle(.plain)
                            }
                            .transition(.scale.combined(with: .opacity))
                        }
                        
                        VStack(spacing: 12) {
                            // Recenter Map Button (on top)
                            Button(action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    region.center = CLLocationCoordinate2D(latitude: 45.5017, longitude: -73.5673)
                                }
                            }) {
                                Image(systemName: "location.fill")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundStyle(.black)
                                    .frame(width: 56, height: 56)
                                    .background(
                                        .regularMaterial,
                                        in: Circle()
                                    )
                                    .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
                            }
                            
                            // Add Group Button (below, white on blue)
                            Button(action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    showCreateOptions.toggle()
                                }
                            }) {
                                Image(systemName: showCreateOptions ? "xmark" : "plus")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundStyle(.white)
                                    .frame(width: 56, height: 56)
                                    .background(
                                        Color.appAccent,
                                        in: Circle()
                                    )
                                    .shadow(color: Color.appAccent.opacity(0.4), radius: 12, y: 6)
                                    .rotationEffect(.degrees(showCreateOptions ? 45 : 0))
                            }
                        }
                    }
                    .padding(.trailing, 20)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .offset(y: isSheetOpen ? -sheetHeight(for: geometry.size.height) + 350 : 250)
                }
                
                // Show Groups Button (when sheet is closed and pastilles are not open)
                if !isSheetOpen && !showCreateOptions {
                    VStack {
                        Spacer()
                        Button(action: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                isSheetOpen = true
                            }
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "list.bullet")
                                    .font(.system(size: 16, weight: .semibold))
                                Text(variant == .groups ? "Show Groups" : "Show Travelers")
                                    .font(.system(size: 15, weight: .semibold))
                            }
                            .foregroundStyle(.black)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(
                                .regularMaterial,
                                in: Capsule()
                            )
                            .shadow(color: .black.opacity(0.15), radius: 12, y: 4)
                        }
                        .padding(.bottom, 80)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
            }
            .sheet(isPresented: $showCitySearch) {
                CitySearchView(
                    cities: cities,
                    currentCity: currentCity,
                    onCitySelected: { city in
                        selectedCity = city
                        showTeleportConfirmation = true
                        showCitySearch = false
                    }
                )
            }
            .alert("Téléporter la carte ?", isPresented: $showTeleportConfirmation) {
                Button("Annuler", role: .cancel) {
                    selectedCity = nil
                }
                Button("Téléporter") {
                    if let city = selectedCity {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            currentCity = city.name
                            region.center = city.coordinate
                        }
                    }
                    selectedCity = nil
                }
            } message: {
                if let city = selectedCity {
                    Text("Voulez-vous vraiment téléporter la carte vers \(city.name) ?")
                }
            }
            .sheet(isPresented: $showFilters) {
                TravelersFilterView()
            }
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 12) {
            if variant == .groups {
                groupsHeader
            } else {
                travelersHeader
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 0)
        .safeAreaInset(edge: .top) {
            Color.clear.frame(height: 0)
        }
    }
    
    private var groupsHeader: some View {
        HStack(spacing: 12) {
            // Search Bar for Location (compact and less prominent)
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                    showCitySearch = true
                }
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.secondary)
                    
                    Text(getCityFlag(from: currentCity))
                        .font(.system(size: 14))
                    
                    Text(getCityName(from: currentCity))
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.primary)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(Color.white)
                .clipShape(Capsule())
                .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
            }
            .buttonStyle(.plain)
            
            Spacer()
            
            HStack(spacing: 8) {
                iconButton(icon: "eye.fill", color: .secondary)
                
                // Notification button with badge
                Button(action: {}) {
                    ZStack(alignment: .topTrailing) {
                        iconButton(icon: "bell.fill", color: .secondary)
                        Circle()
                            .fill(Color.red)
                            .frame(width: 10, height: 10)
                            .offset(x: 6, y: -6)
                    }
                }
                
                // Profile button
                Button(action: {}) {
                    AsyncImage(url: URL(string: "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?ixlib=rb-4.0.3&auto=format&fit=crop&w=200&q=80")) { phase in
                        if let image = phase.image {
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } else if phase.error != nil {
                            Image(systemName: "person.circle.fill")
                                .foregroundStyle(.secondary)
                        } else {
                            ProgressView()
                                .tint(.secondary)
                        }
                    }
                    .frame(width: 44, height: 44) // HIG minimum touch target
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .strokeBorder(Color.white.opacity(0.3), lineWidth: 2.5)
                    )
                    .shadow(color: .black.opacity(0.15), radius: 4, y: 2)
                }
            }
        }
    }
    
    private var travelersHeader: some View {
        VStack(spacing: 12) {
            // Enhanced Search Bar
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                    showCitySearch = true
                }
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.secondary)
                    
                    Text(getCityName(from: currentCity))
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.primary)
                    
                    Spacer()
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 14)
                .background(.regularMaterial)
                .clipShape(Capsule())
                .shadow(color: .black.opacity(0.1), radius: 8, y: 2)
            }
            .buttonStyle(.plain)
            
            // Enhanced Filter Chips with better spacing
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                            showFilters = true
                        }
                    }) {
                        filterChipContent(icon: "slider.horizontal.3", text: "Filter", isPrimary: true)
                    }
                    .buttonStyle(.plain)
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedLifestyleFilter = selectedLifestyleFilter == "backpacking" ? nil : "backpacking"
                        }
                    }) {
                        filterChipContent(emoji: "🎒", text: "backpacking", isSelected: selectedLifestyleFilter == "backpacking")
                    }
                    .buttonStyle(.plain)
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedLifestyleFilter = selectedLifestyleFilter == "digital nomad" ? nil : "digital nomad"
                        }
                    }) {
                        filterChipContent(emoji: "💻", text: "digital nomad", isSelected: selectedLifestyleFilter == "digital nomad")
                    }
                    .buttonStyle(.plain)
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedLifestyleFilter = selectedLifestyleFilter == "gap year" ? nil : "gap year"
                        }
                    }) {
                        filterChipContent(emoji: "👋", text: "gap year", isSelected: selectedLifestyleFilter == "gap year")
                    }
                    .buttonStyle(.plain)
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedLifestyleFilter = selectedLifestyleFilter == "studying abroad" ? nil : "studying abroad"
                        }
                    }) {
                        filterChipContent(emoji: "📚", text: "studying abroad", isSelected: selectedLifestyleFilter == "studying abroad")
                    }
                    .buttonStyle(.plain)
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedLifestyleFilter = selectedLifestyleFilter == "living abroad" ? nil : "living abroad"
                        }
                    }) {
                        filterChipContent(emoji: "🏠", text: "living abroad", isSelected: selectedLifestyleFilter == "living abroad")
                    }
                    .buttonStyle(.plain)
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedLifestyleFilter = selectedLifestyleFilter == "au pair" ? nil : "au pair"
                        }
                    }) {
                        filterChipContent(emoji: "🤹", text: "au pair", isSelected: selectedLifestyleFilter == "au pair")
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 4)
            }
        }
    }
    
    private func filterChipContent(icon: String? = nil, emoji: String? = nil, text: String, isPrimary: Bool = false, isSelected: Bool = false) -> some View {
        HStack(spacing: 6) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .medium))
            }
            if let emoji = emoji {
                Text(emoji)
                    .font(.system(size: 16))
            }
            Text(text)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(isSelected ? .white : .primary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            isSelected
                ? AnyShapeStyle(Color.appAccent)
                : AnyShapeStyle(.regularMaterial),
            in: Capsule()
        )
        .overlay(
            Capsule()
                .strokeBorder(
                    isSelected ? Color.clear : Color(.systemGray5).opacity(0.3),
                    lineWidth: 1
                )
        )
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }
    
    private func getCityName(from cityString: String) -> String {
        // Extract just the city name (before comma)
        let components = cityString.components(separatedBy: ", ")
        return components.first ?? cityString
    }
    
    private func getCityFlag(from cityString: String) -> String {
        // Find the corresponding flag from the cities array
        if let city = cities.first(where: { $0.name == cityString }) {
            return city.flag
        }
        return "🇨🇦" // Default flag (Canada/Montreal)
    }
    
    private func iconButton(icon: String, color: Color = .secondary) -> some View {
        Button(action: {}) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(color)
                .frame(width: 38, height: 38) // HIG minimum touch target
                .background(Color.white)
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
        }
        .buttonStyle(.plain)
    }
    
    private var bottomSheet: some View {
        VStack(spacing: 0) {
            // Enhanced Drag Handle
            RoundedRectangle(cornerRadius: 2.5)
                .fill(Color.secondary.opacity(0.4))
                .frame(width: 36, height: 5)
                .padding(.top, 12)
                .padding(.bottom, 4)
            
            ScrollView {
                if variant == .groups {
                    groupsContent
                } else {
                    travelersContent
                }
            }
            .padding(.top, 4)
        }
        .background(Color.white)
        .clipShape(UnevenRoundedRectangle(
            cornerRadii: .init(
                topLeading: 28,
                bottomLeading: 24,
                bottomTrailing: 24,
                topTrailing: 28
            ),
            style: .continuous
        ))
        .shadow(color: .black.opacity(0.15), radius: 30, y: -8)
        .padding(.bottom, 100) // Space for navigation bar
        .gesture(
            DragGesture()
                .onChanged { value in
                    // Smooth drag feedback
                }
                .onEnded { value in
                    if value.translation.height > 100 {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            isSheetOpen = false
                        }
                    } else {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            isSheetOpen = true
                        }
                    }
                }
        )
    }
    
    private func sheetHeight(for screenHeight: CGFloat) -> CGFloat {
        // Increased height for better visibility
        return variant == .groups ? screenHeight * 0.50 : screenHeight * 0.55
    }
    
    private var groupsContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Segmented Control for Groups/Events Toggle
            Picker("View Type", selection: $groupsViewType) {
                ForEach(GroupsViewType.allCases, id: \.self) { type in
                    Text(type.rawValue).tag(type)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 20)
            .padding(.top, 8)
            
            if groupsViewType == .groups {
                groupsView
            } else {
                eventsView
            }
        }
        .padding(.bottom, 20)
        .padding(.top, 0)
    }
    
    private var groupsView: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("3 Nearby Groups")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(.primary)
                .padding(.horizontal, 20)
            
            ForEach(data.groups) { group in
                groupRow(group: group)
                    .padding(.horizontal, 20)
            }
        }
    }
    
    private var eventsView: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Upcoming Events")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(.primary)
                .padding(.horizontal, 20)
            
            // Placeholder for events - will need Event model
            VStack(spacing: 16) {
                eventPlaceholderCard(
                    title: "Art Gallery Opening",
                    date: "Tomorrow, 7:00 PM",
                    location: "Montreal Art Gallery"
                )
                .padding(.horizontal, 20)
                
                eventPlaceholderCard(
                    title: "Food Festival",
                    date: "Friday, 12:00 PM",
                    location: "Old Port"
                )
                .padding(.horizontal, 20)
                
                eventPlaceholderCard(
                    title: "Music Night",
                    date: "Saturday, 9:00 PM",
                    location: "Jazz Club"
                )
                .padding(.horizontal, 20)
            }
        }
    }
    
    private func eventPlaceholderCard(title: String, date: String, location: String) -> some View {
        Button(action: {}) {
            HStack(spacing: 16) {
                // Event icon placeholder
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.appAccent.opacity(0.1))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: "calendar")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(Color.appAccent)
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.primary)
                    
                    HStack(spacing: 8) {
                        Label(date, systemImage: "clock")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack(spacing: 8) {
                        Label(location, systemImage: "mappin.circle.fill")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(.secondary)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.secondary)
            }
            .padding(16)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(Color.secondary.opacity(0.1), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
    
    private func groupRow(group: Group) -> some View {
        Button(action: {}) {
            HStack(spacing: 16) {
                // Enhanced group image with rounded rectangle style
                AsyncImage(url: URL(string: group.image)) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else if phase.error != nil {
                        ZStack {
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(Color(.systemGray5))
                            
                            Image(systemName: "person.3.fill")
                                .font(.system(size: 24, weight: .medium))
                                .foregroundStyle(.secondary)
                        }
                    } else {
                        ZStack {
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(Color(.systemGray6))
                            
                            ProgressView()
                                .tint(.secondary)
                        }
                    }
                }
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(Color(.systemGray5).opacity(0.3), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.08), radius: 6, y: 3)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(group.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.primary)
                        .lineLimit(2)
                    
                    HStack(spacing: 8) {
                        avatarStack(avatars: group.avatars)
                        
                        Text("\(group.attendees) Travelers")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(.ultraThinMaterial)
                            .clipShape(Capsule())
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.tertiary)
            }
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
    
    private var filteredUsers: [User] {
        guard let lifestyleFilter = selectedLifestyleFilter else {
            return data.users
        }
        // Filter users by selected lifestyle
        return data.users.filter { user in
            user.lifestyle?.lowercased() == lifestyleFilter.lowercased()
        }
    }
    
    private var travelersContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("\(filteredUsers.count) Nearby Travelers")
                    .font(.system(size: 22, weight: .bold))
                Spacer()
                Button("See All") {
                    // Handle see all
                }
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.blue)
            }
            .padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(filteredUsers) { user in
                        travelerCard(user: user)
                    }
                }
                .padding(.horizontal, 20)
            }
            
            Button(action: {}) {
                Text("See all 468 Nearby Travelers")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
    }
    
    private func travelerCard(user: User) -> some View {
        Button(action: {
            onProfileClick(user)
        }) {
            ZStack(alignment: .bottomLeading) {
                AsyncImage(url: URL(string: user.image)) { image in
                    image.resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color.gray.opacity(0.3)
                }
                .frame(width: 130, height: 170)
                
                // Gradient overlay
                LinearGradient(
                    colors: [.black.opacity(0.8), .clear],
                    startPoint: .bottom,
                    endPoint: .top
                )
                .frame(height: 80)
                .offset(y: 45)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(user.flag)
                        .font(.system(size: 18))
                        .offset(y: -145)
                        .padding(.leading, 10)
                        .padding(.top, 10)
                    
                    HStack(spacing: 6) {
                        Text(user.name)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                        Circle()
                            .fill(Color.green)
                            .frame(width: 8, height: 8)
                    }
                    .offset(y: -10)
                    
                    Text(user.distance)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white.opacity(0.9))
                        .offset(y: -10)
                }
                .padding(.leading, 12)
                .padding(.bottom, 12)
            }
            .frame(width: 130, height: 170)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.1), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
    
    private func avatarStack(avatars: [String]) -> some View {
        HStack(spacing: -8) {
            ForEach(Array(avatars.prefix(3).enumerated()), id: \.offset) { _, avatar in
                AsyncImage(url: URL(string: avatar)) { image in
                    image.resizable()
                } placeholder: {
                    Color.gray.opacity(0.3)
                }
                .frame(width: 24, height: 24)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white, lineWidth: 2))
            }
        }
    }
    
    // MARK: - Annotations
    private var annotations: [AnnotationItem] {
        switch variant {
        case .groups:
            return data.groups.map { AnnotationItem(id: $0.id, coordinate: $0.coordinate, type: .group($0)) }
        case .travelers:
            return data.users.map { AnnotationItem(id: $0.id, coordinate: $0.coordinate, type: .user($0)) }
        }
    }
    
    private func annotationView(for item: AnnotationItem) -> some View {
        switch item.type {
        case .group(let group):
            return AnyView(groupAnnotation(group: group))
        case .user(let user):
            return AnyView(userAnnotation(user: user))
        }
    }
    
    private func groupAnnotation(group: Group) -> some View {
        HStack(spacing: 0) {
            AsyncImage(url: URL(string: group.image)) { image in
                image.resizable()
            } placeholder: {
                Color.gray.opacity(0.3)
            }
            .frame(width: 48, height: 48)
            .clipShape(Circle())
            .background(Circle().fill(Color.white).padding(2))
            
            Text(group.title)
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(.black)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .padding(.horizontal, 8)
                .offset(x: -4)
        }
    }
    
    private func userAnnotation(user: User) -> some View {
        ZStack {
            AsyncImage(url: URL(string: user.image)) { image in
                image.resizable()
            } placeholder: {
                Color.gray.opacity(0.3)
            }
            .frame(width: 48, height: 48)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.white, lineWidth: 2))
            
            Circle()
                .fill(Color.green)
                .frame(width: 12, height: 12)
                .offset(x: 16, y: -16)
        }
        .onTapGesture {
            onProfileClick(user)
        }
    }
    
    private struct AnnotationItem: Identifiable {
        let id: Int
        let coordinate: CLLocationCoordinate2D
        let type: AnnotationType
        
        enum AnnotationType {
            case group(Group)
            case user(User)
        }
    }
}
