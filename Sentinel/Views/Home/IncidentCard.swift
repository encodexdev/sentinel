import SwiftUI

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
