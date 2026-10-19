//
//  CircuitoInteratleticoDesignApp.swift
//  CircuitoInteratleticoDesign
//
//  Created by Beatriz Medina on 16/10/26.
//

import SwiftUI

@main
struct CircuitoInteratleticoDesignApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
                .preferredColorScheme(.light)
                .tint(.textPrimary)
        }
    }
}

/// Alterna entre o onboarding e o app. O carregamento das atléticas é simulado.
/// Para pular o onboarding no simulador: `-labSkipOnboarding YES` (e, opcionalmente,
/// `-labFavorite ath-poraque` para escolher a atlética).
struct RootView: View {
    @State private var athleticsState: LoadState<[Athletic]> = .loading
    @State private var favoriteAthletic: Athletic?
    @State private var hasFinishedOnboarding = false

    init() {
        let defaults = UserDefaults.standard
        guard defaults.bool(forKey: "labSkipOnboarding") else { return }
        let favoriteID = defaults.string(forKey: "labFavorite") ?? "ath-bufalos"
        _favoriteAthletic = State(initialValue: MockData.athletics.first { $0.id == favoriteID })
        _hasFinishedOnboarding = State(initialValue: true)
    }

    var body: some View {
        Group {
            if hasFinishedOnboarding, let favoriteAthletic {
                MainTabView(appState: AppState(favoriteAthletic: favoriteAthletic))
            } else {
                OnboardingView(editionName: MockData.edition.name,
                               state: athleticsState,
                               initialSelectionID: favoriteAthletic?.id,
                               onRetry: { Task { await loadAthletics() } },
                               onEnter: { athletic in
                                   favoriteAthletic = athletic
                                   hasFinishedOnboarding = true
                               })
                .task {
                    if case .loaded = athleticsState { return }
                    await loadAthletics()
                }
            }
        }
        .animation(.default, value: hasFinishedOnboarding)
    }

    private func loadAthletics() async {
        athleticsState = .loading
        try? await Task.sleep(for: .seconds(1))
        athleticsState = .loaded(MockData.athletics)
    }
}

#Preview("Fluxo completo") {
    RootView()
}
