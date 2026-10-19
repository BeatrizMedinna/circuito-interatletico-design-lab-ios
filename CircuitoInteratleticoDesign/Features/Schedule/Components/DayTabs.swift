import SwiftUI

/// Dias do cronograma ("Hoje" identifica o dia atual). Rola na horizontal e
/// centraliza o dia escolhido.
struct DayTabs: View {
    let days: [Date]
    @Binding var selection: Date

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal) {
                HStack(spacing: 0) {
                    ForEach(days, id: \.self) { day in
                        tab(day).id(day)
                    }
                }
                .padding(.horizontal, Spacing.xs)
            }
            .scrollIndicators(.hidden)
            .onAppear { proxy.scrollTo(selection, anchor: .center) }
            .onChange(of: selection) { _, day in
                withAnimation { proxy.scrollTo(day, anchor: .center) }
            }
        }
        .sensoryFeedback(.selection, trigger: selection)
    }

    private func tab(_ day: Date) -> some View {
        let isSelected = Calendar.current.isDate(day, inSameDayAs: selection)
        return Button {
            withAnimation(.snappy) { selection = day }
        } label: {
            VStack(spacing: 2) {
                Text(Formatters.dayTab(day))
                    .font(.subheadline.weight(isSelected ? .semibold : .regular))
                    .foregroundStyle(isSelected ? Color.textPrimary : Color.textSecondary)
                Capsule()
                    .fill(isSelected ? Color.textPrimary : .clear)
                    .frame(height: 3)
                    .padding(.top, 4)
            }
            .fixedSize()
            .padding(.horizontal, Spacing.s)
            .padding(.top, Spacing.xs)
            .frame(minWidth: 84, minHeight: 44)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Calendar.current.isDateInToday(day) ? "Hoje, \(Formatters.fullDay(day))" : Formatters.fullDay(day))
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview {
    DayTabs(days: MockData.scheduleDays, selection: .constant(MockData.scheduleDays[0]))
        .background(Color.appBackground)
}
