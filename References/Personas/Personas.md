# Personas do Projeto — Sistema de Gestão do Circuito Inter-Atlético (MVP)

## 1. Carlos — 32 anos
**Papel no Sistema:** Produtor de Eventos Universitários (`ADMIN_SUPREMO`)

* **SOBRE:** É o organizador geral responsável pela governança completa do evento e de suas edições anuais itinerantes. Comanda a logística esportiva, a configuração das divisões e modalidades, a homologação das atléticas participantes e a coordenação da equipe de arbitragem, tendo a responsabilidade final de fazer o torneio operar sem paralisações ou conflitos de quadra.
* **ESTILO DE VIDA:** Possui uma rotina executiva intensa, dividindo seu tempo entre o planejamento estrutural da edição, o alinhamento com as faculdades e o gerenciamento operacional da competição. Nos dias de jogos, sua rotina vira uma gestão de crise em tempo real contra atrasos e imprevistos climáticos.
* **OBJETIVOS:**
  * Ter controle macro e centralizado sobre toda a operação esportiva e logística do campeonato.
  * Encerrar a edição com o histórico de campeões (gerais por divisão e por modalidade) consolidado e métricas reais de engajamento das torcidas (*Torcidômetro*) para comprovar o alcance do evento e planejar o crescimento do ano seguinte.
* **FRUSTRAÇÕES:**
  * O retrabalho exaustivo de montar chaveamentos e cronogramas manualmente, precisando redefinir locais e horários a cada imprevisto logístico sem sobrepor ginásios.
  * A descentralização de dados operacionais espalhados entre planilhas, grupos de WhatsApp e súmulas de papel, que atrasam a divulgação oficial dos resultados.
* **NECESSIDADES:**
  * Centralizar a configuração da edição (identidade visual *white-label*, divisões, modalidades eliminatórias/classificatórias e locais) e a geração automática de chaves (com resolução de *byes*) e cronogramas em um único painel web.
  * Trabalhar com versões de rascunho do cronograma (`EM_EDICAO`) antes de publicar a versão oficial (`SALVA`), disparando notificações *push* automáticas aos torcedores a cada mudança.
* **COMPORTAMENTOS:**
  * É o tomador de decisão final: cria as contas da equipe, escala os mesários concedendo acessos temporários e é o único autorizado a reabrir súmulas ou provas encerradas em caso de erro.
  * Atua de forma analítica, monitorando indicadores operacionais no painel web enquanto delega a coleta de dados em quadra para o staff técnico.

---

## 2. Lucas — 22 anos
**Papel no Sistema:** Estudante de Educação Física / Staff Técnico (`MESARIO`)

* **SOBRE:** É o responsável posicionado na mesa técnica ou na pista para validar os atletas antes do início, controlar ocorrências e computar placares ou marcas oficiais. Atua como o elo oficial entre a arbitragem de campo e a direção do torneio, precisando ser ágil e imparcial sob a pressão direta de treinadores e torcidas organizadas.
* **ESTILO DE VIDA:** Universitário que equilibra a faculdade com atuações em eventos esportivos para ganhar experiência prática e renda extra. Passa os dias de campeonato focado nas quadras e ginásios, lidando com barulho, cobrança por resultados imediatos e conexões de internet instáveis.
* **OBJETIVOS:**
  * Validar rapidamente os atletas presentes (registrando o número da camisa na partida) e lançar os eventos do jogo (pontos, faltas, cartões) em tempo real, ou registrar as marcas finais das provas classificatórias (tempo, distância, pontos), encerrando a disputa com precisão.
* **FRUSTRAÇÕES:**
  * O uso de súmulas e listas de presença em papel, que amassam, molham ou se perdem no ginásio e atrasam a consolidação dos rankings e da artilharia.
  * O medo de perder todos os lançamentos registrados durante uma partida acirrada quando o Wi-Fi do ginásio cai.
* **NECESSIDADES:**
  * Um módulo de súmula digital simples, rápido e com acesso temporário restrito exatamente às partidas ou provas para as quais foi escalado pelo Admin Supremo.
  * Uma ferramenta tolerante a falhas de conexão (que guarde os lançamentos pendentes e evite duplicação ao reconectar) e que permita aplicar W.O. manualmente, a seu critério, caso uma equipe não compareça ou não tenha atletas suficientes.
* **COMPORTAMENTOS:**
  * Trabalha sob forte pressão na beira da quadra e precisa de uma interface adaptada ao molde de cada esporte (com contadores e campos específicos já configurados).
  * Confere os dados e encerra oficialmente a súmula ou prova ao apito final, ciente de que o registro será bloqueado imediatamente e qualquer correção posterior exigirá solicitar a reabertura ao Admin Supremo.

---

## 3. Marina — 21 anos
**Papel no Sistema:** Estudante Universitária e Representante de Atlética (`ADMIN_ATLETICA`)

* **SOBRE:** É a liderança estudantil eleita para representar sua faculdade perante a comissão organizadora do torneio. Coordena a participação esportiva das equipes da sua instituição na edição, sendo responsável pelo levantamento de documentos, cadastro do elenco de alunos e inscrição correta dos jogadores em cada modalidade.
* **ESTILO DE VIDA:** Vive equilibrando a carga de estudos com a gestão esportiva da sua delegação. É sociável, engajada na cultura do campus e está sempre conectada. Nos dias que antecedem e durante os jogos, atua como ponto focal para orientar seus atletas sobre horários, locais de competição e desempenho da faculdade.
* **OBJETIVOS:**
  * Garantir que todos os atletas da sua atlética estejam devidamente cadastrados na edição e inscritos nas modalidades certas dentro dos limites regulamentares, evitando impedimentos na mesa de arbitragem ou derrotas por W.O..
  * Mobilizar sua comunidade acadêmica para escolher a atlética no aplicativo e liderar o ranking do *Torcidômetro* e as classificações da sua divisão.
* **FRUSTRAÇÕES:**
  * A falta de autonomia quando depende da organização central para corrigir fichas de inscrição em papel ou planilhas compartilhadas.
  * O risco de ter inscrições invalidadas por erros manuais na conferência de limites mínimo/máximo de atletas por modalidade ou incompatibilidade de gênero (masculino, feminino ou mista).
  * O desencontro de informações quando o cronograma sofre alterações de última hora e a delegação descobre em cima da hora.
* **NECESSIDADES:**
  * Um painel web com escopo isolado e seguro (RBAC *multi-tenant*), onde ela acesse e gerencie exclusivamente os atletas da sua própria atlética homologada.
  * Validação imediata pelo sistema no momento da inscrição (alertando se o elenco está abaixo do mínimo, bloqueando se atingir o máximo ou se o gênero do atleta for incompatível com a modalidade) e um painel consolidado para acompanhar próximos jogos, estatísticas e posição no *Torcidômetro*.
* **COMPORTAMENTOS:**
  * É uma líder multitarefa que atua como ponte entre a diretoria do campeonato e os estudantes da sua faculdade.
  * Acessa o painel web para manter a documentação (CPF ou matrícula) do elenco em dia a cada edição e monitora de perto o engajamento da sua torcida e o avanço das equipes nas chaves.

---

## 4. Thiago — 20 anos
**Papel no Sistema:** Estudante Universitário, Atleta Participante e Torcedor (`Torcedor` / `Dispositivo` e `Atleta` cadastrado)

* **SOBRE:** É o universitário que vive intensamente os dias de jogos acadêmicos. Alterna entre o papel de torcedor fanático na arquibancada e o de atleta amador em quadra pela sua faculdade (cadastrado previamente pela representante da sua atlética), priorizando o senso de pertencimento, a rivalidade saudável e a visibilidade das conquistas.
* **ESTILO DE VIDA:** Muito sociável, conectado e focado em aproveitar a experiência universitária sem burocracia. Em um momento está competindo em quadra pela sua atlética e, logo depois, está na arquibancada acompanhando outras modalidades pelo celular e compartilhando resultados nas redes sociais.
* **OBJETIVOS:**
  * Acompanhar em tempo real os placares ao vivo, o chaveamento, o cronograma atualizado e a posição da sua faculdade nos rankings e no *Torcidômetro* sem precisar enfrentar telas de cadastro ou senhas.
  * Ter seu desempenho em quadra reconhecido oficialmente nas estatísticas públicas do aplicativo (pontos, faltas, artilharia) e compartilhar as vitórias com facilidade.
* **FRUSTRAÇÕES:**
  * Aplicativos que exigem criação de conta e formulários longos apenas para consultar o horário ou o local de um jogo.
  * A cobertura incompleta do campeonato em canais fragmentados (Stories e grupos de WhatsApp), obrigando-o a caçar resultados, chaves de mata-mata ou endereços de ginásios desconhecidos.
* **NECESSIDADES:**
  * Acesso instantâneo e sem login ao aplicativo iOS do evento (identificado automaticamente pelo dispositivo), permitindo escolher sua "atlética de coração" com um toque e receber notificações *push* caso o horário ou local de uma partida mude.
  * Redirecionamento direto para o aplicativo de mapas ao tocar no local do jogo, consulta pública às suas estatísticas individuais como atleta e geração sob demanda de *cards* visuais de resultado (estilo Strava) com a identidade visual da edição para postar nas redes sociais.
* **COMPORTAMENTOS:**
  * Usuário extremamente dinâmico que realiza micro-sessões no celular: abre o app na arquibancada para checar o placar ao vivo, filtrar os jogos do dia da sua atlética ou ver o histórico de campeões de edições passadas.
  * Quando atua como atleta, não utiliza login próprio nem crachá digital no aplicativo: ele se apresenta ao mesário antes do jogo para ter sua participação e número de camisa validados na súmula e, após a partida, consulta seu próprio nome no ranking de artilharia e estatísticas públicas do app.
