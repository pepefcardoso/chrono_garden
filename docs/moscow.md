# MoSCoW Prioritization

### Must Have (Crítico para a fundação)
* Motor determinístico de turnos com geração de novo `GameState` (Matriz 2D).
* Mecânica de *Undo/Redo* em memória limitados a um número fixo de instâncias.
* Interação básica no grid (selecionar célula, plantar semente).
* Condição de vitória (ex: Planta atingiu estágio final na célula-alvo).

### Should Have (Importante para a experiência)
* Sistema de persistência local (Salvar níveis debloqueados).
* Feedback visual de "viagem no tempo" (Shader via `ui.FragmentProgram` com distorção simples).
* Animações de interpolação entre turnos (`ImplicitlyAnimatedWidget`).
* Feedback Haptico (Vibração nativa) nos eventos críticos.

### Could Have (Bom de ter, mas não bloqueia lançamento)
* Visão isométrica (pseudo-3D).
* Inventário complexo com ferramentas secundárias (Água, Adubo, Veneno).
* Sistema de pontuação baseado no menor número de turnos.

### Won't Have (Descartado para V1)
* Multiplayer ou leaderboards online.
* Backend em nuvem para sincronização de save.
* Geração procedural de níveis.
