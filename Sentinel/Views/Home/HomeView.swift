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
                        Text("Shift started at 8:00 AM")
                            .font(.subheadline)
                            .foregroundColor(Color("SecondaryText"))
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
                            .background(Color("AccentBlue"))
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