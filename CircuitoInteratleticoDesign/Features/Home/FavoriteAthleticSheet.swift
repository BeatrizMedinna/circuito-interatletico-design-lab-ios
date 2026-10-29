import SwiftUI

/// Troca ou remove a atlética de coração sem refazer o onboarding (RN-86).
/// Reaproveita a lista do onboarding; "Salvar" só habilita quando algo mudou.
struct FavoriteAthleticSheet: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    @State private var selectedID: Athletic.ID?
    @State private var query = ""

    var body: some View {
        NavigationStack {
            AthleticPicker(athletics: MockData.athletics, selectedID: $selectedID, query: $query,
                           label: "Qual atlética você acompanha?")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.canvas.ignoresSafeArea())
                .safeAreaInset(edge: .bottom, spacing: 0) { actions }
                .navigationTitle("Atlética de coração")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancelar") { dismiss() }
                            .barControlNeutral()
                    }
                }
        }
        .onAppear { selectedID = appState.favoriteAthletic?.id }
    }

    private var actions: some View {
        VStack(spacing: Spacing.xs) {
            Button("Salvar") {
                appState.setFavorite(MockData.athletics.first { $0.id == selectedID })
                dismiss()
            }
            .buttonStyle(.primary)
            .disabled(selectedID == nil || selectedID == appState.favoriteAthletic?.id)

            if appState.favoriteAthletic != nil {
                Button {
                    appState.setFavorite(nil)
                    dismiss()
                } label: {
                    Text("Remover atlética de coração")
                        .font(.subheadline.weight(.semibold))
                        .underline()
                        .foregroundStyle(.textPrimary)
                        .frame(maxWidth: .infinity, minHeight: 44)
                }
                Text("Sem atlética de coração, você vê os jogos e as notificações de todas.")
                    .font(.footnote)
                    .foregroundStyle(.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.horizontal, Spacing.l)
        .padding(.top, Spacing.s)
        .padding(.bottom, Spacing.xs)
        .background(Color.appBackground.ignoresSafeArea(edges: .bottom))
    }
}

#Preview("Com atlética") {
    Color.clear.sheet(isPresented: .constant(true)) {
        FavoriteAthleticSheet()
            .environment(AppState(favoriteAthletic: MockData.athletic("ath-bufalos"), scenario: .filled, preloaded: true))
    }
}

#Preview("Sem atlética") {
    Color.clear.sheet(isPresented: .constant(true)) {
        FavoriteAthleticSheet()
            .environment(AppState(favoriteAthletic: nil, scenario: .filled, preloaded: true))
    }
}
