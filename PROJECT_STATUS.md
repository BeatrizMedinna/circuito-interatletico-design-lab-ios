# Circuito Inter-Atlético — Status do Design Lab

## Etapa atual
- Plataforma: iOS / iPhone — SwiftUI (target convertido de macOS para iOS em 17/10/2026; iOS 26.1, só iPhone, retrato).
- Fidelidade: **alta, em andamento** na branch `design/high-fidelity-ios` (base `72fb2af`). A média fidelidade monocromática está validada no `main`.
- Paleta: Dark fixo com marca Lime `#B7F34B` + Teal `#2DD4BF` (Etapa 1); variantes claras e de alto contraste preparadas.
- Dados: mockados; sem backend.
- Ambiente: projeto Xcode local separado do repositório dos desenvolvedores.

## Referências
- `References/Documentos/documento-fonte-da-verdade.md` (v1.3.0) — único documento de domínio, de propósito (consolida visão, negócio, requisitos, casos de uso, classes e banco).
- `References/Personas/Personas.md` — 4 personas; a persona do app iOS é **Thiago** (torcedor/atleta).
- `References/Figma/` — 17 telas mobile (PNG 2x). São referência visual e funcional, não especificação imutável.

## Inventário de telas do Figma (app do torcedor)
| # | Tela | Status |
|---|---|---|
| 01 | Escolha sua Atlética (onboarding) | **Validada** |
| 02 | Início (abas Atlética/Geral, ao vivo, próximos e últimos jogos) | **Validada** (Bloco 2 adicionou a atlética de coração) |
| 03 / 04 / 05 | Jogo ao vivo / encerrado / a iniciar | **Validada** |
| 06 | Notificações (Minha Atlética / Geral) | **Validada** (Bloco 2 adicionou lidas e permissão) |
| 07 / 08 | Cronograma / filtros | **Validada** |
| 09 | Ranking por divisão (pódio + lista) | **Validada** |
| 10 / 11 / 12 | Atlética: info / cronograma / ranking | **Validada** (Bloco 4 ligou a aba Modalidades) |
| 13 | Modalidades (busca + filtro) | **Validada** · refinamento em validação |
| 14 / 15 / 16 | Modalidade: cronograma / chaveamento / ranking | **Validada** |
| 17 | Filtros de modalidades | **Validada** |

## Fluxos identificados
- Primeiro acesso → 01 Escolha da atlética → app com 4 tabs (Início, Cronograma, Ranking, Modalidades).
- Início → Jogo (03/04/05 conforme status) · sino → Notificações.
- Cronograma → Jogo · filtros em sheet (08).
- Ranking → Atlética (10–12) → Modalidade / Jogo.
- Modalidades → Modalidade (14–16) → Atlética / Jogo · filtros em sheet (17).
- Cada tab terá seu próprio `NavigationStack`; tab bar sempre visível nos pushes.

## Componentes compartilhados
Criados no Bloco 4:
- `Mocks/Competition.swift`: `Competition` (modalidade × divisão), `CompetitionFormat`, `RankingCriterion`, `MarkUnit` (formata tempo, distância, pontos, quantidade), `Trial`, `TrialResult`, `ResultSituation`, `RankedResult`, `BracketRound`, `BracketMatchup`, `Phase`.
- `Mocks/CompetitionProgress.swift`: chave (explícita ou montada a partir das partidas), vencedor, momento da modalidade, campanha no mata-mata e situação de cada atlética.
- `Mocks/MockCompetitions.swift`: 16 modalidades (12 eliminatórias, 3 provas, 1 sem chave), duas chaves completas com bye e "a definir".
- `TrialCard` (prova no cronograma), `CompetitionRow`, `FlowChips` (agora compartilhado), `RankingRow.showsPosition`, `MatchCard.caption`.
- `ScheduleItem` (partida ou prova) no Cronograma; `AppRoute.competition`.

Criados no Bloco 3:
- `RankingRow` (posição, escudo, nome, pontos, empate, "Sua atlética").
- `UnderlineTabs` ganhou ícone opcional e passa a rolar quando as abas não cabem.
- `MatchHeaderCard` ganhou `linksTeams` (no detalhe da partida, cada time abre a atlética).
- `Mocks/Ranking.swift`: `RankingEntry`, `DivisionRanking`, `SportStanding`, `AthleticProfile` e dados fictícios; 8 atléticas novas em `MockData` (17 no total) e `MockData.divisions`.
- `AppRoute.athletic` e `AppRoute.matchList(_, athleticID)` (a lista "Ver mais" agora é por atlética ou geral).

Criados no Bloco 2:
- `AthleticPicker` (+ `SelectionRow`, `AthleticSelectionRow`): busca + lista de escolha única, usado no onboarding, na troca da atlética e no filtro.
- `ChoiceChip` e `RemovableChip` (Chips.swift), `Toast`, `CountBadge`; `CircleIconLabel` ganhou `isActive`.
- `MatchCard` ganhou `date` (`.dayAndTime`, `.time`, `.none`) e `showsVenue`.
- `AppState`: atlética de coração opcional, leitura dos avisos, permissão simulada e aviso rápido (toast). `AppRoute` (antes `HomeRoute`) serve Início e Cronograma.

Criados no Bloco 1:
- `MatchCard` (+ `TeamColumn`, `MatchStatusTag`, `teamSideBars()`), `ScoreBoxes`, `MatchHeaderCard` (+ `LiveBadge`, `UpdatedAgoText`), `UnderlineTabs`, `SectionHeader`, `CircleIconLabel`, `InlineNote`, `Formatters` (datas pt-BR, 24h) e o estilo `.pressableCard`.
- `AthleticBadge` ganhou o tamanho `.prominent` e a variante `isUndefined` (borda tracejada + "?").
- `Mocks/`: `Match`, `Sport`, `Play`, `PeriodScore`, `AppNotification`; `MockMatches.swift` com 13 partidas e 6 avisos (datas relativas a "agora").
- `App/AppState.swift`: estado compartilhado (atlética de coração, partidas, avisos, cenário). `App/MainTabView.swift`: abas e rotas da Início.

Criados na tela 01:
- `DesignSystem/Tokens.swift` — cores semânticas (`appBackground`, `canvas`, `surface`, `surfaceSelected`, `textPrimary`, `textSecondary`, `textOnAccent`, `borderStrong`, `actionPrimary`, `disabledFill`, `disabledText`), `Spacing`, `Radius`.
- `DesignSystem/AthleticBadge.swift` — escudo circular (small/medium/large), escala com Dynamic Type até 1,5×.
- `DesignSystem/SearchField.swift` — busca com botão de limpar.
- `DesignSystem/ButtonStyles.swift` — `.primary` (largura total, estado desabilitado) e `.secondary` (contorno).
- `Mocks/` — `Athletic`, `Division`, `Edition`, `LoadState` (loading / loaded / failed / unavailable) e `MockData` (9 atléticas, 3 séries).
- Estados vazios/erro usam o `ContentUnavailableView` nativo.

Previstos (criados só quando a tela precisar): IconTabs, RankingRow, ListRowWithIcon, EntityHeaderCard, FilterSheet/ChipGroup, Podium.

## Telas em desenvolvimento
### Alta fidelidade — Etapa 5: Cronograma e Detalhe da Partida (26/10/2026) — em validação
Diagnóstico: abas de dias com sublinhado branco; trilho da linha do tempo branco (pesado no Dark); nomes longos ("Atlética Acadêmica Nicolau Carvalho Esteves") truncados e reduzidos mesmo no cartão de largura total; no detalhe, rótulos de Informações mais fortes que os valores, duas colunas em texto grande, tabela de parciais rolando na horizontal com períodos escondidos em texto grande **e com nome longo em qualquer tamanho** (defeito anterior: os períodos saíam da tela); lances com coluna de horário estreita em texto grande.

5A — Cronograma:
- `DayTabs`: dia selecionado com sublinhado Lime; demais neutros; trilho de 1 pt sob as abas (`ScheduleHeader`).
- `ScheduleTimeline`: horário em `subheadline` semibold; trilho em cinza forte nos horários iniciados e discreto nos próximos.
- Cartões: `MatchCard` ganhou `stacksLongNames` (opcional, padrão desligado) e `ScheduleItemLink` ganhou `adaptsMatchLayout` (padrão desligado), ligado só na linha do tempo — nomes longos (> 20 caracteres, `TeamRow.isLongName`) e texto ≥ xxxLarge empilham os times. Agendas de Atlética e Modalidade seguem em colunas.
- Provas (`TrialCard`), filtros, sheet e estados vazios conferidos sem mudança: já seguiam o Design System (✕ neutro, ✓ Lime, "Limpar" secundário). Fundo da sheet mantido (`appBackground`, cor sólida da paleta, sem material personalizado).

5B — Detalhe da Partida:
- `MatchHeaderCard`: `stacksLongNames` (opcional) e layout empilhado agora também com os links para a atlética; o detalhe liga as duas opções.
- `MatchInfoSection`: valor em texto primário semibold, rótulo secundário; uma coluna em tamanhos de acessibilidade.
- `PartialsTable`: números em SF Pro Rounded; nome em até 2 linhas; tabela sempre na largura da tela (corrige períodos fora da tela com nome longo); em tamanhos de acessibilidade vira tabela vertical (linha por período, coluna por time, período atual com faixa Lime).
- `PlayRow`: em tamanhos de acessibilidade, período · minuto · placar numa linha acima do lance.
- Consumidores: `PartialsTable`, `PlayRow`/`PlayHistorySection` e `MatchInfoSection` só existem no detalhe da partida.

Testes (iPhone 17 Pro, toques reais com pausas): fluxos 1 (Início → Ver mais), 2 (Ranking → Atlética → Agenda → Ver todos), 3 (Modalidade → Jogos → Ver todos: Basquete, Masculino, Série Ouro), 4 (Cronograma → Partida → Voltar com filtros mantidos), 5 (filtros combinados → aplicar → Limpar → ✕ mantém os aplicados), 6 (Detalhe → Ver chave → modalidade) e 7 (trocar atlética → Teal no cartão e no detalhe); dia sem eventos e "Nada com esses filtros"; ao vivo, encerrado, a iniciar e prova parcial; mesmos placares, parciais e ordem dos lances do baseline. Capturas: acessibilidade L (detalhe, parciais verticais, lances), Aumentar contraste, iPhone 16e (Cronograma e detalhe). Início conferida: igual à Etapa 4. VoiceOver e Reduzir movimento não testados.

Pendências:
- Nome longo ainda abrevia na tabela de parciais horizontal (2 linhas) e quebra sílabas na tabela vertical; nome completo no cabeçalho e no VoiceOver.
- Abas de período do Histórico em texto grande rolam e a selecionada pode começar fora da tela (`UnderlineTabs`, compartilhado).
- `FlowChips` quebra as divisões em coluna quando uma fica selecionada (salto de layout na sheet de filtros).
- Carrosséis da Início podem ligar `stacksLongNames` (uma linha) — depende de aprovação, pois a Início ficou fora desta etapa.

### Alta fidelidade — Etapa 4: Início (26/10/2026) — em validação
Diagnóstico: cabeçalho fixo (edição, sino com contador, seletor da atlética de coração, abas "Minha atlética | Geral" quando há atlética e jogos), carrossel ao vivo paginado (ou nota "sem jogo ao vivo"), "Próximos jogos" e "Últimos jogos" em carrosséis com "Ver mais" (até 5 cartões, borda do próximo visível). Estados: carregando, erro, sem edição, cronograma não publicado, atlética sem jogos, seções vazias. A Início só mostra partidas (provas ficam no Cronograma). Problemas: no texto de acessibilidade o sino crescia além do círculo e o contador o cobria, "Atlética de coração" quebrava e truncava, nomes truncavam nos cartões; indicador de página inativo com 1,45:1; esqueleto de carregamento mostrava anéis Teal.

Implementado:
- Cabeçalho (`HomeHeader`): sino e contador limitados ao maior tamanho padrão (xxxLarge), com visualizador de conteúdo ampliado do sistema ao tocar e segurar; seletor com anel Teal no escudo, seta junto do nome, nome em até 2 linhas; trilho de 1 pt sob as abas (como em Notificações); título reduz até 75% só quando uma palavra não cabe (maior tamanho de acessibilidade). Large Title nativo avaliado e descartado: mudaria a estrutura (sino na barra, seletor e abas fora dela).
- Ao vivo (`LiveCarousel`): indicador de página com inativos em cinza terciário (6,1:1) e atual mais longo; animação desligada com Reduzir movimento.
- Cartões: `MatchHeaderCard` e `MatchCard` ganharam a opção `stacksAtAccessibilitySizes` (padrão desligado), que empilha time A, placar e time B com a nova molécula `TeamRow` — ligada só na Início (cartão ao vivo em tamanhos de acessibilidade; cartões dos carrosséis a partir de xxxLarge). Detalhe da partida, Cronograma, Atlética e Modalidades continuam iguais.
- Esqueleto de carregamento sem destaque Teal.

Testes (iPhone 17 Pro, toques reais com pausas): Minha atlética e Geral (mesmos placares, horários e seções), "Ver mais" em Geral (Cronograma sem filtro) e em Minha atlética (filtrado por Búfalos, dia de hoje), detalhe da partida, troca da atlética pela sheet (Teal e nome longo em 2 linhas, nota "sem jogo ao vivo"), sino → Notificações e **"Ler todas" funcionando** (pendência da Etapa 3 resolvida). Capturas: carregando, Poraquê sem jogos, xxxLarge, acessibilidade L e XXXL, Aumentar contraste; iPhone 16e (iOS 26) padrão, xxxLarge e acessibilidade XL. Reduzir movimento e VoiceOver não testados.

Pendências:
- Nomes longos de atlética ainda truncam no `MatchCard` em tamanho padrão (avaliar sigla ou 3 linhas na Etapa 5, pois o cartão é compartilhado).
- No maior tamanho de acessibilidade o cabeçalho fixo ocupa quase metade da tela; deixar o cabeçalho rolar junto exigiria mudar a estrutura (pedir decisão).
- `SectionHeader` quebra o título em 2 linhas ao lado de "Ver mais" em tamanhos de acessibilidade (componente compartilhado).

### Alta fidelidade — Etapa 3: Navegação global (26/10/2026) — em validação
Diagnóstico: a navegação já usava os componentes nativos do iOS 26 — `TabView` com `Tab` (4 abas, cada uma com sua `NavigationStack`), barra de abas em Liquid Glass com seleção Lime e ícones preenchidos pelo sistema, botão Voltar nativo (monocromático), títulos em linha nos detalhes e efeito de borda nativo no topo. Sem fundos personalizados nas barras, sem vidro na camada de conteúdo. Rotas, destinos, `schedulePath`, filtros e a atlética de coração não foram alterados.

Refinamentos (só aparência):
- `DesignSystem/Tokens/NavigationStyles.swift` (novo): `barControlNeutral()` (fechar, cancelar, "Ler todas" em branco, como o padrão do iOS 26) e `barPrimaryAction()` (✓ "Aplicar filtros" em vidro preenchido Lime com símbolo On Lime, 12,6:1). Regra da HIG: barras monocromáticas, cor só na ação principal.
- Aplicado em `ScheduleFilterSheet`, `SportsFilterSheet`, `FavoriteAthleticSheet` e `NotificationsView` (uma linha em cada item da barra).
- `MainTabView`: `.scrollEdgeEffectStyle(.hard, for: .bottom)` — efeito de borda nativo mais forte sob a barra de abas; comprovado em captura com texto grande (o "Ver mais" Lime aparecia atrás dos rótulos). Reversível removendo a linha.

Atlética de coração: trocar pelo perfil (Imortal) e pela sheet da Início (Poraquê → Búfalos) atualizou o Teal na Início, Ranking/pódio, parciais e lances sem reiniciar, e a escolha seguiu entre abas. **A atlética de coração vive só na memória (`AppState`)**: ao fechar o app volta ao onboarding (ou ao `-labFavorite`). Comportamento anterior à alta fidelidade, não alterado.

Testes: build sem avisos; iPhone 17 Pro com toques reais nos fluxos A (Ranking → Atlética → Agenda → Ver todos), B (Modalidade → Jogos → Ver todos), C (Início → Ver mais), D (Partida → Ver chave → Voltar), E (troca de abas preservando a pilha) e F (Notificação → partida); "Aumentar contraste" e texto grande de acessibilidade por captura no 17 Pro; iPhone 16e (iOS 26) com texto padrão e grande. VoiceOver e "Reduzir transparência" não testados. Toques muito rápidos no simulador entregaram eventos fora de ordem; os fluxos foram refeitos com pausas.

Pendências para as etapas de tela:
- Início: no texto grande, o selo do sino sobrepõe o ícone e os nomes dos times truncam.
- Títulos genéricos "Atlética" e "Modalidade" nos detalhes (avaliar o nome da entidade).
- Sheet da atlética de coração: "Cancelar" em texto empurra o título; avaliar ✕ padrão.
- Fundos próprios das sheets (`appBackground`) cobrem o vidro das sheets do iOS 26 (HIG: revisar).
- Toast posicionado com margem fixa (96 pt) acima da barra de abas.

### Alta fidelidade — Etapa 2: Componentes reutilizáveis (26/10/2026) — em validação
Decisões aprovadas: cartões sem barras laterais; "Ver mais/Ver todos" em Lime com chevron; não lida = ponto Lime + título em negrito; contadores em Lime (vermelho só para "Ao vivo"); SF Pro Rounded em placares e números esportivos; atlética de coração destacada automaticamente em Teal a partir de `AppState.favoriteAthletic`.

Fundações complementares (`DesignSystem/Tokens/`):
- `Typography.swift` (novo): `scoreLarge`, `scoreCompact`, `sportNumber(_:)` (SF Pro Rounded, segue o Dynamic Type), `sectionTitle`, `eyebrow`.
- `CardModifiers.swift`: `teamSideBars()` removido; `cardSurface(_:cornerRadius:highlighted:)` com estilos `standard`/`emphasized` (gradiente sutil) e contorno reforçado em cinza para partida ao vivo. `Radius.card` 14 → 16.
- `FavoriteEnvironment.swift` (novo): valor de ambiente `favoriteAthleticID`, projetado em `MainTabView` a partir do `AppState` (mesma fonte de verdade e persistência).
- `ButtonStyles.swift`: estilo `.sectionLink` (Lime + chevron); botão secundário em `surfaceInset`.
- `PreviewAppearance.swift` (novo): trait `.appAppearance` — os 37 previews do DesignSystem abrem no escuro.

Átomos: `AthleticBadge` (anel Teal `isFavorite`, fundo `surfaceInset`), `ScoreBoxes` (Rounded), `LiveBadge` (caixa alta, fundo vermelho translúcido), `MatchStatusTag` (eyebrow; ao vivo vermelho, encerrado terciário), `ChoiceChip`, `RemovableChip`, `CircleIconLabel`, `CountBadge` (`onAccent` para botão Lime), `SearchField`, `SelectorLabel`, `Toast` (neutro com ✓ verde), `InlineNote` (tons neutro/atenção/erro).
Moléculas: `SectionHeader`, `UnderlineTabs` (sublinhado Lime), `TeamColumn`, `RankingRow` (Teal + "· Sua atlética" + barra Teal), `SelectionRow`, `NotificationRow` (ponto Lime; ícone amarelo em mudança de local/horário), `CompetitionRow`, `CompetitionLinkRow`, `PlayRow`, `ActiveFiltersBar`.
Organismos: `MatchCard`, `MatchHeaderCard`, `TrialCard` (status parcial com ícone de atenção), `Podium` (1º em Lime, Teal na sua atlética), `PartialsTable`, `AthleticSummaryCard` (corrigido: cartão era invisível no escuro), `CompetitionSummaryCard`, `MatchInfoSection`, `AthleticPicker`. `AgendaSummary` e `ScheduleItemLink` sem mudança de lógica.
Fora do DesignSystem (só chamada): `MainTabView` (ambiente), `ScheduleHeader` e `SportsHeader` (`CountBadge(onAccent: true)`). Models, Mocks, Services, rotas, filtros e Tab Bar não foram alterados.

Testes: build sem avisos (iPhone 17 Pro); no simulador 17 Pro, com toques reais: onboarding, Início, "Ver mais" → Cronograma filtrado, Ranking, perfil da atlética e "Ver todos" → Cronograma filtrado, Modalidades (lista e detalhe), Notificações. iPhone 16e: Início no tamanho padrão e em texto grande de acessibilidade, sem cortes.

Pendências:
- `DayTabs` do Cronograma ainda com sublinhado branco (Etapa 5, telas).
- Algumas telas ainda passam `fill: .surface` para o escudo (ex.: cabeçalho da Início).
- Tons do `InlineNote` disponíveis, ainda não usados pelas telas.
- Previews das Features ainda no claro; VoiceOver e "Aumentar contraste" não retestados nesta etapa.

### Alta fidelidade — Etapa 1: Fundações (26/10/2026) — em validação
Decisões aprovadas: Dark fixo no protótipo com variantes preparadas; "ao vivo" em vermelho `#FF5C5C` sempre com ponto/rótulo; Teal `#2DD4BF` = atlética de coração (não é cor de sucesso); neutros escuros com leve viés verde. Card ao vivo da Início **sem** contorno vermelho (usa `borderStrong`, cinza), a pedido da designer.

Implementado:
- `Assets.xcassets/Palette/`: 17 Color Sets com variantes clara, escura, clara alto contraste e escura alto contraste (base, surface 1–3, separador, borda forte, texto 1–3, marca, preenchimento da marca, sobre-marca, atlética de coração, ao vivo, sucesso, atenção, erro). `AccentColor`: Lime no escuro, Lime Strong no claro.
- `Tokens.swift`: os nomes existentes passaram a ler os Color Sets (`appBackground`/`canvas` → base `#0B0E0C`, `surface` → `#151A17`, `surfaceSelected` → `#2A312C`, `actionPrimary` → Lime, `textOnAccent` → On Lime `#152211`…). Novos papéis: `surfaceInset`, `separatorLine`, `textTertiary`, `brandPrimary`, `favoriteAccent`, `live`, `success`, `warning`, `critical`. Telas não mudaram.
- Aparência: `INFOPLIST_KEY_UIUserInterfaceStyle = Dark` (antes Light) no `project.pbxproj` (autorizado); `.preferredColorScheme(.light)` removido; `.tint(.brandPrimary)` na raiz. Para seguir o sistema no futuro, basta remover a chave do Info.plist.
- Cores fixas trocadas por tokens: barras laterais dos cartões (`CardModifiers`) e linhas da tabela de parciais.
- "Ao vivo" vermelho nos átomos `LiveBadge` e `MatchStatusTag` e no título do detalhe da partida.

Contrastes (WCAG, escuro): texto primário 14,2–17,7:1; secundário 6,0–8,7:1; terciário ≥ 4,9:1 em base/surface 1/surface 2 (não usar em surface 3); Lime 10,1–14,7:1; Teal 7,2–10,4:1; ao vivo 5,8:1 (surface 1) e 6,4:1 (base); On Lime sobre Lime 12,6:1; borda forte 4,1:1. Claro: terciário 4,6–5,4:1; Lime Strong/Teal Strong ~5,0–5,5:1.

Limitações e pendências para a Etapa 2:
- Teal ainda não aplicado nos componentes (Início, Ranking, perfil); `success`/`warning`/`critical` definidos mas não usados.
- `Toast` e `CountBadge` herdaram o Lime de `actionPrimary`; avaliar toast neutro com ícone de sucesso.
- Escala tipográfica continua nos estilos do sistema (SF Pro + Dynamic Type); estilos de placar/destaque entram com os componentes.
- Previews do Xcode aparecem no claro (o Info.plist não vale no Canvas).

### Refinamento de UX (19/10/2026) — em validação
- **Cronograma:** abas de dia sem contagem ("Hoje" segue identificando o dia atual); barra de filtros ativos com botão preto ✕ (limpar tudo) fixo à esquerda, separado por um traço, e ✕ em cada pílula (`ActiveFiltersBar`, também em Modalidades); coluna de horário mais estreita (fonte footnote, largura mínima 40 pt, cresce com Dynamic Type sem cortar).
- **"Ver mais" da Início → Cronograma** (`AppState.openSchedule`): troca de aba, volta o Cronograma à raiz, aplica a atlética da aba de origem (ou nenhuma em "Geral") e abre no dia certo — próximo jogo ("Próximos") ou último dia com encerrado ("Últimos"), rolando até ele. Filtros continuam editáveis. A lista intermediária (`MatchListView`) foi removida.
- **Perfil da atlética:** sem o coração na barra. Ação textual no resumo: "Escolher como atlética de coração", "Trocar para [nome]" (com "Hoje você torce por X. Só dá para ter uma…") ou "Remover atlética de coração" + "Sua atlética" na própria. Início mantém a troca sob o título; Ranking mantém o destaque.
- **Modalidades:** linha com duas informações (nome com categoria; divisão · estado curto, sem datas) e selo ao vivo; sem coração decorativo. Abas "Minha atlética | Geral" como na Início (some sem atlética de coração; estado vazio com "Ver todas as modalidades"); Categoria e Divisão continuam nos filtros, aplicados sobre a aba.
- **Agendas contextuais (resumo):** aba "Agenda" da atlética (jogos e provas) e aba Jogos da modalidade usam o mesmo `AgendaSummary`: "Ao vivo e próximos" (tudo ao vivo/em andamento + só o próximo) e "Último encerrado" (só o mais recente). "Ver todos" abre o Cronograma com a origem (atlética, ou esporte + categoria + divisão) e o foco da seção. Decisão: "Ver todos" só aparece quando há mais eventos do que os mostrados, e seções vazias somem.
- **Torcidômetro:** aviso mockado "Ultrapassagem no ranking" passou a "Liderança no Torcidômetro" para não sugerir que mexe no Ranking.

### Bloco 4 — Modalidades (13–17)
Lista (13) e filtros (17) — `Features/Sports/SportsView.swift`:
- Cada linha é uma modalidade numa divisão: ícone do esporte, nome (com a prova, ex.: "Natação Masculino · 50m livre"), divisão · formato e o momento (fase atual, "Resultados parciais", "Começa…", "Encerrada · Campeã: X", "Chave ainda não definida"); selo "ao vivo"; coração quando a atlética de coração disputa.
- Busca por nome; filtros Categoria e Divisão em meia tela (rascunho, ✕/✓, "Limpar", contagem); filtros ativos em pílulas e no botão.
- Estados: carregando, erro, sem edição, modalidades não divulgadas, busca/filtros sem resultado (com "Limpar busca" e "Limpar filtros").

Detalhe — `CompetitionDetailView` (o formato muda as abas):
- Eliminatória → **Jogos** (ao vivo e próximos, depois encerrados, com a fase no cartão), **Chave** (15) e **Classificação** (16).
- Classificatória → **Prova** (data, local, critério, unidade, individual/equipe, situação) e **Resultados** (16).
- Resumo: divisão, etapa/situação, atletas, "Jogo ao vivo agora" e "Campeã: X".
- Chave: uma fase por vez (abre na atual); confrontos com situação, placar, ✓ no vencedor, perdedor em cinza, W.O., bye ("avança direto, sem jogo"), "A definir" e para onde o vencedor segue. Tocar abre a partida.
- Classificação do mata-mata: sem pontos; mostra até onde cada atlética chegou (Campeã, Vice-campeã, Na semifinal, Eliminada nas quartas…), com aviso explicando.
- Resultados da prova: marca formatada pela unidade, empates "2º=", ausente/desistência/desclassificado sem posição, "Resultados parciais" antes do encerramento, "Aguardando resultado" para inscritas sem marca, prova por equipe mostra a atlética.
- Estados: chave não definida, prova agendada sem resultados, modalidade indisponível.

Integrações:
- Cronograma mostra provas (`TrialCard`, borda tracejada quando parcial) junto com as partidas; filtros valem para as duas. Isso resolve a pendência "provas no cronograma".
- Detalhe da partida → "Ver chave e classificação" da modalidade.
- Atlética › Modalidades: situação real de cada modalidade (antes, posições fictícias), com seta para a modalidade.

### Bloco 3 — Ranking e Atléticas (09–12)
Ranking (`Features/Ranking/`):
- Abas por divisão (abre na divisão da atlética de coração), pódio 2º·1º·3º e lista a partir do 4º; tocar abre a atlética.
- Empate: mesma posição, mesmo degrau no pódio e "empate" na linha.
- Busca em todas as divisões (nome ou sigla); atléticas sem classificação aparecem com "—".
- Estados: carregando, erro, sem edição, ranking não disponível, divisão sem classificação (com "Ver [outra divisão]"), busca sem resultado (com "Limpar busca").
- Atlética de coração destacada (barra preta, coração, "Sua atlética").

Atlética (`Features/Athletic/AthleticDetailView.swift`), acessada pelo Ranking, pela busca e pelos times no detalhe da partida:
- Resumo: escudo, nome, instituição, Divisão, Lugar, Pontos, Torcedores ("—" quando não há dado; 2×2 se não couber).
- Abas com ícone e texto: Jogos (ao vivo, próximos e últimos, até 3 por seção + "Ver mais"), Sobre (sigla, instituição, descrição ou aviso de que não há), Modalidades (colocação ou "Ainda sem resultado").
- Coração na barra: torcer ou deixar de torcer; Início, Ranking, Notificações e filtros atualizam na hora.
- Estados: atlética sem jogos, sem descrição, sem classificação, sem modalidades, atlética indisponível.

### Bloco 2 — Cronograma e Filtros (07–08) + pendências do Bloco 1
Cronograma (`Features/Schedule/`):
- Abas de dias do cronograma publicado (inclui dia sem jogos), com "Hoje" e a quantidade de jogos (já filtrada) em cada dia; começa em hoje.
- Linha do tempo por horário: vários jogos no mesmo horário ficam juntos; linha preta nos horários já iniciados e cinza nos próximos; hoje abre no primeiro jogo ao vivo ou por começar.
- Cartões com situação (ao vivo, a iniciar, encerrado, W.O., a definir) e local; tocar abre o detalhe já existente.
- Estados: carregando, erro com nova tentativa, sem edição, não publicado, dia sem jogos e filtros sem resultado, ambos com saída ("Ver [dia com jogos]" e "Limpar filtros").
- Fonte de acessibilidade: o horário passa para cima dos jogos.

Filtros:
- Modalidade (lista), Categoria (Masculino/Feminino/Misto, só as que existem), Atlética (atalho "Minha atlética" + lista com busca), Divisão. Os campos se combinam.
- Rascunho: ✕ descarta, ✓ aplica, "Limpar" zera; o rodapé mostra quantos jogos o rascunho encontra.
- Filtros ativos: botão preto com contador e pílulas removíveis abaixo dos dias, mais "Limpar".

Atlética de coração (RN-86):
- Abaixo do título da Início, toque abre um sheet com a mesma lista do onboarding: "Salvar" (só quando muda) e "Remover atlética de coração".
- Sem atlética: Início e Notificações mostram tudo e escondem as abas "Minha atlética | Geral"; o atalho do filtro some. Ao escolher, a Início volta para "Minha atlética". Toast confirma a mudança.

Notificações:
- Não lidas: barra preta à esquerda (do wireframe) e título em negrito; lidas: texto em cinza. Abrir um aviso o marca como lido; ao voltar, a lista mantém a posição.
- Sino com contador de não lidas; "Ler todas" na barra; toque longo marca como lida/não lida.
- Permissão (RN-87): convite na tela de Notificações → alerta simulado do iOS → concedida (some), negada (cartão com "Abrir Ajustes") ou "Agora não" (some até reabrir o app).

### Bloco 1 — Início, partidas e notificações (telas 02–06)
Fluxos:
- Onboarding → abas (Início, Cronograma, Ranking, Modalidades). Só Início está prototipada; as outras mostram "próximo bloco" (sem becos sem saída: a tab bar sempre leva de volta).
- Início → cartão ao vivo / próximo / último → detalhe da partida → voltar.
- Início → "Ver mais" → lista completa agrupada por dia → partida.
- Início → sino → Notificações → aviso com partida → detalhe da partida.
- Puxar para atualizar em Início, listas, detalhe e notificações (renova "Atualizado há…").

Estados cobertos:
- Início: carregando, erro com "Tentar novamente" (a segunda tentativa funciona), sem edição ativa, cronograma não publicado, atlética sem jogos (com "Ver todos os jogos"), sem jogo ao vivo, sem próximos, sem últimos, um ou vários ao vivo (carrossel com indicador de página).
- Partida: ao vivo (com e sem lances, quartos ou sets), encerrada (com lances, 5 sets, W.O., sem lances registrados), a iniciar (com aviso de quando o placar aparece), adversário "A definir", partida indisponível.
- Notificações: com avisos agrupados por dia, aba sem avisos da atlética (com "Ver avisos gerais"), sem avisos, carregando, erro, sem edição. Só os avisos com partida são tocáveis (chevron).

Melhorias de UX (preservam a intenção do wireframe):
- Uma única tela de partida (`MatchDetailView`) para 03/04/05; título "● Ao vivo / Encerrado / A iniciar" na barra.
- Cabeçalhos com fundo branco e conteúdo cinza, como no onboarding validado (consistência).
- "Atlética" → "Minha atlética" nas abas da Início, igual às Notificações.
- Nome da atlética escrito nos lances e nas parciais: no monocromático os escudos são iguais e não identificam o time.
- Vencedor destacado sem cor: placar e nome de quem perdeu ficam em cinza; W.O. mostra "W.O." e um aviso com o vencedor.
- Partida ao vivo também com borda forte (não só o selo).
- Carrosséis mostram a ponta do próximo cartão; "Ver mais" aparece só quando há mais de um jogo.
- Informações da partida incluem a Divisão (dado do domínio).
- Horários mockados alinhados a slots de :00/:30 (RN-52).
- Dynamic Type: placar limitado a xxLarge e escudos a 125% para caber; parciais rolam na horizontal; coluna de tempo dos lances escala.

Como testar cenários no simulador (Xcode › Edit Scheme › Run › Arguments):
- `-labSkipOnboarding YES` abre direto na Início (atlética Búfalos).
- `-labFavorite ath-poraque` escolhe uma atlética sem jogos.
- `-labScenario empty|loading|error|unavailable` muda os dados de Início, Cronograma e Notificações.
- `-labNotifications authorized|denied` começa com a permissão já decidida.

### 01 — Escolha sua Atlética (`Features/Onboarding/OnboardingView.swift`) — validada
- Busca por nome ou sigla, sem diferenciar maiúsculas e acentos.
- Seleção única; "Entrar" fica desabilitado até escolher uma atlética.
- Estados: carregando (1 s simulado), lista, busca sem resultado, erro com "Tentar novamente", edição indisponível.
- Previews: Sem seleção, Com seleção, Busca sem resultado, Carregando, Erro, Edição indisponível, Dynamic Type grande; e "Fluxo completo" no `App/`.
- Ajustes de UX em relação ao Figma: círculo vazio nas linhas não selecionadas (deixa clara a escolha única); selecionada = fundo mais escuro + borda de 2 pt + ✓ preenchido; nome da divisão real no lugar de "1º divisão"; lista em ordem alfabética; título da seção e busca fixos enquanto a lista rola; leve vibração (haptic) ao selecionar.
- Depois de "Entrar": abre o app com abas (Bloco 1).

## Telas validadas
- 01 — Escolha sua Atlética (17/10/2026, no simulador).
- 02–06 — Bloco 1: Início, partidas e notificações (19/10/2026, no simulador).
- 07–08 — Bloco 2: Cronograma e Filtros, com atlética de coração e notificações (19/10/2026).
- 09–12 — Bloco 3: Ranking e Atléticas (19/10/2026).

## Decisões confirmadas
- Mobile first; iOS nativo em SwiftUI; target existente convertido para iPhone (sem novo projeto).
- Média fidelidade monocromática, sem azul do sistema (AccentColor = preto); somente modo claro.
- Wireframes como referência: ajustes de hierarquia, espaçamento e usabilidade são permitidos com justificativa; mudanças grandes de navegação, funcionalidade ou arquitetura da informação precisam de aprovação.
- Funcionalidades dos wireframes sem suporte no domínio são **mantidas e simuladas** com mocks.
- Horários em formato 24h.
- Tab bar sempre visível nos pushes (inclusive 04, 05 e 06).
- Arquivos e pastas são criados só quando necessários; sem dependências externas.
- Painel web (Admin) e alta fidelidade ficam para fases posteriores.
- Desenvolvimento por blocos funcionais completos; diferenciar otimizações de UX (implementar), complementos necessários (implementar e registrar) e decisões de produto (pedir aprovação).

## Divergências registradas (wireframes × domínio)
1. Ranking geral com pontos (09) e "Lugar/Pontos" da atlética (10): classificação é 📝 e a tabela de pontuação não existe (P-08). Mantido com mocks.
2. Cronômetro e lances com minuto/período (03/04): o domínio não tem relógio de jogo nem período no basquete (só "número do set", RN-75); lances 🚧; tempo real 📝.
3. Notificações (06): o domínio só prevê aviso de mudança no cronograma (RN-62 📝); "Vai começar", "Ultrapassagem no Torcidômetro" e "É campeão" não existem.
4. Descrição da atlética (10): a entidade Atlética não tem esse campo.
5. Trocar ou ficar sem atlética de coração (RN-86) e permissão de notificações (RN-87) não têm tela.
6. Gênero "Misto" existe no domínio, mas os filtros (08, 17) só têm Masculino/Feminino.
7. Divisões têm nome livre (ex.: "Série Ouro"); wireframes usam "1º divisão".
8. Lista de Modalidades (13) mostra uma etapa por modalidade, mas a chave existe por modalidade **e** divisão.
9. Rótulo "DE" no chaveamento (15) não está definido; bye (RN-42) e atlética "a definir" não aparecem.
10. Personas usam nomes antigos (`ADMIN_SUPREMO`, `EM_EDICAO`/`SALVA`), substituídos pela seção 12 do documento-fonte, e citam recursos sem wireframe (estatísticas individuais/artilharia, card de resultado, abrir no mapa, histórico) — não antecipados.

## Pendências
**Hipóteses do Bloco 4:**
- Lista de Modalidades por modalidade × divisão (a chave e a prova existem por divisão, RN-39/RN-46).
- No mata-mata, a classificação mostra a fase alcançada; só campeã e vice têm posição. "Campeã" aparece quando a final termina (o registro oficial de campeões é 📝, RN-90).
- Prova sem estado "em andamento" no domínio: resultados lançados antes do encerramento aparecem como parciais (RN-50).
- Chaves das demais modalidades são montadas a partir das partidas mockadas e completadas até a final com "a definir".
- Marcas, inscritos e nomes de atletas são fictícios. Ajustei fases e adversários de algumas partidas mockadas para as chaves fazerem sentido (ex.: a final de Basquete Masculino agora é contra Lobos).

**Hipóteses do Bloco 3 (dados fictícios, sem regra oficial):**
- Pontos, posições, torcedores e colocação por modalidade são ilustrativos. A tabela de pontuação e os desempates não existem no domínio (P-08).
- Pontos iguais dividem a posição (como RN-49 nas provas); a ordem entre empatados é alfabética só para exibir.
- Classificação pode faltar em uma divisão (Série Bronze no mock) para testar o estado vazio.
- Descrição da atlética não existe no domínio; é mock e pode faltar.
- Colocação por modalidade não leva a lugar nenhum por enquanto (a tela de Modalidade é do Bloco 4).
- O coração na tela da atlética é um segundo caminho para RN-86, com o mesmo efeito da troca na Início.

**Hipóteses do Bloco 2 (reversíveis, sem regra no domínio):**
- Leitura dos avisos guardada só no aparelho; o domínio não tem lido/não lido.
- Cada campo do filtro aceita uma opção; filtros valem para todos os dias e não persistem ao reabrir o app.
- O convite de permissão fica só na tela de Notificações; "Agora não" vale até reabrir o app.
- "Minha atlética" nas Notificações = avisos que citam a atlética.

**Decisões de produto em aberto:**
- Onboarding sem opção "seguir sem atlética" (RN-86 permite). Hoje dá para remover depois, na Início.
- **Ranking geral × Torcidômetro** (consulta ao documento-fonte, seções 2, 4.2, 7.16 e 11.3): o Torcidômetro é um ranking próprio — contagem de dispositivos que escolheram cada atlética (RN-88, entidade com posição própria). A "Classificação" é por modalidade (RN-89), com pontuação e desempate não definidos (P-08). O documento **não define** um ranking geral por divisão nem relação com o Torcidômetro; só prevê "campeão geral de cada divisão" registrado pelo organizador (RN-90), sem critério. Mantido: Ranking com pontos fictícios e Torcidômetro apenas como "Torcedores" no perfil. Decidir: existe ranking geral? Qual o critério? O Torcidômetro deve ter tela própria?
- Início mostra só partidas; provas ao vivo/parciais poderiam entrar no carrossel "Ao vivo".
- Filtro de Modalidades por formato (eliminatória/classificatória) ou por "Minha atlética": não está no wireframe; não implementado.
- Rótulo "Em andamento" (cronograma, 07) × "Ao vivo" (Início e detalhe): o protótipo usa "Ao vivo" em tudo.
- Abrir o local da partida no app de mapas (💡 no domínio, citado nas personas): não implementado.
- Torcedor vê a escalação validada (RN-70), mas os wireframes não mostram escalação na partida.

- Divergências 6–9 serão retomadas quando as telas correspondentes entrarem.

## Próximos passos autorizados
- Validação do Bloco 4 pela designer.
- Alta fidelidade e painel web — **não autorizados**.

## Histórico
- 2026-10-17 — Registro inicial das diretrizes do Design Lab. Nenhuma implementação assumida.
- 2026-10-17 — Análise de referências (documento-fonte, personas, 17 telas) e plano aprovado. Target convertido para iOS/iPhone; AccentColor preto. Tela 01 implementada com tokens, componentes base, mocks e estados; compilada e aberta no simulador.
- 2026-10-17 — Tela 01 validada. Bloco 1 (telas 02–06) implementado com abas, rotas, estados completos e cenários por argumento de inicialização; testado no simulador.
- 2026-10-19 — Bloco 1 validado. Bloco 2: Cronograma e Filtros, atlética de coração editável, notificações lidas/não lidas com contador e permissão simulada; testado no simulador.
- 2026-10-19 — Bloco 2 validado. Bloco 3: Ranking por divisão e detalhes da atlética (Jogos, Sobre, Modalidades), com dados fictícios e navegação partida ↔ atlética; testado no simulador.
- 2026-10-19 — Bloco 3 validado. Bloco 4: Modalidades com layouts próprios para eliminatória (jogos, chave, campanha) e classificatória (prova, resultados), provas no Cronograma e ligações partida/atlética ↔ modalidade; testado no simulador.
- 2026-10-19 — Bloco 4 validado. Rodada de refinamento: Cronograma mais enxuto, "Ver mais" e "Ver no cronograma" abrem o Cronograma filtrado, ação textual de atlética de coração no perfil, Modalidades com "Minha atlética | Geral" e agendas completas; testado no simulador.
- 2026-10-19 — Refatoração de Arquitetura em **Atomic Design**: Reorganização completa do `DesignSystem` e de todas as telas em camadas (`Tokens/`, `Atoms/`, `Molecules/`, `Organisms/`, `Features/<Nome>/Tabs|Components`), aplicando o princípio estrito de **1 componente por arquivo** para máxima facilidade de busca no Xcode (`Cmd + Shift + O`), desacoplamento de modelos de domínio em `Mocks/` (`ScheduleItem`, `ContentScope`) e decomposição das views raiz (`HomeView`, `ScheduleView`, `SportsView`, `NotificationsView`, `RankingView`) em views orquestradoras declarativas que delegam cada estado e seção para componentes dedicados. Build 100% verificado com sucesso no iOS Simulator.
- 2026-10-26 — Alta fidelidade, Etapa 1 (fundações): Color Sets com variantes, tokens remapeados, app em Dark fixo; compilado e conferido no iPhone 17 Pro (inclusive com Aumentar contraste).
- 2026-10-26 — Alta fidelidade, Etapa 2 (componentes): tipografia Rounded, cartões sem barras laterais, links Lime, destaque Teal automático da atlética de coração, estados de ao vivo/não lida/atenção; compilado e testado no iPhone 17 Pro e 16e.
- 2026-10-26 — Alta fidelidade, Etapa 3 (navegação global): diagnóstico da navegação nativa, controles das barras monocromáticos com ação principal em Lime, borda forte sob a barra de abas; atlética de coração validada com troca em tempo real; testado no iPhone 17 Pro e 16e.
- 2026-10-26 — Alta fidelidade, Etapa 4 (Início): cabeçalho adaptável ao texto grande, seletor com Teal, indicador de página legível, cartões empilhados em tamanhos de acessibilidade (opção só na Início); testado no iPhone 17 Pro e 16e.
- 2026-10-26 — Alta fidelidade, Etapa 5 (Cronograma e Detalhe da Partida): abas de dias em Lime, trilho discreto, nomes longos empilhados, parciais e lances adaptáveis ao texto grande; fluxos 1–7 testados no iPhone 17 Pro e 16e.
