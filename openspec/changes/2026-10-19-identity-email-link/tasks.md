# Tarefas propostas: Cadastro local, verificação e admissão

Convenção: `[ ]` significa **não executado**. A confirmação das políticas de produto locais em 02/11/2026 e a validação OpenSpec não aprovam o design técnico nem autorizam implementação. Nenhuma tarefa de código foi executada. Implementação permanece condicionada à revisão/aprovação humana e autorização explícita.

## 1. Revisão e preparação

- [x] 1.1 Confirmar políticas locais PROD-07 e registrá-las em `docs/requirements/decisoes-pendentes.md`; verificação: confirmação explícita do solicitante em 02/11/2026 e conferência documental. Isso não equivale à aprovação de implementação.
- [x] 1.2 Revisar `proposal.md`, `design.md` e `specs/identity-email-link/spec.md` contra requisito v3.4 e decisões PROD-07/08; solicitante registrou aprovação humana em 02/11/2026 para a primeira fatia de cadastro/confirmação local. A validação OpenSpec é somente estrutural.
- [x] 1.3 Aprovar desenho técnico mínimo da primeira fatia: persistência/transições/migração; geração, proteção, expiração, consumo único e tentativas do código; envio de confirmação; limites contra abuso e respostas externas; autorização dos endpoints não autenticados incluídos. Sessão, CSRF e política de senha ficam fora desta fatia. Aprovação e autorização explícita registradas em 02/11/2026; nenhuma implementação iniciada.

## 2. Primeira fatia: cadastro e confirmação local

- [ ] 2.1 Após concluir 1.2–1.3 e registrar autorização explícita de implementação, modelar solicitação e verificação em PostgreSQL sem inferir exclusão em cascata (PROD-07, OPS-01). Esta tarefa inclui migração/modelagem como parte da implementação autorizada; verificar migrações aprovadas e invariantes de unicidade/concorrência conforme desenho aprovado.
- [ ] 2.2 Implementar endpoints não autenticados de solicitação, emissão/reenvio e confirmação de e-mail conforme a política aprovada de uso único, 10 minutos, três tentativas por verificação e reenvio sem reset (PROD-07). Verificação: testes de domínio/API para sucesso, código inválido/expirado/reutilizado, limite e reenvio; provar vínculo à solicitação, limites/respostas externas aprovados e ausência de código/segredo em logs.
- [ ] 2.3 Implementar autenticação local e acesso da conta verificada ainda pendente restrito ao próprio estado e correção do nome (PROD-07), como fatia posterior. Antes dela, aprovar separadamente ciclo de sessão, CSRF, revogação e política de senha. Verificação: testes de API negam palpites, ranking, dados de terceiros e funções administrativas.

## 3. Admissão e alteração de e-mail

- [ ] 3.1 Implementar aprovação/rejeição apenas por administrador autorizado, com transição auditada (ator, instante, ação, estado anterior/novo); preservar conta/histórico em rejeição e não reverter aprovação por falha de e-mail (PROD-07/08). Verificação: testes de domínio/API para autorização negativa, transições e auditoria; teste de concorrência contra PostgreSQL conforme desenho aprovado.
- [ ] 3.2 Implementar alteração de e-mail local mantendo o endereço antigo vigente até verificar o novo, sem fusão de contas (PROD-07; HU-22 aplicável à verificação). Verificação: testar conflito e reivindicações concorrentes conforme política aprovada de comparação/reserva de e-mail; validade e reenvio só após decisão específica, sem presumir 10 minutos.
- [ ] 3.3 Implementar o envio de notificação de liberação e sua nova tentativa conforme a operação de e-mail aprovada (OPS-03). Verificação: testes com adaptador controlado demonstram que falha do envio não reverte aprovação, é registrada e pode ser repetida sem duplicar a transição administrativa.

## 4. Interface e validação

- [ ] 4.1 Implementar interfaces de cadastro, confirmação, login, estado próprio e fila administrativa após aprovação do contrato. Verificação: testes de interface/E2E dos fluxos e estados cobertos acima, usando setup existente/autorizado; não instalar dependências sem autorização.
- [ ] 4.2 Executar validação integrada e registrar resultados reais: testes de backend e frontend disponíveis, `openspec validate 2026-10-19-identity-email-link --strict` e `git diff --check`. Não declarar execução antes de rodar os comandos.

## Rastreabilidade resumida

| Origem / versão | Cenário da spec | Tarefa | Evidência planejada |
|---|---|---|---|
| PROD-07, requisito v3.4 — cadastro local | Solicitação de cadastro; e-mail ainda não confirmado | 2.1–2.2 | Testes de domínio/API para criação pendente e bloqueio de autenticação até confirmação |
| PROD-07, política confirmada em 02/11/2026 — código cadastral | Código de confirmação; confirmação do endereço; mecanismo inválido/expirado | 2.2 | Testes para uso único, vínculo à solicitação, 10 minutos, três tentativas, reenvio sem reset e não exposição do código |
| PROD-07, decisão confirmada em 02/11/2026 — acesso pendente | Conta confirmada aguardando aprovação | 2.3 (fatia posterior) | Testes negativos backend para palpites, ranking, terceiros e administração |
| PROD-07, decisão confirmada em 02/11/2026 — admissão | Aprovação/rejeição, ação não autorizada, alterações concorrentes, falha de e-mail | 3.1–3.3 (fatia posterior) | Testes de autorização, transição/auditoria e concorrência PostgreSQL; falha/reenvio via adaptador aprovado |
| PROD-07 e HU-22, requisito v3.4 — alteração local do e-mail | Endereço antigo, ativação, conflito, reivindicações concorrentes | 3.2 (fatia posterior) | Testes de fluxo e unicidade concorrente; validade/reenvio dependem de decisão própria |
| PROD-08, requisito v3.4 — conta administrativa local | Login development e rejeição fora de development | Requisito 89; comportamento preexistente preservado, não alterado por esta change | Testes existentes são referência; não constituem validação desta change |
| HU-21 e integração/vínculo Google HU-22/23 | Explicitamente fora desta entrega | Fora do escopo | Não implementar nem considerar critério de aceite desta change |
