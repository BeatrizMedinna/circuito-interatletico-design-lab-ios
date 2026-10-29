import SwiftUI

extension EnvironmentValues {
    /// Id da atlética de coração, projetado da fonte de verdade (`AppState.favoriteAthletic`)
    /// na raiz das abas. Escudos, linhas de ranking e pódio leem este valor para
    /// destacar a sua atlética em branco sem cada tela precisar repassar.
    @Entry var favoriteAthleticID: Athletic.ID? = nil
}
