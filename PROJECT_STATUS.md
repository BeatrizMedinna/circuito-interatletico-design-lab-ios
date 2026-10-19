# Circuito Inter-Atlético — Status do Design Lab

## Etapa atual
- Plataforma: iOS / iPhone — SwiftUI (target convertido de macOS para iOS em 17/10/2026; iOS 26.1, só iPhone, retrato).
- Fidelidade: média.
- Paleta: branco, preto e tons neutros de cinza; **somente modo claro**.
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
| 02 | Início (abas Atlética/Geral, ao vivo, próximos e últimos jogos) | **Bloco 1 — em validação** |
| 03 / 04 / 05 | Jogo ao vivo / encerrado / a iniciar | **Bloco 1 — em validação** |
| 06 | Notificações (Minha Atlética / Geral) | **Bloco 1 — em validação** |
| 07 / 08 | Cronograma / filtros | — |
| 09 | Ranking por divisão (pódio + lista) | — |
| 10 / 11 / 12 | Atlética: info / cronograma / ranking | — |
| 13 | Modalidades (busca + filtro) | — |
| 14 / 15 / 16 | Modalidade: cronograma / chaveamento / ranking | — |
| 17 | Filtros de modalidades | — |

## Fluxos identificados
- Primeiro acesso → 01 Escolha da atlética → app com 4 tabs (Início, Cronograma, Ranking, Modalidades).
- Início → Jogo (03/04/05 conforme status) · sino → Notificações.
- Cronograma → Jogo · filtros em sheet (08).
- Ranking → Atlética (10–12) → Modalidade / Jogo.
- Modalidades → Modalidade (14–16) → Atlética / Jogo · filtros em sheet (17).
- Cada tab terá seu próprio `NavigationStack`; tab bar sempre visível nos pushes.

## Componentes compartilhados
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
- `-labScenario empty|loading|error|unavailable` muda os dados de Início e Notificações.

### 01 — Escolha sua Atlética (`Features/Onboarding/OnboardingView.swift`) — validada
- Busca por nome ou sigla, sem diferenciar maiúsculas e acentos.
- Seleção única; "Entrar" fica desabilitado até escolher uma atlética.
- Estados: carregando (1 s simulado), lista, busca sem resultado, erro com "Tentar novamente", edição indisponível.
- Previews: Sem seleção, Com seleção, Busca sem resultado, Carregando, Erro, Edição indisponível, Dynamic Type grande; e "Fluxo completo" no `App/`.
- Ajustes de UX em relação ao Figma: círculo vazio nas linhas não selecionadas (deixa clara a escolha única); selecionada = fundo mais escuro + borda de 2 pt + ✓ preenchido; nome da divisão real no lugar de "1º divisão"; lista em ordem alfabética; título da seção e busca fixos enquanto a lista rola; leve vibração (haptic) ao selecionar.
- Depois de "Entrar": abre o app com abas (Bloco 1).

## Telas validadas
- 01 — Escolha sua Atlética (17/10/2026, no simulador).

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
**Decisões de produto do Bloco 1:**
- Notificações lidas/não lidas: o wireframe 06 tem uma barra cinza à esquerda dos avisos, que pode indicar "não lido". O domínio não tem esse estado. Sem decisão, não implementei nem a barra nem um contador no sino.
- Trocar a atlética de coração (RN-86) depois do onboarding: não há tela para isso. Hoje o protótipo sempre abre no onboarding.
- Permissão de notificações (RN-87): onde e quando pedir.
- Destino do "Ver mais": abre uma lista própria dentro da Início. Quando o Cronograma (07) existir, avaliar se deve levar para lá com filtro.
- Rótulo "Em andamento" (cronograma, 07) × "Ao vivo" (Início e detalhe): o protótipo usa "Ao vivo" em tudo.
- Abrir o local da partida no app de mapas (💡 no domínio, citado nas personas): não implementado.
- Torcedor vê a escalação validada (RN-70), mas os wireframes não mostram escalação na partida.

- **Modalidades (etapa 13–17):** analisar as diferenças entre eliminatórias e classificatórias — ranking em "pts" não existe no mata-mata; classificatórias usam marca (tempo/distância) e situação; não há wireframe de resultados de prova; a aba Chaveamento não se aplica a elas. Nenhuma tela nova antecipada.
- Onboarding: opção "seguir sem atlética" (RN-86) e pedido de permissão de notificações (RN-87) — aguardam decisão.
- Divergências 6–9 serão retomadas quando as telas correspondentes entrarem.

## Próximos passos autorizados
- Validação do Bloco 1 pela designer.
- Próximo bloco — **ainda não autorizado**.

## Histórico
- 2026-10-17 — Registro inicial das diretrizes do Design Lab. Nenhuma implementação assumida.
- 2026-10-17 — Análise de referências (documento-fonte, personas, 17 telas) e plano aprovado. Target convertido para iOS/iPhone; AccentColor preto. Tela 01 implementada com tokens, componentes base, mocks e estados; compilada e aberta no simulador.
- 2026-10-17 — Tela 01 validada. Bloco 1 (telas 02–06) implementado com abas, rotas, estados completos e cenários por argumento de inicialização; testado no simulador.
