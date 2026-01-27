//
//  HousingView.swift
//  ios loopa
//
//  Created by Thomas CHANG-HING-WING on 2026-01-17.
//

import SwiftUI
import MapKit

enum HousingTab: String, CaseIterable {
    case spots = "Housing"
    case roommates = "Roommates"
}

struct HousingView: View {
    @State private var activeTab: HousingTab = .spots
    @State private var showMapView = false
    @State private var selectedMapFilter: String? = nil
    @State private var showSearchFlow = false
    @State private var showCreateSheet = false
    @State private var showCreateTripSheet = false
    @State private var showTripsList = false
    @State private var selectedTripForHousing: Trip?
    @State private var selectedHousingSpot: HousingSpot? = nil
    @State private var selectedRoommate: Roommate? = nil
    @State private var mapRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 45.5017, longitude: -73.5673),
        span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08)
    )
    @State private var housingSpots: [HousingSpot] = AppData.shared.housingSpots
    @State private var roommates: [Roommate] = AppData.shared.roommates
    @State private var trips: [Trip] = [
        Trip(
            destination: "Bali",
            startDate: Calendar.current.date(from: DateComponents(year: 2026, month: 1, day: 17)) ?? Date(),
            endDate: Calendar.current.date(from: DateComponents(year: 2026, month: 2, day: 23)) ?? Date(),
            imageUrl: "https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=1200&q=80"
        )
    ]
    private let data = AppData.shared
    
    var body: some View {
        VStack(spacing: 0) {
            myTripHeader

            // Enhanced Content with smooth transitions
            ZStack(alignment: .top) {
                if showMapView {
                    housingMapContent
                        .transition(.opacity.combined(with: .move(edge: .trailing)))
                } else {
                    Color.white
                        .ignoresSafeArea()
                    
                    ScrollView {
                        LazyVStack(spacing: 24) {
                            upcomingTripsSection
                            recommendedHousingSection
                            findRoommatesSection
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 120)
                    }
                    .id(activeTab)
                    .transition(.opacity.combined(with: .move(edge: .leading)))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .animation(.easeInOut(duration: 0.25), value: showMapView)
        }
        .background(Color(.systemGroupedBackground))
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: activeTab)
        .sheet(isPresented: $showSearchFlow) {
            HousingSearchFlowView(activeTab: $activeTab) {
                showSearchFlow = false
            }
        }
        .sheet(isPresented: $showCreateSheet) {
            CreateHousingListingView(activeTab: $activeTab, coordinate: mapRegion.center) { spot in
                housingSpots.insert(spot, at: 0)
            } onCreateRoommate: { roommate in
                roommates.insert(roommate, at: 0)
            } onClose: {
                showCreateSheet = false
            }
        }
        .sheet(isPresented: $showCreateTripSheet) {
            CreateTripView { trip in
                trips.insert(trip, at: 0)
                showCreateTripSheet = false
            } onClose: {
                showCreateTripSheet = false
            }
        }
        .sheet(isPresented: $showTripsList) {
            UpcomingTripsListView(trips: $trips) {
                showTripsList = false
            }
        }
        .sheet(item: $selectedHousingSpot) { spot in
            HousingDetailSheet(spot: spot, onClose: {
                selectedHousingSpot = nil
            })
        }
        .sheet(item: $selectedRoommate) { roommate in
            RoommateDetailSheet(roommate: roommate, onClose: {
                selectedRoommate = nil
            })
        }
        .sheet(item: $selectedTripForHousing) { trip in
            RecommendedHousingMapView(
                trip: trip,
                spots: housingSpots,
                avatarImages: data.users.map(\.image),
                onClose: { selectedTripForHousing = nil }
            )
        }
    }

    private var myTripHeader: some View {
        HStack {
            Text("My trip")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(.primary)

            Spacer()

            Button(action: {
                showCreateTripSheet = true
            }) {
                Image(systemName: "plus")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
                    .background(Color.appAccent, in: Circle())
                    .shadow(color: Color.appAccent.opacity(0.3), radius: 8, y: 4)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
    }

    private var housingHeroSection: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                Button(action: {
                    showSearchFlow = true
                }) {
                    HStack(spacing: 10) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.secondary)
                        Text("Start my search")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                    .padding(.horizontal, 18)
                    .padding(.vertical, 14)
                    .background(Color.white, in: Capsule())
                    .shadow(color: .black.opacity(0.16), radius: 16, y: 10)
                }
                .buttonStyle(.plain)

                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        showMapView.toggle()
                    }
                }) {
                    Image(systemName: showMapView ? "list.bullet" : "map.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 48, height: 48)
                        .background(Color(hex: "222222"), in: Circle())
                        .shadow(color: .black.opacity(0.12), radius: 10, y: 6)
                }
                .buttonStyle(.plain)
            }

            HStack(alignment: .bottom, spacing: 80) {
                ForEach(HousingTab.allCases, id: \.self) { tab in
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            activeTab = tab
                        }
                    }) {
                        HousingTabLabel(
                            text: tabLabel(for: tab),
                            isActive: activeTab == tab
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 0)
        .background(Color(.systemBackground))
        .safeAreaInset(edge: .top) {
            Color.clear.frame(height: 0)
        }
    }

    private var upcomingTripsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(title: "Upcoming Trips", actionText: "See All") {
                showTripsList = true
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(trips) { trip in
                        tripCard(trip: trip)
                    }
                }
                .padding(.horizontal, 2)
            }
        }
    }

    private var recommendedHousingSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(title: "Recommended Housing", actionText: "See All") {
                if let nextTrip {
                    selectedTripForHousing = nextTrip
                }
            }

            VStack(spacing: 12) {
                ForEach(housingSpots.prefix(3)) { spot in
                    recommendedHousingRow(spot: spot)
                }
            }

            Button(action: {
                showCreateSheet = true
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "plus")
                        .font(.system(size: 15, weight: .semibold))
                    Text("Add new recommendation")
                        .font(.system(size: 15, weight: .semibold))
                }
                .foregroundStyle(Color.appAccent)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(Color.appAccent.opacity(0.5), lineWidth: 1.2)
                )
            }
            .buttonStyle(.plain)
        }
    }

    private var findRoommatesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(title: "Find Roommates", actionText: "See All") {}

            VStack(spacing: 12) {
                ForEach(roommates.prefix(4)) { roommate in
                    roommateListRow(roommate: roommate)
                }
            }
        }
    }

    private func sectionHeader(title: String, actionText: String, action: @escaping () -> Void) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.primary)
            Spacer()
            Button(action: action) {
                Text(actionText)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.appAccent)
            }
            .buttonStyle(.plain)
        }
    }

    private func tripCard(trip: Trip) -> some View {
        let countdown = daysUntil(trip.startDate)
        let avatarImages = data.users.map(\.image).prefix(5)
        let dateLabel = "\(shortDate(trip.startDate)) - \(shortDate(trip.endDate))"
        let statusText = tripStatusText(start: trip.startDate, end: trip.endDate)

        return ZStack(alignment: .bottomLeading) {
            AsyncImage(url: URL(string: trip.imageUrl)) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    Color(.systemGray5)
                }
            }
            .frame(width: 300, height: 190)
            .clipped()

            LinearGradient(
                colors: [.black.opacity(0.35), .clear],
                startPoint: .bottom,
                endPoint: .top
            )
            .frame(height: 100)
            .frame(maxWidth: .infinity, alignment: .bottom)

            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("🌍 \(trip.destination)")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                    Spacer()
                    Text(dateLabel.uppercased())
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.9))
                }

                HStack(spacing: 8) {
                    avatarStack(images: Array(avatarImages))
                    Text(statusText ?? "+\(countdown) days")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.white.opacity(0.18), in: Capsule())
                }
            }
            .padding(14)
        }
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: .black.opacity(0.1), radius: 12, y: 6)
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(Color.black.opacity(0.05), lineWidth: 1)
        )
    }

    private func recommendedHousingRow(spot: HousingSpot) -> some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: spot.image)) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    Color(.systemGray5)
                }
            }
            .frame(width: 64, height: 64)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text(spot.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                Text(spot.type)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            HStack(spacing: -6) {
                avatarStack(images: Array(data.users.prefix(3).map(\.image)))
                Text("\(max(20, Int(spot.rating * 50)))+")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.primary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(Color(.systemGray6), in: Capsule())
            }
        }
        .padding(12)
        .background(Color(.systemGray6).opacity(0.6), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func roommateListRow(roommate: Roommate) -> some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: roommate.image)) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    Color(.systemGray5)
                }
            }
            .frame(width: 44, height: 44)
            .clipShape(Circle())
            .overlay(Circle().strokeBorder(Color.white, lineWidth: 2))

            VStack(alignment: .leading, spacing: 4) {
                Text("\(roommate.name), \(roommate.age)")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.primary)
                Text("Move in \(roommate.moveIn)")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button(action: {}) {
                Text("Say hello 👋")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.appAccent)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .strokeBorder(Color.appAccent.opacity(0.6), lineWidth: 1.2)
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 6)
        .contentShape(Rectangle())
        .onTapGesture {
            selectedRoommate = roommate
            selectedHousingSpot = nil
        }
    }

    private func avatarStack(images: [String]) -> some View {
        HStack(spacing: -8) {
            ForEach(Array(images.prefix(4).enumerated()), id: \.offset) { _, imageUrl in
                AsyncImage(url: URL(string: imageUrl)) { phase in
                    if let image = phase.image {
                        image.resizable()
                    } else {
                        Color(.systemGray5)
                    }
                }
                .frame(width: 26, height: 26)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white, lineWidth: 2))
            }
        }
    }

    private var nextTrip: Trip? {
        trips.sorted { $0.startDate < $1.startDate }.first
    }

    private func daysUntil(_ date: Date) -> Int {
        let days = Calendar.current.dateComponents([.day], from: Date(), to: date).day ?? 0
        return max(days, 0)
    }

    private func shortDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }

    private func tripStatusText(start: Date, end: Date) -> String? {
        let now = Date()
        if now >= start && now <= end {
            return "Happening now"
        }
        return nil
    }

    private struct Trip: Identifiable {
        let id = UUID()
        let destination: String
        let startDate: Date
        let endDate: Date
        let imageUrl: String
    }

    private struct CreateTripView: View {
        let onCreate: (Trip) -> Void
        let onClose: () -> Void

        @State private var destination = ""
        @State private var startDate = Date()
        @State private var endDate = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()

        var body: some View {
            NavigationStack {
                VStack(spacing: 16) {
                    HStack {
                        Text("New trip")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(.primary)
                        Spacer()
                        Button(action: onClose) {
                            Image(systemName: "xmark")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(.secondary)
                                .frame(width: 34, height: 34)
                                .background(Color(.systemGray6), in: Circle())
                        }
                        .buttonStyle(.plain)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Destination")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.secondary)
                        TextField("Where are you going?", text: $destination)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 12)
                            .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Dates")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.secondary)
                        DatePicker("Start", selection: $startDate, displayedComponents: .date)
                            .datePickerStyle(.compact)
                        DatePicker("End", selection: $endDate, in: startDate..., displayedComponents: .date)
                            .datePickerStyle(.compact)
                    }

                    Spacer()

                    Button(action: createTrip) {
                        Text("Add trip")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(canCreate ? Color.appAccent : Color(.systemGray4), in: Capsule())
                    }
                    .buttonStyle(.plain)
                    .disabled(!canCreate)
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 24)
            }
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }

        private var canCreate: Bool {
            !destination.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }

        private func createTrip() {
            let safeDestination = destination.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !safeDestination.isEmpty else { return }
            let newTrip = Trip(
                destination: safeDestination,
                startDate: startDate,
                endDate: endDate,
                imageUrl: "https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=1200&q=80"
            )
            onCreate(newTrip)
        }
    }

    private struct UpcomingTripsListView: View {
        @Binding var trips: [Trip]
        let onClose: () -> Void

        var body: some View {
            NavigationStack {
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(trips) { trip in
                            UpcomingTripRow(trip: trip) {
                                trips.removeAll { $0.id == trip.id }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 24)
                }
                .navigationTitle("My Upcoming Trips")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: onClose) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(.primary)
                                .frame(width: 36, height: 36)
                                .background(Color(.systemGray6), in: Circle())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private struct UpcomingTripRow: View {
        let trip: Trip
        let onDelete: () -> Void
        @State private var showDeletePopover = false
        private var dateLabel: String {
            "\(shortDate(trip.startDate)) - \(shortDate(trip.endDate))"
        }
        private var destinationTitle: String {
            trip.destination.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        private var destinationSubtitle: String {
            let components = trip.destination.split(separator: ",")
            if components.count >= 2 {
                return components.last?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "Destination"
            }
            return "Destination"
        }

        var body: some View {
            ZStack(alignment: .topTrailing) {
                ZStack(alignment: .bottomLeading) {
                    AsyncImage(url: URL(string: trip.imageUrl)) { phase in
                        if let image = phase.image {
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } else {
                            Color(.systemGray5)
                        }
                    }
                    .frame(height: 180)
                    .frame(maxWidth: .infinity)
                    .clipped()

                    LinearGradient(
                        colors: [.black.opacity(0.4), .clear],
                        startPoint: .bottom,
                        endPoint: .top
                    )
                    .frame(height: 90)

                    VStack(alignment: .leading, spacing: 6) {
                        Text(destinationTitle)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(.white)

                        Text(destinationSubtitle)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.white.opacity(0.9))
                    }
                    .padding(14)
                }
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

                Text(dateLabel)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.black.opacity(0.4), in: Capsule())
                    .padding(.trailing, 12)
                    .padding(.bottom, 12)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)

                Button(action: { showDeletePopover = true }) {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 32, height: 32)
                        .background(Color.black.opacity(0.45), in: Circle())
                }
                .popover(isPresented: $showDeletePopover, attachmentAnchor: .rect(.bounds), arrowEdge: .top) {
                    VStack(alignment: .leading, spacing: 8) {
                        Button(role: .destructive, action: {
                            showDeletePopover = false
                            onDelete()
                        }) {
                            Label("Delete trip", systemImage: "trash")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(12)
                    .background(.ultraThinMaterial)
                    .presentationCompactAdaptation(.popover)
                }
                .padding(.trailing, 12)
                .padding(.top, 12)
            }
            .shadow(color: .black.opacity(0.08), radius: 10, y: 5)
        }

        private func shortDate(_ date: Date) -> String {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"
            return formatter.string(from: date)
        }
    }

    private struct RecommendedHousingMapView: View {
        let trip: Trip
        let spots: [HousingSpot]
        let avatarImages: [String]
        let onClose: () -> Void

        @State private var region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 45.5017, longitude: -73.5673),
            span: MKCoordinateSpan(latitudeDelta: 0.25, longitudeDelta: 0.25)
        )
        @State private var hasAnimated = false

        var body: some View {
            ZStack(alignment: .top) {
                Map(coordinateRegion: $region)
                    .mapStyle(.standard)
                    .ignoresSafeArea()
                    .onAppear {
                        animateToTrip()
                    }

                HStack {
                    Button(action: onClose) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.primary)
                            .frame(width: 36, height: 36)
                            .background(Color.white.opacity(0.9), in: Circle())
                    }
                    .buttonStyle(.plain)

                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)

                VStack(spacing: 0) {
                    Spacer()
                    sheetContent
                }
            }
        }

        private var sheetContent: some View {
            VStack(spacing: 16) {
                RoundedRectangle(cornerRadius: 2.5)
                    .fill(Color.secondary.opacity(0.4))
                    .frame(width: 36, height: 5)
                    .padding(.top, 10)

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(tripTitle)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(.primary)
                        Spacer()
                        Text(tripSubtitle)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.secondary)
                    }

                    HStack(spacing: 8) {
                        Image(systemName: "calendar")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.secondary)
                        Text(tripDateLabel)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal, 20)

                VStack(alignment: .leading, spacing: 12) {
                    Text("Recommended Housing")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(.primary)

                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(spots) { spot in
                                recommendedHousingRow(spot: spot)
                            }
                        }
                    }
                    .frame(maxHeight: 260)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .clipShape(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
            )
            .shadow(color: .black.opacity(0.15), radius: 30, y: -8)
            .ignoresSafeArea(edges: .bottom)
        }

        private func recommendedHousingRow(spot: HousingSpot) -> some View {
            HStack(spacing: 12) {
                AsyncImage(url: URL(string: spot.image)) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else {
                        Color(.systemGray5)
                    }
                }
                .frame(width: 64, height: 64)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                VStack(alignment: .leading, spacing: 4) {
                    Text(spot.title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                    Text(spot.type)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.secondary)
                }

                Spacer()

                HStack(spacing: -6) {
                    avatarStack(images: avatarImages)
                    Text("\(max(20, Int(spot.rating * 50)))+")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.primary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                        .background(Color(.systemGray6), in: Capsule())
                }
            }
            .padding(12)
            .background(Color(.systemGray6).opacity(0.6), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        }

        private func avatarStack(images: [String]) -> some View {
            HStack(spacing: -8) {
                ForEach(Array(images.prefix(3).enumerated()), id: \.offset) { _, imageUrl in
                    AsyncImage(url: URL(string: imageUrl)) { phase in
                        if let image = phase.image {
                            image.resizable()
                        } else {
                            Color(.systemGray5)
                        }
                    }
                    .frame(width: 26, height: 26)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                }
            }
        }

        private var tripTitle: String {
            destinationParts.first ?? trip.destination
        }

        private var tripSubtitle: String {
            if destinationParts.count > 1 {
                return destinationParts[1]
            }
            return "Destination"
        }

        private var destinationParts: [String] {
            trip.destination.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        }

        private var tripDateLabel: String {
            "\(shortDate(trip.startDate)) - \(shortDate(trip.endDate))"
        }

        private func shortDate(_ date: Date) -> String {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"
            return formatter.string(from: date)
        }

        private func animateToTrip() {
            guard !hasAnimated else { return }
            hasAnimated = true

            let geocoder = CLGeocoder()
            geocoder.geocodeAddressString(trip.destination) { placemarks, _ in
                let coordinate = placemarks?.first?.location?.coordinate
                    ?? CLLocationCoordinate2D(latitude: -8.4095, longitude: 115.1889)
                withAnimation(.easeInOut(duration: 0.8)) {
                    region.center = CLLocationCoordinate2D(
                        latitude: coordinate.latitude - 0.035,
                        longitude: coordinate.longitude
                    )
                    region.span = MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08)
                }
            }
        }
    }

    private func tabIcon(for tab: HousingTab) -> String {
        switch tab {
        case .spots:
            return "house.fill"
        case .roommates:
            return "person.2.fill"
        }
    }

    private func tabLabel(for tab: HousingTab) -> String {
        switch tab {
        case .spots:
            return "🏠 Housing"
        case .roommates:
            return "👋 Roommates"
        }
    }

    private struct HousingTabLabel: View {
        let text: String
        let isActive: Bool
        @State private var textWidth: CGFloat = 0

        var body: some View {
            VStack(spacing: 6) {
                Text(text)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.primary)
                    .background(
                        GeometryReader { proxy in
                            Color.clear
                                .onAppear { textWidth = proxy.size.width }
                                .onChange(of: proxy.size.width) { _, newValue in
                                    textWidth = newValue
                                }
                        }
                    )

                Capsule()
                    .fill(isActive ? Color.appAccent : Color.clear)
                    .frame(width: textWidth, height: 3)
            }
            .padding(.bottom, 6)
        }
    }

    private var housingMapContent: some View {
        ZStack(alignment: .top) {
            Map(coordinateRegion: $mapRegion, annotationItems: mapItems) { item in
                MapAnnotation(coordinate: item.coordinate) {
                    Button(action: {
                        if let spot = item.spot {
                            selectedHousingSpot = spot
                            selectedRoommate = nil
                        } else if let roommate = item.roommate {
                            selectedRoommate = roommate
                            selectedHousingSpot = nil
                        }
                    }) {
                        VStack(spacing: 4) {
                            Image(systemName: item.icon)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(width: 26, height: 26)
                                .background(Color.appAccent, in: Circle())
                            Text(item.title)
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundStyle(.primary)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 3)
                                .background(Color.white, in: Capsule())
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .mapStyle(.standard(pointsOfInterest: .excludingAll))
            .ignoresSafeArea(edges: .bottom)
            .id(activeTab)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    Button(action: {}) {
                        mapFilterChip(icon: "slider.horizontal.3", text: "Filter", isSelected: false)
                    }
                    .buttonStyle(.plain)

                    ForEach(mapFilters, id: \.self) { filter in
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedMapFilter = selectedMapFilter == filter ? nil : filter
                            }
                        }) {
                            mapFilterChip(text: filter, isSelected: selectedMapFilter == filter)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
            }
        }
    }

    private var mapFilters: [String] {
        switch activeTab {
        case .spots:
            return ["Studio", "Private room", "Entire place"]
        case .roommates:
            return ["Pet friendly", "Quiet", "Social"]
        }
    }

    private func mapFilterChip(icon: String? = nil, text: String, isSelected: Bool = false) -> some View {
        HStack(spacing: 6) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .medium))
            }
            Text(text)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(isSelected ? .white : .primary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            isSelected ? AnyShapeStyle(Color.appAccent) : AnyShapeStyle(.regularMaterial),
            in: Capsule()
        )
        .overlay(
            Capsule()
                .strokeBorder(isSelected ? Color.clear : Color(.systemGray5).opacity(0.3), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }

    private struct MapItem: Identifiable {
        let id: String
        let title: String
        let coordinate: CLLocationCoordinate2D
        let icon: String
        let spot: HousingSpot?
        let roommate: Roommate?
    }

    private var mapItems: [MapItem] {
        switch activeTab {
        case .spots:
            return housingSpots.map {
                MapItem(
                    id: "spot-\($0.id)",
                    title: $0.title,
                    coordinate: CLLocationCoordinate2D(latitude: $0.lat, longitude: $0.lng),
                    icon: "house.fill",
                    spot: $0,
                    roommate: nil
                )
            }
        case .roommates:
            return roommates.map {
                MapItem(
                    id: "roommate-\($0.id)",
                    title: $0.name,
                    coordinate: CLLocationCoordinate2D(latitude: $0.lat, longitude: $0.lng),
                    icon: "person.fill",
                    spot: nil,
                    roommate: $0
                )
            }
        }
    }

private struct HousingSearchFlowView: View {
    @Binding var activeTab: HousingTab
    let onClose: () -> Void

    @State private var stepIndex = 0
    @State private var locationText = ""
    @State private var selectedCity: String? = nil
    @State private var selectedWhat: Set<String> = []
    @State private var selectedBudget: Set<String> = []
    @State private var selectedRoommatesRange: Set<String> = []
    @State private var selectedRoommatesGender: Set<String> = []

    private let popularCities = [
        "Montreal, Canada",
        "Paris, France",
        "New York, USA",
        "London, UK",
        "Tokyo, Japan",
        "Lisbon, Portugal"
    ]

    private let housingTypes = ["Apartment", "House", "Student residence", "Room"]
    private let roommatesRanges = ["1 roommate", "2-3 roommates", "4+ roommates"]
    private let roommatesGenders = ["Any", "Women only", "Men only", "Mixed"]
    private let budgetRanges = ["$0-500", "$500-1000", "$1000-1500", "$1500+"]

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    headerSection
                    whereStep
                        .opacity(stepIndex == 0 ? 1 : 0)
                        .frame(maxHeight: stepIndex == 0 ? .infinity : 0)
                    whatStep
                        .opacity(stepIndex == 1 ? 1 : 0)
                        .frame(maxHeight: stepIndex == 1 ? .infinity : 0)
                    budgetStep
                        .opacity(stepIndex == 2 ? 1 : 0)
                        .frame(maxHeight: stepIndex == 2 ? .infinity : 0)
                    actionBar
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
        }
    }

    private var headerSection: some View {
        VStack(spacing: 14) {
            HStack {
                Spacer()
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .frame(width: 34, height: 34)
                        .background(Color.white, in: Circle())
                }
                .buttonStyle(.plain)
            }

            HStack(alignment: .bottom, spacing: 40) {
                ForEach(HousingTab.allCases, id: \.self) { tab in
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            activeTab = tab
                            resetSelectionsForTab()
                        }
                    }) {
                        VStack(spacing: 6) {
                            HousingSearchTabIcon(tab: tab)
                                .frame(width: 60, height: 60)
                            Text(tabLabel(for: tab))
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(.primary)
                            Capsule()
                                .fill(activeTab == tab ? Color.appAccent : Color.clear)
                                .frame(width: 46, height: 3)
                        }
                        .frame(height: 86)
                    }
                    .buttonStyle(.plain)
                }
            }

            HStack(spacing: 10) {
                Button(action: { advanceToStep(0) }) {
                    stepChip(title: "Where", isActive: stepIndex == 0)
                }
                .buttonStyle(.plain)
                Button(action: { advanceToStep(1) }) {
                    stepChip(title: "What", isActive: stepIndex == 1)
                }
                .buttonStyle(.plain)
                Button(action: { advanceToStep(2) }) {
                    stepChip(title: "Budget", isActive: stepIndex == 2)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var whereStep: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Where?")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(.primary)

            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.secondary)
                TextField("Search a city", text: $locationText)
                    .textInputAutocapitalization(.words)
                    .onSubmit {
                        if !locationText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            advanceToStep(1)
                        }
                    }
                if !locationText.isEmpty {
                    Button(action: { locationText = "" }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.secondary)
                            .frame(width: 26, height: 26)
                            .background(Color(.systemGray6), in: Circle())
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(Color.white, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: .black.opacity(0.08), radius: 10, y: 6)

            Text("Popular destinations")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.secondary)

            VStack(spacing: 10) {
                ForEach(popularCities, id: \.self) { city in
                    Button(action: {
                        selectedCity = city
                        locationText = city
                        advanceToStep(1)
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "mappin.circle.fill")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(Color.appAccent)
                            VStack(alignment: .leading, spacing: 4) {
                                Text(city)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(.primary)
                                Text("Popular option")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                        }
                        .padding(14)
                        .background(Color.white, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(selectedCity == city ? Color.appAccent : Color.clear, lineWidth: 1.5)
                        )
                        .shadow(color: .black.opacity(0.06), radius: 8, y: 4)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var whatStep: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("What?")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(.primary)

            if activeTab == .roommates {
                Text("How many roommates?")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.secondary)
                chipGrid(options: roommatesRanges, selection: $selectedRoommatesRange, allowsMultiple: true)

                Text("Roommate preference")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.secondary)
                chipGrid(options: roommatesGenders, selection: $selectedRoommatesGender, allowsMultiple: true)
            } else {
                Text("Type of place")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.secondary)
                chipGrid(options: housingTypes, selection: $selectedWhat, allowsMultiple: true)
            }
        }
    }

    private var budgetStep: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Budget")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(.primary)
            chipGrid(options: budgetRanges, selection: $selectedBudget, allowsMultiple: true)
        }
    }

    private var actionBar: some View {
        HStack {
            Button(action: resetAll) {
                Text("Clear all")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)

            Spacer()

            Button(action: {
                if stepIndex < 2 {
                    advanceToStep(stepIndex + 1)
                } else if canSearch {
                    onClose()
                }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 14, weight: .semibold))
                    Text(stepIndex < 2 ? "Next" : "Search")
                        .font(.system(size: 15, weight: .semibold))
                }
                .foregroundStyle(stepIndex < 2 || canSearch ? .white : .secondary)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    stepIndex < 2 || canSearch ? Color.appAccent : Color(.systemGray5),
                    in: Capsule()
                )
            }
            .buttonStyle(.plain)
            .disabled(stepIndex == 2 && !canSearch)
        }
        .padding(.top, 4)
    }

    private var canSearch: Bool {
        isStepComplete(0) && isStepComplete(1) && isStepComplete(2)
    }

    private func stepChip(title: String, isActive: Bool) -> some View {
        Text(title)
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(isActive ? .primary : .secondary)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isActive ? Color.white : Color(.systemGray6), in: Capsule())
            .overlay(
                Capsule()
                    .strokeBorder(isActive ? Color.black.opacity(0.08) : Color.clear, lineWidth: 1)
            )
    }

    private func chipGrid(options: [String], selection: Binding<Set<String>>, allowsMultiple: Bool) -> some View {
        let columns = [GridItem(.flexible()), GridItem(.flexible())]
        return LazyVGrid(columns: columns, spacing: 10) {
            ForEach(options, id: \.self) { option in
                Button(action: {
                    if selection.wrappedValue.contains(option) {
                        selection.wrappedValue.remove(option)
                    } else {
                        if allowsMultiple {
                            selection.wrappedValue.insert(option)
                        } else {
                            selection.wrappedValue = [option]
                        }
                    }
                }) {
                    Text(option)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(selection.wrappedValue.contains(option) ? .white : .primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            selection.wrappedValue.contains(option) ? Color.appAccent : Color.white,
                            in: RoundedRectangle(cornerRadius: 16, style: .continuous)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .strokeBorder(Color.black.opacity(0.06), lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func advanceToStep(_ step: Int) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            stepIndex = min(max(step, 0), 2)
        }
    }

    private func isStepComplete(_ index: Int) -> Bool {
        switch index {
        case 0:
            return selectedCity != nil || !locationText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case 1:
            if activeTab == .roommates {
                return !selectedRoommatesRange.isEmpty && !selectedRoommatesGender.isEmpty
            }
            return !selectedWhat.isEmpty
        case 2:
            return !selectedBudget.isEmpty
        default:
            return false
        }
    }

    private func resetSelectionsForTab() {
        selectedWhat.removeAll()
        selectedRoommatesRange.removeAll()
        selectedRoommatesGender.removeAll()
    }

    private func resetAll() {
        locationText = ""
        selectedCity = nil
        selectedWhat.removeAll()
        selectedBudget.removeAll()
        selectedRoommatesRange.removeAll()
        selectedRoommatesGender.removeAll()
    }

    private func tabLabel(for tab: HousingTab) -> String {
        switch tab {
        case .spots:
            return "Housing recommendations"
        case .roommates:
            return "Find roommates"
        }
    }
}

private struct HousingSearchTabIcon: View {
    let tab: HousingTab

    var body: some View {
        switch tab {
        case .spots:
            Image("Untitled design (14)")
                .resizable()
                .scaledToFill()
                .scaleEffect(1.1)
        case .roommates:
            Image("b (1)")
                .resizable()
                .scaledToFill()
                .scaleEffect(1.1)
        }
    }
}

private struct CreateHousingListingView: View {
    @Binding var activeTab: HousingTab
    let coordinate: CLLocationCoordinate2D
    let onCreateSpot: (HousingSpot) -> Void
    let onCreateRoommate: (Roommate) -> Void
    let onClose: () -> Void

    @State private var selectedTab: HousingTab

    @State private var housingTitle = ""
    @State private var housingDescription = ""
    @State private var housingPrice = ""
    @State private var housingPeriod = "mo"
    @State private var housingType = "Apartment"
    @State private var housingPhotoUrls = ""
    @State private var housingBadgesSelected: Set<String> = []
    @State private var housingBadgesCustom = ""

    @State private var roommateName = ""
    @State private var roommateAge = ""
    @State private var roommateBudget = ""
    @State private var roommateLocation = ""
    @State private var roommateMoveIn = ""
    @State private var roommateTags = ""

    init(
        activeTab: Binding<HousingTab>,
        coordinate: CLLocationCoordinate2D,
        onCreateSpot: @escaping (HousingSpot) -> Void,
        onCreateRoommate: @escaping (Roommate) -> Void,
        onClose: @escaping () -> Void
    ) {
        _activeTab = activeTab
        _selectedTab = State(initialValue: activeTab.wrappedValue)
        self.coordinate = coordinate
        self.onCreateSpot = onCreateSpot
        self.onCreateRoommate = onCreateRoommate
        self.onClose = onClose
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    header
                    tabSelector
                    formContent
                    actionBar
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 24)
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
        }
    }

    private var header: some View {
        HStack {
            Text("Create")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(.primary)
            Spacer()
            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .frame(width: 34, height: 34)
                    .background(Color.white, in: Circle())
            }
            .buttonStyle(.plain)
        }
    }

    private var tabSelector: some View {
        HStack(alignment: .bottom, spacing: 32) {
            ForEach(HousingTab.allCases, id: \.self) { tab in
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = tab
                        activeTab = tab
                    }
                }) {
                    VStack(spacing: 6) {
                        HousingSearchTabIcon(tab: tab)
                            .frame(width: 60, height: 60)
                        Text(tabLabel(for: tab))
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(.primary)
                        Capsule()
                            .fill(selectedTab == tab ? Color.appAccent : Color.clear)
                            .frame(width: 44, height: 3)
                    }
                    .frame(height: 86)
                }
                .buttonStyle(.plain)
            }
        }
    }

    @ViewBuilder
    private var formContent: some View {
        switch selectedTab {
        case .spots:
            housingForm
        case .roommates:
            roommatesForm
        }
    }

    private var housingForm: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Housing recommendation")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.primary)
            
            Text("Share a place you recommend for people moving to a new city")
                .font(.system(size: 13, weight: .regular))
                .foregroundStyle(.secondary)

            formTextField("Title", text: $housingTitle)
            formTextField("Price", text: $housingPrice, keyboard: .numberPad)

            HStack(spacing: 12) {
                formPicker("Period", selection: $housingPeriod, options: ["mo", "week", "day"])
                formPicker("Type", selection: $housingType, options: ["Apartment", "House", "Student residence", "Room"])
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Description")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.secondary)
                ZStack(alignment: .topLeading) {
                    TextEditor(text: $housingDescription)
                        .frame(minHeight: 100)
                        .padding(8)
                        .background(Color.white, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .strokeBorder(Color.black.opacity(0.06), lineWidth: 1)
                        )
                    if housingDescription.isEmpty {
                        Text("Describe the place, what's included, and what makes it special.")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(.secondary.opacity(0.8))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 16)
                    }
                }
            }

            formTextField("Photo URLs (comma separated)", text: $housingPhotoUrls)

            VStack(alignment: .leading, spacing: 8) {
                Text("Badges")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.secondary)
                badgeGrid(options: housingBadgeOptions, selection: $housingBadgesSelected)
                formTextField("Custom badges (comma separated)", text: $housingBadgesCustom)
            }
        }
    }

    private var roommatesForm: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Find roommates")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.primary)
            
            Text("Post that you're looking for roommates")
                .font(.system(size: 13, weight: .regular))
                .foregroundStyle(.secondary)

            formTextField("Name", text: $roommateName)
            HStack(spacing: 12) {
                formTextField("Age", text: $roommateAge, keyboard: .numberPad)
                formTextField("Budget", text: $roommateBudget, keyboard: .numberPad)
            }
            formTextField("Location", text: $roommateLocation)
            formTextField("Move-in date", text: $roommateMoveIn)
            formTextField("Tags (comma separated)", text: $roommateTags)
        }
    }


    private var actionBar: some View {
        Button(action: handleCreate) {
            Text("Publish")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(canPublish ? Color.appAccent : Color(.systemGray5), in: Capsule())
        }
        .buttonStyle(.plain)
        .disabled(!canPublish)
    }

    private var canPublish: Bool {
        switch selectedTab {
        case .spots:
            return !housingTitle.isEmpty && Int(housingPrice) != nil
        case .roommates:
            return !roommateName.isEmpty && Int(roommateAge) != nil && Int(roommateBudget) != nil && !roommateLocation.isEmpty
        }
    }

    private func handleCreate() {
        switch selectedTab {
        case .spots:
            let parsedPhotos = housingPhotoUrls
                .split(separator: ",")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
            let customBadges = housingBadgesCustom
                .split(separator: ",")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
            let allBadges = Array(housingBadgesSelected) + customBadges
            let photos = parsedPhotos.isEmpty
                ? ["https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?auto=format&fit=crop&w=800&q=80"]
                : parsedPhotos
            let spot = HousingSpot(
                id: Int(Date().timeIntervalSince1970),
                title: housingTitle,
                description: housingDescription.isEmpty ? "No description yet." : housingDescription,
                price: Int(housingPrice) ?? 0,
                currency: "$",
                period: housingPeriod,
                image: photos.first ?? "https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?auto=format&fit=crop&w=800&q=80",
                photos: photos,
                badges: allBadges.isEmpty ? ["Furnished", "Near metro"] : allBadges,
                rating: 4.8,
                recommender: "You",
                recommenderImg: "https://i.pravatar.cc/150?u=you",
                lat: coordinate.latitude,
                lng: coordinate.longitude,
                type: housingType
            )
            onCreateSpot(spot)
        case .roommates:
            let tags = roommateTags.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
            let roommate = Roommate(
                id: Int(Date().timeIntervalSince1970),
                name: roommateName,
                age: Int(roommateAge) ?? 0,
                budget: Int(roommateBudget) ?? 0,
                location: roommateLocation,
                image: "https://i.pravatar.cc/150?u=\(roommateName.lowercased())",
                tags: tags.isEmpty ? ["Friendly", "Clean", "Flexible"] : tags,
                lat: coordinate.latitude,
                lng: coordinate.longitude,
                moveIn: roommateMoveIn.isEmpty ? "ASAP" : roommateMoveIn
            )
            onCreateRoommate(roommate)
        }
        onClose()
    }

    private func tabLabel(for tab: HousingTab) -> String {
        switch tab {
        case .spots:
            return "Housing recommendations"
        case .roommates:
            return "Find roommates"
        }
    }

    private func formTextField(_ title: String, text: Binding<String>, keyboard: UIKeyboardType = .default) -> some View {
        TextField(title, text: text)
            .keyboardType(keyboard)
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(Color.white, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(Color.black.opacity(0.06), lineWidth: 1)
            )
    }

    private func formPicker(_ title: String, selection: Binding<String>, options: [String]) -> some View {
        Menu {
            ForEach(options, id: \.self) { option in
                Button(option) { selection.wrappedValue = option }
            }
        } label: {
            HStack(spacing: 6) {
                Text("\(title):")
                    .foregroundStyle(.secondary)
                Text(selection.wrappedValue)
                    .foregroundStyle(.primary)
                Spacer()
                Image(systemName: "chevron.down")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(Color.white, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(Color.black.opacity(0.06), lineWidth: 1)
            )
        }
    }

    private var housingBadgeOptions: [String] {
        ["Furnished", "Near metro", "Utilities included", "Pet friendly", "Quiet", "Balcony"]
    }

    private func badgeGrid(options: [String], selection: Binding<Set<String>>) -> some View {
        let columns = [GridItem(.flexible()), GridItem(.flexible())]
        return LazyVGrid(columns: columns, spacing: 10) {
            ForEach(options, id: \.self) { option in
                Button(action: {
                    if selection.wrappedValue.contains(option) {
                        selection.wrappedValue.remove(option)
                    } else {
                        selection.wrappedValue.insert(option)
                    }
                }) {
                    Text(option)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(selection.wrappedValue.contains(option) ? .white : .primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            selection.wrappedValue.contains(option) ? Color.appAccent : Color.white,
                            in: RoundedRectangle(cornerRadius: 14, style: .continuous)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .strokeBorder(Color.black.opacity(0.06), lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }
}

    
    private func housingSpotCard(spot: HousingSpot) -> some View {
        let featureLine = ([spot.type] + Array(spot.badges.prefix(2))).joined(separator: " • ")
        return Button(action: {
            selectedHousingSpot = spot
            selectedRoommate = nil
        }) {
            VStack(alignment: .leading, spacing: 10) {
                ZStack {
                    let heroImage = spot.photos.first ?? spot.image
                    AsyncImage(url: URL(string: heroImage)) { phase in
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
                    .frame(height: 220)
                    .frame(maxWidth: .infinity)
                    .clipped()
                }
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .overlay(alignment: .topLeading) {
                    Text("Traveler favorite")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.primary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(.regularMaterial, in: Capsule())
                        .padding(12)
                }
                .overlay(alignment: .topTrailing) {
                    Image(systemName: "heart")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 34, height: 34)
                        .background(Color.black.opacity(0.35), in: Circle())
                        .padding(12)
                }
                .overlay(alignment: .bottom) {
                    HStack(spacing: 6) {
                        ForEach(0..<4, id: \.self) { index in
                            Circle()
                                .fill(index == 0 ? Color.white : Color.white.opacity(0.5))
                                .frame(width: 6, height: 6)
                        }
                    }
                    .padding(.bottom, 10)
                }

                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(spot.title)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(.primary)
                            .lineLimit(1)

                        Text(featureLine)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }

                    Spacer()

                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(.yellow)
                        Text(String(format: "%.1f", spot.rating))
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(.primary)
                    }
                }

                Text(spot.description)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(.secondary)
                    .lineLimit(2)

                HStack(spacing: 6) {
                    Text("\(spot.currency)\(spot.price)")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(.primary)
                    Text("/\(spot.period)")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.secondary)
                }
            }
            .padding(14)
            .background(Color.white, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            .shadow(color: .black.opacity(0.08), radius: 12, y: 6)
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .strokeBorder(Color.black.opacity(0.05), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
    
    private func roommateCard(roommate: Roommate) -> some View {
        Button(action: {
            selectedRoommate = roommate
            selectedHousingSpot = nil
        }) {
            VStack(alignment: .leading, spacing: 10) {
                ZStack {
                    AsyncImage(url: URL(string: roommate.image)) { phase in
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
                    .frame(height: 200)
                    .frame(maxWidth: .infinity)
                    .clipped()
                }
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .overlay(alignment: .topLeading) {
                    Text("Roommate request")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.primary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(.regularMaterial, in: Capsule())
                        .padding(12)
                }
                .overlay(alignment: .topTrailing) {
                    Image(systemName: "bubble.left")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 34, height: 34)
                        .background(Color.black.opacity(0.35), in: Circle())
                        .padding(12)
                }

                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(roommate.name), \(roommate.age)")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(.primary)

                        HStack(spacing: 6) {
                            Image(systemName: "mappin.and.ellipse")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(.secondary)
                            Text(roommate.location)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                    }

                    Spacer()

                    Text("Move in \(roommate.moveIn)")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.primary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                        .background(Color.appAccent.opacity(0.12), in: Capsule())
                }

                if !roommate.tags.isEmpty {
                    HStack(spacing: 6) {
                        ForEach(roommate.tags.prefix(3), id: \.self) { tag in
                            cardTag(text: tag)
                        }
                    }
                }
            }
            .padding(14)
            .background(Color.white, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            .shadow(color: .black.opacity(0.08), radius: 12, y: 6)
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .strokeBorder(Color.black.opacity(0.05), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private func cardTag(text: String) -> some View {
        Text(text)
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(.secondary)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Color(.systemGray6), in: Capsule())
    }
    
}

// MARK: - Housing Detail Sheet
private struct HousingDetailSheet: View {
    let spot: HousingSpot
    let onClose: () -> Void
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    housingHero
                    housingHeader
                    housingInfoCards
                    housingDescription
                    housingBadges
                    housingRecommender
                    housingPhotos
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 40)
            }
            .background(Color.white)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .environment(\.colorScheme, .light)
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(24)
    }

    private var housingHero: some View {
        ZStack(alignment: .topTrailing) {
            let heroImage = spot.photos.first ?? spot.image
            AsyncImage(url: URL(string: heroImage)) { phase in
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
            .frame(height: 260)
            .frame(maxWidth: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .strokeBorder(Color.black.opacity(0.05), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.08), radius: 10, y: 6)

            HStack(spacing: 4) {
                Image(systemName: "star.fill")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.yellow)
                Text(String(format: "%.1f", spot.rating))
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.primary)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
            .padding(16)
        }
    }

    private var housingHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(spot.title)
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(.primary)

            HStack(spacing: 6) {
                Image(systemName: "house.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
                Text(spot.type)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var housingInfoCards: some View {
        VStack(spacing: 12) {
            infoCard(
                title: "Price",
                subtitle: "Per \(spot.period)",
                systemImage: "banknote.fill",
                value: "\(spot.currency)\(spot.price)"
            )
            infoCard(
                title: "Rating",
                subtitle: "User review",
                systemImage: "star.fill",
                value: String(format: "%.1f", spot.rating)
            )
        }
    }

    private var housingDescription: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Description")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.primary)
            Text(spot.description)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.secondary)
                .lineSpacing(4)
        }
    }

    private var housingBadges: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Features")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.primary)

            if spot.badges.isEmpty {
                Text("✨ Cozy, well-located, and fully equipped.")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.secondary)
            } else {
                FlowLayout(spacing: 8) {
                    ForEach(spot.badges, id: \.self) { badge in
                        Text(badge)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.primary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color(.systemGray6), in: Capsule())
                    }
                }
            }
        }
    }

    private var housingRecommender: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Recommended by")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.primary)

            HStack(spacing: 12) {
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
                .frame(width: 44, height: 44)
                .clipShape(Circle())
                .overlay(Circle().strokeBorder(.quaternary, lineWidth: 1))

                Text(spot.recommender)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.primary)

                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
    }

    private var housingPhotos: some View {
        Group {
            if spot.photos.count > 1 {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Photos")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.primary)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(Array(spot.photos.enumerated()), id: \.offset) { _, photo in
                                AsyncImage(url: URL(string: photo)) { phase in
                                    if let image = phase.image {
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                    } else {
                                        Color(.systemGray5)
                                    }
                                }
                                .frame(width: 120, height: 120)
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            }
                        }
                    }
                }
            }
        }
    }

    private func infoCard(title: String, subtitle: String, systemImage: String, value: String) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.appAccent.opacity(0.12))
                Image(systemName: systemImage)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.appAccent)
            }
            .frame(width: 44, height: 44)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.primary)
                Text(subtitle)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(value)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.primary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

// MARK: - Roommate Detail Sheet
private struct RoommateDetailSheet: View {
    let roommate: Roommate
    let onClose: () -> Void
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    roommateHero
                    roommateHeader
                    roommateInfoCards
                    roommateDescription
                    roommateTags
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 40)
            }
            .background(Color.white)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .environment(\.colorScheme, .light)
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(24)
    }

    private var roommateHero: some View {
        AsyncImage(url: URL(string: roommate.image)) { phase in
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
        .frame(height: 260)
        .frame(maxWidth: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(Color.black.opacity(0.05), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.08), radius: 10, y: 6)
    }

    private var roommateHeader: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("\(roommate.name), \(roommate.age)")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(.primary)
                    HStack(spacing: 6) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(.secondary)
                        Text(roommate.location)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()
            }

            moveInPill
        }
    }

    private var roommateInfoCards: some View {
        VStack(spacing: 12) {
            infoCard(
                title: "Budget",
                subtitle: "Monthly target",
                systemImage: "banknote.fill",
                value: "$\(roommate.budget)"
            )
            infoCard(
                title: "Location",
                subtitle: "Preferred area",
                systemImage: "mappin.and.ellipse",
                value: roommate.location
            )
        }
    }

    private var roommateTags: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("About")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.primary)

            if roommate.tags.isEmpty {
                Text("👋🙂 Friendly & respectful\n🏡✨ Looking for a cozy shared place\n🧹🫧 Clean habits and good vibes\n📍🗺️ Open to nearby neighborhoods\n🤝😊 Easy to live with")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.secondary)
                    .lineSpacing(4)
            } else {
                FlowLayout(spacing: 8) {
                    ForEach(roommate.tags, id: \.self) { tag in
                        Text("\(emojiForRoommateTag(tag)) \(tag)")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.primary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color(.systemGray6), in: Capsule())
                    }
                }
            }
        }
    }

    private var roommateDescription: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Description")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.primary)
            Text("✨ Friendly and easy-going roommate looking for a respectful shared space. 🧹 Clean habits, open communication, and good vibes.")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.secondary)
                .lineSpacing(4)
        }
    }

    private var moveInPill: some View {
        HStack(spacing: 8) {
            Image(systemName: "calendar")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color.appAccent)
            Text("Move in \(roommate.moveIn)")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.primary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.systemGray6), in: Capsule())
    }

    private func infoCard(title: String, subtitle: String, systemImage: String, value: String) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.appAccent.opacity(0.12))
                Image(systemName: systemImage)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.appAccent)
            }
            .frame(width: 44, height: 44)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.primary)
                Text(subtitle)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(value)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.primary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func emojiForRoommateTag(_ tag: String) -> String {
        switch tag.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() {
        case "student":
            return "🎓"
        case "non-smoker", "nonsmoker":
            return "🚭"
        case "quiet":
            return "🤫"
        case "professional":
            return "💼"
        case "pet friendly", "pet-friendly":
            return "🐾"
        case "social":
            return "🥳"
        case "remote worker", "remote":
            return "🧑‍💻"
        case "clean":
            return "🧼"
        case "flexible":
            return "🔁"
        case "lgbtq+ friendly", "lgbtq+":
            return "🏳️‍🌈"
        case "vegetarian":
            return "🥗"
        case "early riser":
            return "🌅"
        case "artist":
            return "🎨"
        default:
            return "✨"
        }
    }
}
