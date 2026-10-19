import SwiftUI

/// Aba Sobre da atlética: sigla, instituição e descrição.
struct AthleticAboutTab: View {
    let athletic: Athletic
    let profile: AthleticProfile

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xl) {
            VStack(alignment: .leading, spacing: Spacing.s) {
                SectionHeader(title: "Informações")
                VStack(alignment: .leading, spacing: Spacing.m) {
                    item("Sigla", athletic.acronym)
                    item("Instituição", athletic.institution)
                }
                .padding(Spacing.m)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.surface, in: RoundedRectangle(cornerRadius: Radius.card))
            }
            VStack(alignment: .leading, spacing: Spacing.s) {
                SectionHeader(title: "Descrição")
                if let description = profile.description {
                    Text(description)
                        .font(.body)
                        .foregroundStyle(.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                } else {
                    InlineNote(systemImage: "text.alignleft", text: "Esta atlética ainda não tem descrição.")
                }
            }
        }
    }

    private func item(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.textPrimary)
            Text(value)
                .font(.subheadline)
                .foregroundStyle(.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    let athletic = MockData.athletic("ath-bufalos")
    AthleticAboutTab(athletic: athletic, profile: MockData.profile(for: athletic.id))
        .padding()
        .background(Color.canvas)
}
