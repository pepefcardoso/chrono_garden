# Architecture (Skills)

**Recomendação Arquitetural:** Padrão Memento com Fluxo Unidirecional de Dados (via Riverpod).

**Stack:** Flutter, Riverpod (State Management), Freezed (Imutabilidade), flutter_hooks (gerenciamento do ciclo de vida de shaders e animações).

**Estrutura de Estado (Core):**
```dart
@freezed
class GameState with _$GameState {
  const factory GameState({
    required int currentTurn,
    required GridData grid,
    required Inventory inventory,
  }) = _GameState;
}
```

**Gerenciador de Tempo (TimeMachineNotifier):**
Uma classe de controle que gerencia uma `List<GameState>` (pilha). 
* `undo()`: decrementa o ponteiro da lista. Não destrói o estado futuro imediatamente (permite `redo`), a menos que uma *nova* ação divirja a linha do tempo.
* `tick()`: Computa a matriz do grid baseada nas regras de evolução das plantas, gera um novo `GameState`, descarta os estados futuros (se houver divergência) e faz o push na pilha. Se a pilha exceder 20, remove o índice 0.

**Tradeoffs:**
* **Favor:** Facilidade extrema de debugar. Bugs podem ser reproduzidos apenas despejando o JSON do `GameState` e do array de ações.
* **Contra:** Custo de CPU em grids muito grandes ($> 20 \times 20$) a cada turno devido à cópia imutável. Para o escopo de $8 \times 8$, o impacto é insignificante ($O(N)$ onde $N = 64$).
