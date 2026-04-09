# Backlog — Chrono Garden (v1.0 MVP)

> **Formato:** User Story + Tarefas técnicas granulares.
> Cada tarefa deve caber em **1 dia de trabalho de 1 desenvolvedor**.
> **Legenda de status:** ✅ Implementado · ⬜ Pendente · ⚠️ Parcial

---

## Resumo por Sprint (Ativas)

| Sprint                 | Foco Principal                                 | Tarefas       | Esforço | Status     | Critérios de "Pronto" (Done)                                                                                           |
| ---------------------- | ---------------------------------------------- | ------------- | ------- | ---------- | ---------------------------------------------------------------------------------------------------------------------- |
| **Sprint 1 (Sem 1–2)** | Motor de Estado, Grid e Memento (Core Logic)   | T-001 a T-005 | ~4d dev | ⬜ Pendente | Classe `GameState` implementada, Riverpod provendo o grid, mecânica de undo/redo funcional em memória sem UI travada.  |
| **Sprint 2 (Sem 3–4)** | UI/UX Base, Interactions e Time Travel Visuals | T-006 a T-010 | ~5d dev | ⬜ Pendente | Grid renderizado na tela; jogador consegue plantar; slider de tempo retrocede o grid; Fragment Shader ativo no rewind. |
| **Sprint 3 (Sem 5–6)** | Progressão, Menus e Polimento                  | T-011 a T-014 | ~4d dev | ⬜ Pendente | Menu principal funcional; persistência de níveis concluídos com secure storage; haptics e condições de vitória ativas. |

## Épico 0 — Fundação e Arquitetura Base (Sprint 0)

**Como** desenvolvedor líder, **quero** inicializar o repositório, instalar as dependências core e definir a arquitetura de pastas, **para** que o desenvolvimento das lógicas do jogo ocorra de forma padronizada e sem gargalos de infraestrutura.

### US-00 — Inicialização e Dependências (Boilerplate)

| ID        | Tarefa Técnica                                                                                                                                                                                                                                           | Esforço | Sprint | Status |
| --------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------- | ------ | ------ |
| **T-00A** | **Criação do Projeto e Linting:** Rodar `flutter create chrono_garden --platforms=ios,android`. Configurar o arquivo `analysis_options.yaml` com regras restritas (ex: `flutter_lints` atualizado, obrigar tipagem forte e construtores `const`).        | 0.5d    | S0     | ✅      |
| **T-00B** | **Instalação de Dependências Base:** Adicionar ao `pubspec.yaml`: `hooks_riverpod`, `flutter_hooks`, `vibration`, `flutter_shaders`, `flutter_secure_storage`.                                                                                           | 0.5d    | S0     | ✅      |
| **T-00C** | **Instalação do Code Generation:** Adicionar em `dev_dependencies`: `build_runner`, `freezed`, `json_serializable`. Configurar script no `package.json` ou `Makefile` (ex: `make build-runner`) para facilitar a geração de código das models imutáveis. | 0.5d    | S0     | ✅      |

### US-00.1 — Arquitetura de Pastas e Tema Base

| ID        | Tarefa Técnica                                                                                                                                                                                                                                                      | Esforço | Sprint | Status |
| --------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------- | ------ | ------ |
| **T-00D** | **Estrutura Feature-First:** Criar o esqueleto de pastas em `lib/`: `core/` (theme, utils, errors), `features/game/` (models, notifiers, views), `features/menu/`, e `services/` (storage). Garantir que `main.dart` fique limpo.                                   | 0.5d    | S0     | ✅      |
| **T-00E** | **Implementação do Design System:** Criar o arquivo `core/theme/app_theme.dart`. Configurar o `ThemeData` com a paleta do Vendian Chronos (Verde #4CAF50, Marrom #795548, Cyan #00E5FF). Adicionar e linkar as fontes `Manrope` e `Plus Jakarta Sans` no `pubspec`. | 1d      | S0     | ✅      |
| **T-00F** | **Entrypoint e Roteamento:** Configurar o `main.dart` com o `ProviderScope` (para o Riverpod). Implementar roteamento inicial básico usando `GoRouter` ou Navigator 2.0 padrão mapeando as rotas `/splash`, `/menu` e `/game`.                                      | 0.5d    | S0     | ✅      |

## Épico 1 — Core Game State & Board (O Motor)

**Como** sistema do jogo, **preciso** manter um histórico imutável do estado do grid e gerenciar a passagem de turnos, **para** garantir que o jogador possa retroceder no tempo de forma determinística e sem bugs visuais.

### US-01 — Modelagem Imutável e Pilha de Turnos

| ID        | Tarefa Técnica                                                                                                                                                                                            | Esforço | Sprint | Status |
| --------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------- | ------ | ------ |
| **T-001** | Criar as models `@freezed`: `GameState`, `GridData`, `CellData`. Definir enums de entidades (Vazio, Semente, Planta_Fase1, etc). Implementar Flyweight nas entidades estáticas.                           | 0.5d    | S1     | ✅      |
| **T-002** | Criar `TimeMachineNotifier` (Riverpod `StateNotifier`). Implementar lógica base: array circular/pilha `List<GameState>` com tamanho máximo (20). Funções `tick()` (avança e gera novo estado) e `undo()`. | 1d      | S1     | ⬜      |

### US-02 — Lógica Determinística de Crescimento

| ID        | Tarefa Técnica                                                                                                                                                                                        | Esforço | Sprint | Status |
| --------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------- | ------ | ------ |
| **T-003** | Criar motor de regras no `tick()`. Exemplo: Iterar a matriz anterior e aplicar regras (Se célula tem "Semente" e passaram-se 2 turnos, transformar em "Planta_Fase1"). Retornar a matriz nova mutada. | 1d      | S1     | ⬜      |
| **T-004** | Criar os primeiros 3 níveis no formato JSON/Dart Maps (hardcoded) para injetar no `GameState` inicial. Definir layout inicial do grid ($5 \times 5$ e $8 \times 8$).                                  | 0.5d    | S1     | ⬜      |

---

## Épico 2 — Time Travel Mechanics & Interfaces (O Visual)

**Como** jogador, **quero** interagir visualmente com o grid, ver as plantas crescerem dinamicamente e receber feedback visual agressivo quando eu manipular o tempo.

### US-03 — Renderização do Grid e HUD

| ID        | Tarefa Técnica                                                                                                                                                                                     | Esforço | Sprint | Status |
| --------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------- | ------ | ------ |
| **T-005** | Desenvolver componente `GameBoard` que escuta o `TimeMachineNotifier`. Renderizar matriz 2D top-down (GridView / CustomPaint). Aplicar paleta Secundária (`#795548`) na terra.                     | 1d      | S2     | ⬜      |
| **T-006** | Implementar HUD Superior (Contador Manrope) e HUD Inferior (Controles de Mídia/Slider de tempo). Slider deve refletir e ditar o `currentStateIndex` da pilha. Cor Terciária (`#00E5FF`) no Slider. | 1d      | S2     | ⬜      |

### US-04 — Feedback Sensorial (Shaders & Haptics)

| ID        | Tarefa Técnica                                                                                                                                                 | Esforço | Sprint | Status |
| --------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------- | ------ | ------ |
| **T-007** | Escrever shader GLSL (`ui.FragmentProgram`) de ruído/sépia para efeito de VHS temporal. Compilar via `flutter_shaders`.                                        | 1d      | S2     | ⬜      |
| **T-008** | Integrar Shader no widget root da tela de jogo. Acionar a animação (duração: 300ms) sempre que a ação de `undo()` for chamada.                                 | 0.5d    | S2     | ⬜      |
| **T-009** | Adicionar dependência `vibration`. Mapear pulso leve (`tick`) e pulso duplo/pesado para quando limite de viagem no tempo for atingido ou ao usar botão rewind. | 0.5d    | S2     | ⬜      |

---

## Épico 3 — Sistema de Progressão e Telas de Apoio

**Como** jogador, **quero** navegar por um menu principal limpo, selecionar as fases que já desbloqueei e ter meu progresso salvo caso eu feche o aplicativo.

### US-05 — Navegação e Persistência de Save

| ID        | Tarefa Técnica                                                                                                                                                                       | Esforço | Sprint | Status |
| --------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ------- | ------ | ------ |
| **T-010** | Telas de apoio estruturadas com componentes do Design System: Splash Screen com pre-cacheamento de assets, Main Menu e Modal de Vitória. Fontes Manrope e Plus Jakarta Sans.         | 1d      | S3     | ⬜      |
| **T-011** | Tela de Seleção de Níveis (1 a 15). Layout em grid. Implementar cadeados visuais em níveis não desbloqueados.                                                                        | 1d      | S3     | ⬜      |
| **T-012** | Implementar persistência local (Save System) com `flutter_secure_storage`. Salvar e ler payload JSON encriptado: `{"maxUnlockedLevel": 3, "scores": {...}}` na inicialização do app. | 1d      | S3     | ⬜      |

---

## Plano de Execução Recomendado (Ordem Lógica)

> A ordem de execução foca em mitigar os maiores riscos arquiteturais primeiro (Motor de Regras Imutáveis), deixando a camada visual (Shaders e Telas acessórias) para o final.

### Sprint 1 (Motor e Fundações — Bloqueadores)

1. `T-002` — Criação do Notifier de Time Travel — **A espinha dorsal da mecânica principal.**
2. `T-003` — Motor Determinístico no `tick()` — **Onde a lógica real de jogo vive.**
3. `T-004` — Criação dos níveis (Hardcoded JSON) — **Necessário para alimentar a UI no Sprint 2.**

### Sprint 2 (Core Gameplay Visual)

1. `T-005` — Board Render (Grid Visual) — **Primeiro teste real se a modelagem não pesou na performance.**
2. `T-006` — HUD e Controles de Tempo (Slider) — **Permite testar o núcleo construído no Sprint 1 de forma humana.**
3. `T-007` & `T-008` — Integração de Shader de distorção — **Polimento crítico da mecânica de tempo.**
4. `T-009` — Haptics — **Feedback tátil melhora drasticamente o feel do puzzle.**

### Sprint 3 (Envelopamento e Lançamento)

1. `T-012` — Persistência de Save (Secure Storage) — **Bloqueador para a tela de níveis funcionar corretamente.**
2. `T-011` — Tela de Seleção de Níveis — **Fluxo macro do produto.**
3. `T-010` — Menus e Telas de Apoio — **Amarra a experiência inicial e final (Splash/Victory).**
