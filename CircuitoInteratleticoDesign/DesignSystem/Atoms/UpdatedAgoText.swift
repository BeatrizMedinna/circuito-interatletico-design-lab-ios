import SwiftUI

/// "Atualizado há 8 s", contando sozinho a cada segundo.
struct UpdatedAgoText: View {
    let date: Date

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            Text(Formatters.updatedAgo(since: date, now: context.date))
                .font(.caption)
                .monospacedDigit()
                .foregroundStyle(.textSecondary)
        }
    }
}

#Preview {
    UpdatedAgoText(date: .now.addingTimeInterval(-15))
        .padding()
}
