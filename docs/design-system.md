# UI/UX Design System (Vendian Chronos)

**Análise baseada no System anexado:** O design comunica uma interface limpa, orientada à utilidade, com forte apelo visual natural (tons terrosos e verdes) contrastado com elementos digitais/temporais (cyan).

**Paleta de Cores & Uso Funcional:**
* **Primary (`#4CAF50` - Verde Natural):** Usado para ações positivas no grid (Botão "Plantar", feedback de crescimento, "Play/Next Turn"). Representa a natureza.
* **Secondary (`#795548` - Marrom Terroso):** Cor de fundação. Usada para o grid de fundo, células vazias (Terra), e tipografia de suporte em fundos claros.
* **Tertiary (`#00E5FF` - Cyan Digital/Temporal):** Cor de contraste temático. Usada exclusivamente para mecânicas de manipulação temporal: barra do Slider de tempo, botões de *Rewind* e o efeito de borda quando uma distorção temporal ocorre.
* **Neutral (`#F1F8E9` - Off-White Esverdeado):** Background principal (Splash, Menus, Fundo do Tabuleiro). Reduz o cansaço visual em comparação com o branco puro.

**Tipografia:**
* **Headlines (`Manrope`):** Usado para contadores numéricos (HUD de Turnos), Títulos de Nível ("Nível 4") e modais de Vitória. Aporta um peso geométrico moderno.
* **Body & Labels (`Plus Jakarta Sans`):** Usado para inventário, menus de configuração e tooltips. Excelente legibilidade em tamanhos pequenos.

**Componentes Base:**
* **Botões:** Formato *Pill* (bordas totalmente arredondadas). Botões de ação do tempo devem adotar as variantes `Primary` ou `Inverted` da spec.
* **Cards:** Elementos de HUD flutuantes e o tabuleiro devem ter bordas levemente arredondadas (estimado em `16px` pelo mockup), com sombras suaves (elevação branda) para separar o *Game Board* do *Background*.
