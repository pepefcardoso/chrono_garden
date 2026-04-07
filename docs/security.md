# Security (Skills)

Embora seja um jogo majoritariamente *client-side*, devemos aplicar princípios básicos de proteção de estado para evitar adulteração simples de *save games*, caso haja intenção futura de leaderboards.

**Recomendações:**
1.  **Proteção de Save (State Tampering):** O progresso de níveis concluídos e o inventário devem ser armazenados usando `flutter_secure_storage` (AES no Android, Keychain no iOS).
2.  **Validação de Integridade (Checksum):** Adicionar um hash simples (ex: SHA-256 do payload do save + um *salt* local gerado na instalação) ao arquivo de save. Se o usuário editar o JSON em aparelhos com *root*, o save é invalidado, evitando desbloqueio de fases artificial.
3.  **Memória:** Nenhuma credencial de rede trafega neste MVP. O foco de segurança é puramente na integridade dos dados locais para não quebrar a experiência de progressão.
