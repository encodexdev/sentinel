import SwiftUI

struct DutyBadgeView: View {
  let onDuty: Bool
  
  var body: some View {
    Text(onDuty ? "On Duty" : "Off Duty")
      .font(.caption)
      .bold()
      .padding(.horizontal, 12)
      .padding(.vertical, 6)
      .background(onDuty ? Color.green.opacity(0.2) : Color.red.opacity(0.2))
      .foregroundColor(onDuty ? .green : .red)
      .clipShape(Capsule())
  }
}
