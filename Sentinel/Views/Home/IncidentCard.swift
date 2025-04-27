import SwiftUI

struct IncidentCard: View {
    let incident: Incident
    var onTap: (() -> Void)? = nil
    
    private var statusColor: Color {
        switch incident.status {
        case .open:       return Color("StatusOpen")
        case .inProgress: return Color("StatusInProgress")
        case .resolved:   return Color("StatusResolved")
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
                    .foregroundColor(Color("SecondaryText"))
            }
            HStack(spacing: 16) {
                Label(incident.location, systemImage: "mappin.and.ellipse")
                    .font(.caption2)
                    .foregroundColor(Color("SecondaryText"))
                Label(formattedTime, systemImage: "clock")
                    .font(.caption2)
                    .foregroundColor(Color("SecondaryText"))
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
        .background(Color("Background"))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.03), radius: 2, x: 0, y: 1)
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .onTapGesture {
            if let onTap = onTap {
                onTap()
            } else {
                // Default navigate to incidents tab
                TabState.shared.switchTo(.incidents)
            }
        }
    }
}


#Preview {
    IncidentCard(incident: TestData.incidents[0])
}
