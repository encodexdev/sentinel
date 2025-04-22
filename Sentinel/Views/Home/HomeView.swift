import SwiftUI

struct HomeView: View {
    @StateObject private var vm = HomeViewModel()
    
    // Extract first name from TestData.user
    private var firstName: String {
        let parts = TestData.user.fullName.split(separator: " ")
        return parts.first.map(String.init) ?? TestData.user.fullName
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    
                    // MARK: Greeting
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Welcome, \(firstName)")
                            .font(.largeTitle).bold()
                        Text("Shift started at 8:00 AM")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // MARK: Report Button
                    Button {
                        // TODO: navigate to ChatView
                    } label: {
                        Label("Report New Incident", systemImage: "exclamationmark.bubble")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    
                    // MARK: My Incidents Section
                    SectionCard(
                        title: "My Incidents",
                        actionTitle: "View all",
                        action: {
                            // TODO: handle "View all"
                        }
                    ) {
                        ForEach(vm.myIncidents) { incident in
                            IncidentCard(incident: incident)
                        }
                    }
                    
                    // MARK: Team Incidents Section
                    SectionCard(title: "Team Incidents") {
                        ForEach(vm.teamIncidents) { incident in
                            IncidentCard(incident: incident)
                        }
                    }
                    
                    Spacer(minLength: 20)
                }
                .padding()
            }
            .background(Color("Background").ignoresSafeArea())
            .navigationTitle("Home")
        }
    }
}

// MARK: - SectionCard

struct SectionCard<Content: View>: View {
    let title: String
    let actionTitle: String?
    let action: (() -> Void)?
    let content: Content
    
    init(
        title: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.actionTitle = actionTitle
        self.action = action
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text(title)
                    .font(.headline)
                Spacer()
                if let actionTitle = actionTitle, let action = action {
                    Button(action: action) {
                        Text(actionTitle)
                            .font(.subheadline)
                    }
                }
            }
            .padding(.horizontal)
            
            VStack(spacing: 8) {
                content
            }
            .padding(.vertical, 8)
        }
        .background(Color("CardBackground"))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 4)
    }
}

// MARK: - IncidentCard

struct IncidentCard: View {
    let incident: Incident
    
    private var statusColor: Color {
        switch incident.status {
        case .open:       return .red
        case .inProgress: return .orange
        case .resolved:   return .green
        }
    }
    
    private var formattedTime: String {
        let fmt = DateFormatter()
        fmt.dateFormat = "h:mm a"
        return fmt.string(from: incident.time)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(incident.title)
                    .font(.subheadline).bold()
                Spacer()
                Text(incident.status.rawValue)
                    .font(.caption2).bold()
                    .padding(.horizontal, 8).padding(.vertical, 4)
                    .background(statusColor.opacity(0.2))
                    .foregroundColor(statusColor)
                    .clipShape(Capsule())
            }
            if let desc = incident.description {
                Text(desc)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            HStack(spacing: 16) {
                Label(incident.location, systemImage: "mappin.and.ellipse")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Label(formattedTime, systemImage: "clock")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(Color("Background"))
        .cornerRadius(8)
    }
}
