import SwiftUI

/// Campo de busca das listas (onboarding, ranking, modalidades).
struct SearchField: View {
    let prompt: String
    @Binding var text: String

    var body: some View {
        HStack(spacing: Spacing.xs) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.textSecondary)
                .accessibilityHidden(true)

            TextField(text: $text, prompt: Text(prompt).foregroundStyle(.textSecondary)) {
                Text(prompt)
            }
            .foregroundStyle(.textPrimary)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .submitLabel(.search)

            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.textSecondary)
                }
                .accessibilityLabel("Limpar busca")
            }
        }
        .padding(.horizontal, Spacing.s)
        .frame(minHeight: 44)
        .background(.surface, in: RoundedRectangle(cornerRadius: Radius.control))
    }
}

#Preview {
    @Previewable @State var text = ""
    SearchField(prompt: "Buscar atlética", text: $text)
        .padding()
}
