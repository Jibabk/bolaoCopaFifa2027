# Design

## Context

Ver `proposal.md` para objetivo e escopo, e `specs/identity-email-link/spec.md` para comportamentos. ADR-001 estabelece monólito modular, persistência síncrona inicial com PostgreSQL/SQLAlchemy e sessão opaca revogável mantida no servidor. Driver, esquema, ciclo de sessão e detalhes de segurança ainda não foram aprovados. O backend já contém autenticação administrativa local exclusivamente para `ENVIRONMENT=development`; esta change amplia a capacidade de identidade, não substitui essa implementação.

## Goals / Non-Goals

**Goals:**
- Implementar cadastro local, confirmação, autenticação restrita por estado, admissão administrativa e alteração verificada do e-mail local.
- Manter regras e autorização no backend, com transições e unicidade consistentes na persistência.
- Preservar a distinção entre código cadastral, verificação HU-22 relacionada à alteração de e-mail/vínculo e recuperação HU-21.

**Non-Goals:**
- Google/primeiro vínculo, recuperação HU-21, provisionamento administrativo fora de development, política de retenção/exclusão (OPS-01) e seleção/operação de provedor (OPS-03).
- Fixar neste artefato driver, schema/DDL, mecanismo de lock, valores de sessão/rate limit ou fornecedor de e-mail.

## Decisions

1. **Fronteira e autorização.** A capacidade `identity` no backend é responsável pelos estados de confirmação/admissão e pelas regras de autorização. FastAPI adapta contratos HTTP a casos de uso; a interface Next.js apresenta os estados, mas não decide permissões. Isso segue ADR-001 e evita duplicar regras no frontend.
2. **Persistência e concorrência.** PostgreSQL é a autoridade dos estados. Cada operação que confirma endereço ou altera admissão deve preservar atomicamente as invariantes observáveis, incluindo endereço único segundo a política de comparação aprovada e transição válida a partir do estado vigente. A validação de disponibilidade na API não substitui garantia concorrente no banco. A técnica concreta fica para design técnico aprovado; validar concorrência usando PostgreSQL real, não presumir que SQLite a representa.
3. **Sessão.** Usar a direção aprovada de sessão opaca revogável no servidor. A API deve verificar autorização com estado atual da conta. Cookie, CSRF, expiração, rotação e eventos de revogação são controles obrigatórios a detalhar e aprovar antes do fluxo autenticado; JWT/refresh da minuta TEC-01 não é adotado.
4. **Credenciais e código.** Nunca armazenar senha em claro; selecionar e calibrar um KDF apropriado para senhas, com Argon2id como recomendação técnica para revisão. Gerar códigos com fonte criptograficamente segura, associá-los a finalidade/solicitação e garantir expiração, limite de tentativas e consumo único no servidor. Código cadastral não pode ser armazenado em claro nem aparecer em logs; recomenda-se avaliar verificador com chave protegida em vez de hash simples do espaço numérico. Algoritmo, parâmetros e gestão de chave são propostas para revisão, não decisões já aprovadas. A política cadastral aprovada (10 minutos, até três tentativas e reenvio sem reiniciar) não define a validade/reenvio da mudança de e-mail HU-22.
5. **E-mail e admissão.** Persistir a decisão administrativa e sua auditoria sem depender da entrega do e-mail; disparar a notificação sem manter transação de banco aberta. Falha deve ser registrada e permitir nova tentativa sem reverter aprovação. O mecanismo de despacho, retries, idempotência e fornecedor depende de OPS-03; não introduzir fila/outbox ou prometer entrega exatamente uma vez sem decisão específica.
6. **Auditoria.** Aprovação e rejeição registram ator, instante, ação e estado anterior/novo. A decisão e o registro de auditoria devem permanecer consistentes. Logs operacionais não devem conter senha, código, sessão/cookie, token ou conteúdo sensível de e-mail. Retenção e exclusão seguem pendentes em OPS-01; não inferir cascata nem retenção ilimitada.

## Risks / Trade-offs

- [Concorrência entre confirmação de e-mail ou ações administrativas] → definir invariantes no banco e validar com testes PostgreSQL concorrentes antes de concluir implementação.
- [Abuso de envio/tentativas ou enumeração] → definir limites de solicitação e respostas externas antes de expor os fluxos; não aplicar bloqueio permanente nem importar automaticamente a política de anti-enumeração da HU-21.
- [Sessões persistentes após mudança de credencial/estado] → decidir eventos de revogação e ciclo de vida no desenho de sessão antes de liberar autenticação.
- [Falha ou resposta incerta do provedor] → separar envio da transição de admissão, registrar falha de forma segura e definir nova tentativa dentro de OPS-03.
- [Endereço equivalente ou já reservado] → aprovar política de comparação/reserva antes de impor unicidade; não assumir normalização universal de e-mail.

## Preparação da primeira fatia

A primeira fatia de código pode ser limitada a cadastro e confirmação de e-mail local; não inclui login autenticado, admissão administrativa, alteração de e-mail, Google ou recuperação de senha. Antes de iniciar essa fatia, registrar e aprovar um desenho técnico mínimo para persistência/transições e migração; geração, armazenamento protegido, expiração, consumo único e tentativas do código cadastral; envio do código; respostas e limites contra abuso; e autorização/sessão dos endpoints que forem expostos. Não escolher mecanismos ou valores ainda pendentes por inferência. A aprovação humana desse recorte/design e a autorização explícita de implementação são gates separados.

A implementação das fatias posteriores exige fechar apenas as decisões que afetam cada fluxo: validade/reenvio HU-22 e comparação/reserva de e-mail para alteração de endereço; sessão/cookie/CSRF/revogação e política de senha antes de endpoints autenticados; estados/permissões após rejeição, saída e reativação; e operação de falha/retry do e-mail de liberação (OPS-03). Retenção/exclusão segue OPS-01 e permanece fora desta change. Esses pontos posteriores não bloqueiam a primeira fatia se ela não os expuser.
