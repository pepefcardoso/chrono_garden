# Design Document — Chrono Garden

**Objetivo:** Criar um jogo de puzzle determinístico focado na mecânica de manipulação temporal, onde o jogador planta sementes e avança/retrocede no tempo para resolver desafios em um grid.

**Decisões de Design de Core (Core Loop):**
1. **Determinismo Estrito:** O tempo não avança em tempo real. Cada ação (plantar, usar ferramenta) custa 1 "Turno". O crescimento do grid é uma função pura do número do turno e do estado inicial.
2. **Imutabilidade Visual:** A interface é uma casca "burra" que apenas desenha o que o `GameState` atual dita. Nenhuma lógica de jogo deve residir nos componentes de UI.
3. **Restrição de Escopo:** O MVP usará uma visão Top-Down 2D (mais estável para hit-testing no Flutter) em vez de Isométrica 3D, mitigando o risco de complexidade de renderização inicial.

**Riscos Identificados & Mitigações:**
* **Risco:** Vazamento de memória (Memory Leak) ao armazenar milhares de estados em arrays bidimensionais.
* **Mitigação:** Implementar limite rígido de *undo* (ex: máximo de 20 turnos guardados em pilha). Objetos do grid usarão o padrão *Flyweight* (instâncias únicas compartilhadas em memória para entidades estáticas, como "Terra Vazia" ou "Obstáculo").
