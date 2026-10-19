# Plano de Implementação — Arquitetura Atomic Design

Este documento define a reestruturação e padronização dos componentes e telas do **Circuito Inter-Atlético (Design Lab iOS)** seguindo a metodologia **Atomic Design**, garantindo alta modularidade, facilidade de busca no Xcode (`Cmd + Shift + O`), separação de responsabilidades (1 componente por arquivo) e desacoplamento entre UI e modelos de domínio.

---

## 1. Princípios e Regras de Organização

1. **Um componente por arquivo**: Cada struct/view pública deve ter seu próprio arquivo `.swift` batizado com o nome exato do componente (ex.: `LiveBadge.swift`, `TeamColumn.swift`, `PartialsTable.swift`).
2. **Estrutura por camadas (Atomic Design)**:
   - **Tokens (Foundations)**: Cores semânticas, espaçamentos (`Spacing`), raios (`Radius`), formatadores e view modifiers globais.
   - **Atoms (Átomos)**: Elementos visuais indivisíveis (badges, tags, chips, botões, campos de busca, ícones circulares, notas inline).
   - **Molecules (Moléculas)**: Combinações diretas de 2 ou mais átomos para formar unidades funcionais simples (linhas de lista, cabeçalhos de seção, abas, colunas de equipe, grupos de chips).
   - **Organisms (Organismos)**: Blocos de interface ricos, autônomos e compostos (cartões de partida, pódio, tabelas de parciais, histórico de lances, seletor completo de atléticas).
   - **Templates / Sheets / Tabs**: Estruturas de tela intermediárias, sheets de filtros e abas modulares de telas complexas.
   - **Pages (Telas)**: Telas completas que compõem os fluxos do app (`Features/<NomeDaFeature>/<Nome>View.swift`).
3. **Modelos desacoplados das Views**: Tipos de dados de domínio (`ScheduleItem`, `ContentScope`, etc.) devem residir em `Mocks/` ou `Domain/`, nunca declarados dentro de arquivos de View ou Sheet de filtros.
4. **Xcode 16 Synchronized Root Group**: O projeto usa `PBXFileSystemSynchronizedRootGroup`. Novas pastas e arquivos criados no sistema de arquivos são sincronizados automaticamente no Xcode.

---

## 2. Mapa de Decomposição (Antes vs. Depois)

### 2.1 DesignSystem

| Arquivo Original | Componentes Internos | Classificação Atomic | Novo Caminho Proposto |
|---|---|---|---|
| `Tokens.swift` | `Color` tokens, `Spacing`, `Radius` | Tokens | `DesignSystem/Tokens/Tokens.swift` |
| `Formatters.swift` | `enum Formatters` | Tokens | `DesignSystem/Tokens/Formatters.swift` |
| `ButtonStyles.swift` | `PrimaryButtonStyle`, `SecondaryButtonStyle`, `PressableCardStyle` | Tokens / Atoms | `DesignSystem/Tokens/ButtonStyles.swift` |
| `MatchCard.swift` | `teamSideBars()` | View Modifier / Token | `DesignSystem/Tokens/CardModifiers.swift` |
| `AthleticBadge.swift` | `struct AthleticBadge` | Átomo | `DesignSystem/Atoms/AthleticBadge.swift` |
| `MatchCard.swift` | `struct MatchStatusTag` | Átomo | `DesignSystem/Atoms/MatchStatusTag.swift` |
| `MatchHeaderCard.swift` | `struct LiveBadge` | Átomo | `DesignSystem/Atoms/LiveBadge.swift` |
| `MatchHeaderCard.swift` | `struct UpdatedAgoText` | Átomo | `DesignSystem/Atoms/UpdatedAgoText.swift` |
| `Chips.swift` | `struct ChoiceChip` | Átomo | `DesignSystem/Atoms/ChoiceChip.swift` |
| `Chips.swift` | `struct RemovableChip` | Átomo | `DesignSystem/Atoms/RemovableChip.swift` |
| `SectionHeader.swift` | `struct CircleIconLabel` | Átomo | `DesignSystem/Atoms/CircleIconLabel.swift` |
| `SectionHeader.swift` | `struct CountBadge` | Átomo | `DesignSystem/Atoms/CountBadge.swift` |
| `SearchField.swift` | `struct SearchField` | Átomo | `DesignSystem/Atoms/SearchField.swift` |
| `ScheduleFilters.swift` | `struct SelectorLabel` | Átomo | `DesignSystem/Atoms/SelectorLabel.swift` |
| `ScoreBoxes.swift` | `struct ScoreBoxes` | Átomo | `DesignSystem/Atoms/ScoreBoxes.swift` |
| `InlineNote.swift` | `struct InlineNote` | Átomo | `DesignSystem/Atoms/InlineNote.swift` |
| `Toast.swift` | `struct Toast` | Átomo | `DesignSystem/Atoms/Toast.swift` |
| `SectionHeader.swift` | `struct SectionHeader` | Molécula | `DesignSystem/Molecules/SectionHeader.swift` |
| `MatchCard.swift` | `struct TeamColumn` | Molécula | `DesignSystem/Molecules/TeamColumn.swift` |
| `UnderlineTabs.swift` | `struct UnderlineTabs` | Molécula | `DesignSystem/Molecules/UnderlineTabs.swift` |
| `Chips.swift` | `struct FlowChips` | Molécula | `DesignSystem/Molecules/FlowChips.swift` |
| `Chips.swift` | `struct ActiveFiltersBar` | Molécula | `DesignSystem/Molecules/ActiveFiltersBar.swift` |
| `AthleticPicker.swift` | `struct SelectionRow` | Molécula | `DesignSystem/Molecules/SelectionRow.swift` |
| `AthleticPicker.swift` | `struct AthleticSelectionRow` | Molécula | `DesignSystem/Molecules/AthleticSelectionRow.swift` |
| `RankingRow.swift` | `struct RankingRow` | Molécula | `DesignSystem/Molecules/RankingRow.swift` |
| `SportsView.swift` | `struct CompetitionRow` | Molécula | `DesignSystem/Molecules/CompetitionRow.swift` |
| `MatchDetailView.swift` | `struct CompetitionLinkRow` | Molécula | `DesignSystem/Molecules/CompetitionLinkRow.swift` |
| `MatchDetailView.swift` | `struct PlayRow` | Molécula | `DesignSystem/Molecules/PlayRow.swift` |
| `MatchCard.swift` | `struct MatchCard` | Organismo | `DesignSystem/Organisms/MatchCard.swift` |
| `MatchHeaderCard.swift` | `struct MatchHeaderCard` | Organismo | `DesignSystem/Organisms/MatchHeaderCard.swift` |
| `TrialCard.swift` | `struct TrialCard` | Organismo | `DesignSystem/Organisms/TrialCard.swift` |
| `AthleticPicker.swift` | `struct AthleticPicker` | Organismo | `DesignSystem/Organisms/AthleticPicker.swift` |
| `RankingView.swift` | `struct Podium` | Organismo | `DesignSystem/Organisms/Podium.swift` |
| `ScheduleView.swift` | `struct ScheduleItemLink` | Organismo | `DesignSystem/Organisms/ScheduleItemLink.swift` |
| `Schedule/AgendaSummary.swift` | `struct AgendaSummary` | Organismo | `DesignSystem/Organisms/AgendaSummary.swift` |
| `MatchDetailView.swift` | `struct PartialsTable` | Organismo | `DesignSystem/Organisms/PartialsTable.swift` |
| `MatchDetailView.swift` | `struct PlayHistorySection` | Organismo | `DesignSystem/Organisms/PlayHistorySection.swift` |
| `MatchDetailView.swift` | `struct MatchInfoSection` | Organismo | `DesignSystem/Organisms/MatchInfoSection.swift` |
| `AthleticDetailView.swift` | `struct AthleticSummaryCard` | Organismo | `DesignSystem/Organisms/AthleticSummaryCard.swift` |
| `CompetitionDetailView.swift` | `struct CompetitionSummaryCard` | Organismo | `DesignSystem/Organisms/CompetitionSummaryCard.swift` |

---

### 2.2 Features (Modularização de Telas e Subcomponentes)

| Feature | Arquivo Atual | Novo Caminho Modularizado | Descrição |
|---|---|---|---|
| **Mocks / Core** | `ScheduleFilters.swift` | `Mocks/ScheduleItem.swift` | Modelo polimórfico de item do cronograma (`.match` / `.trial`) |
| **Mocks / Core** | `HomeView.swift` | `Mocks/ContentScope.swift` | Escopo canônico `ContentScope` (`.favorite`, `.general`) |
| **Schedule** | `ScheduleFilters.swift` | `Features/Schedule/ScheduleFilters.swift` | Struct com os critérios de filtro |
| **Schedule** | `ScheduleFilters.swift` | `Features/Schedule/ScheduleFilterSheet.swift` | Sheet com os campos de filtro |
| **Schedule** | `ScheduleFilters.swift` | `Features/Schedule/Components/SportFilterPicker.swift` | Seletor de modalidade |
| **Schedule** | `ScheduleFilters.swift` | `Features/Schedule/Components/AthleticFilterPicker.swift` | Seletor de atlética para filtro |
| **Sports** | `SportsView.swift` | `Features/Sports/SportsFilters.swift` | Struct com os critérios de filtro |
| **Sports** | `SportsView.swift` | `Features/Sports/SportsFilterSheet.swift` | Sheet de filtro de modalidades |
| **Sports** | `CompetitionDetailView.swift` | `Features/Sports/Tabs/CompetitionMatchesTab.swift` | Aba Jogos da modalidade |
| **Sports** | `CompetitionDetailView.swift` | `Features/Sports/Tabs/CampaignTab.swift` | Aba Classificação / Mata-mata |
| **Sports** | `CompetitionDetailView.swift` | `Features/Sports/Tabs/TrialInfoTab.swift` | Aba Prova classificatória |
| **Sports** | `CompetitionDetailView.swift` | `Features/Sports/Tabs/TrialResultsTab.swift` | Aba Resultados da prova |
| **Athletic** | `AthleticDetailView.swift` | `Features/Athletic/Tabs/AthleticMatchesTab.swift` | Aba Agenda da atlética |
| **Athletic** | `AthleticDetailView.swift` | `Features/Athletic/Tabs/AthleticAboutTab.swift` | Aba Sobre a atlética |
| **Athletic** | `AthleticDetailView.swift` | `Features/Athletic/Tabs/AthleticSportsTab.swift` | Aba Modalidades da atlética |
| **Athletic** | `AthleticDetailView.swift` | `Features/Athletic/Components/FavoriteChoice.swift` | Bloco de ação da atlética de coração |

---

## 3. Estrutura de Diretórios Final

```text
CircuitoInteratleticoDesign/
├── App/
│   ├── AppState.swift
│   ├── CircuitoInteratleticoDesignApp.swift
│   └── MainTabView.swift
│
├── Mocks/
│   ├── Athletic.swift
│   ├── Competition.swift
│   ├── CompetitionProgress.swift
│   ├── ContentScope.swift
│   ├── LoadState.swift
│   ├── Match.swift
│   ├── MockCompetitions.swift
│   ├── MockData.swift
│   ├── MockMatches.swift
│   ├── Ranking.swift
│   └── ScheduleItem.swift
│
├── DesignSystem/
│   ├── Tokens/
│   │   ├── ButtonStyles.swift
│   │   ├── CardModifiers.swift
│   │   ├── Formatters.swift
│   │   └── Tokens.swift
│   ├── Atoms/
│   │   ├── AthleticBadge.swift
│   │   ├── ChoiceChip.swift
│   │   ├── CircleIconLabel.swift
│   │   ├── CountBadge.swift
│   │   ├── InlineNote.swift
│   │   ├── LiveBadge.swift
│   │   ├── MatchStatusTag.swift
│   │   ├── RemovableChip.swift
│   │   ├── ScoreBoxes.swift
│   │   ├── SearchField.swift
│   │   ├── SelectorLabel.swift
│   │   ├── Toast.swift
│   │   └── UpdatedAgoText.swift
│   ├── Molecules/
│   │   ├── ActiveFiltersBar.swift
│   │   ├── AthleticSelectionRow.swift
│   │   ├── CompetitionLinkRow.swift
│   │   ├── CompetitionRow.swift
│   │   ├── FlowChips.swift
│   │   ├── NotificationRow.swift
│   │   ├── PlayRow.swift
│   │   ├── RankingRow.swift
│   │   ├── SectionHeader.swift
│   │   ├── SelectionRow.swift
│   │   ├── TeamColumn.swift
│   │   └── UnderlineTabs.swift
│   └── Organisms/
│       ├── AgendaSummary.swift
│       ├── AthleticPicker.swift
│       ├── AthleticSummaryCard.swift
│       ├── CompetitionSummaryCard.swift
│       ├── MatchCard.swift
│       ├── MatchHeaderCard.swift
│       ├── MatchInfoSection.swift
│       ├── PartialsTable.swift
│       ├── PlayHistorySection.swift
│       ├── Podium.swift
│       ├── ScheduleItemLink.swift
│       └── TrialCard.swift
│
└── Features/
    ├── Athletic/
    │   ├── AthleticDetailView.swift
    │   ├── Components/
    │   │   └── FavoriteChoice.swift
    │   └── Tabs/
    │       ├── AthleticAboutTab.swift
    │       ├── AthleticMatchesTab.swift
    │       └── AthleticSportsTab.swift
    ├── Home/
    │   ├── Components/
    │   │   ├── HomeFeedView.swift
    │   │   ├── HomeHeader.swift
    │   │   ├── HomeLiveSection.swift
    │   │   ├── HomeLoadingSkeleton.swift
    │   │   ├── HomeMatchSection.swift
    │   │   ├── LiveCarousel.swift
    │   │   ├── MatchCarousel.swift
    │   │   └── MatchListKind.swift
    │   ├── FavoriteAthleticSheet.swift
    │   └── HomeView.swift
    ├── Match/
    │   └── MatchDetailView.swift
    ├── Notifications/
    │   ├── Components/
    │   │   ├── NotificationsListView.swift
    │   │   ├── NotificationsLoadingSkeleton.swift
    │   │   └── PermissionCard.swift
    │   └── NotificationsView.swift
    ├── Onboarding/
    │   └── OnboardingView.swift
    ├── Ranking/
    │   ├── Components/
    │   │   ├── DivisionRankingContent.swift
    │   │   ├── RankingHeader.swift
    │   │   ├── RankingLoadingSkeleton.swift
    │   │   └── RankingSearchResultsView.swift
    │   └── RankingView.swift
    ├── Schedule/
    │   ├── Components/
    │   │   ├── AthleticFilterPicker.swift
    │   │   ├── DayTabs.swift
    │   │   ├── ScheduleDayContent.swift
    │   │   ├── ScheduleHeader.swift
    │   │   ├── ScheduleTimeline.swift
    │   │   └── SportFilterPicker.swift
    │   ├── ScheduleFilterSheet.swift
    │   ├── ScheduleFilters.swift
    │   └── ScheduleView.swift
    └── Sports/
        ├── CompetitionDetailView.swift
        ├── Components/
        │   ├── SportsHeader.swift
        │   ├── SportsListView.swift
        │   └── SportsLoadingSkeleton.swift
        ├── SportsFilterSheet.swift
        ├── SportsFilters.swift
        ├── SportsView.swift
        └── Tabs/
            ├── BracketTab.swift
            ├── CampaignTab.swift
            ├── CompetitionMatchesTab.swift
            ├── TrialInfoTab.swift
            └── TrialResultsTab.swift
```

---

## 4. Fases de Execução

1. **Fase 1: Modelos e Escopos Compartilhados**
   - Criar `ScheduleItem.swift` e `ContentScope.swift` em `Mocks/`.
   - Atualizar imports/usos em `HomeView`, `NotificationsView`, `SportsView` e `ScheduleFilters`.
   - Compilar via `xcodebuild` para validar integridade inicial.

2. **Fase 2: Reestruturação do Design System em Atomic Design**
   - Criar pastas `Tokens/`, `Atoms/`, `Molecules/`, `Organisms/` em `DesignSystem/`.
   - Decompor e migrar arquivos que possuíam 2 ou mais componentes.
   - Compilar via `xcodebuild` para garantir que todos os símbolos foram exportados e resolvidos.

3. **Fase 3: Promoção de Componentes das Features para o Design System**
   - Mover `Podium`, `CompetitionRow`, `SelectorLabel` e `ScheduleItemLink` para suas respectivas camadas do Design System.
   - Compilar via `xcodebuild`.

4. **Fase 4: Modularização das Telas Complexas**
   - Decompor `MatchDetailView`, `AthleticDetailView`, `CompetitionDetailView`, `ScheduleFilters` e `SportsView` em suas subpastas `Tabs/` e `Components/`.
   - Compilar via `xcodebuild`.

5. **Fase 5: Previews e Homologação**
   - Garantir que cada componente atômico, molecular e organismo mantenha seu bloco `#Preview`.
   - Executar build completo no simulador iOS (`iPhone 16`) garantindo 0 erros e 0 avisos.
   - Atualizar `PROJECT_STATUS.md`.
