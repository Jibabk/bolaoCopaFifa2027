# Proposta: Cadastro local, verificação de e-mail e admissão

## Por quê

A primeira entrega funcional prioriza o cadastro local, a confirmação do endereço de e-mail e o login por usuário e senha. A participação no bolão continua condicionada à aprovação administrativa (PROD-07). A integração Google fica opcional e fora desta primeira entrega; HU-22/23 e as decisões de vínculo permanecem como escopo futuro independente.

## O que muda

- Especificar solicitação de cadastro local com nome, e-mail e credencial local, confirmação do e-mail, autenticação por usuário/senha após a confirmação e alteração de e-mail local com ativação apenas após verificar o endereço novo.
- Reutilizar no desenvolvimento local a exceção administrativa já decidida em PROD-08 (`admin`, senha configurada em variável local não versionada, sem validação de e-mail, exclusivamente em `ENVIRONMENT=development`). Provisionamento e recuperação de acesso administrativo fora do ambiente local permanecem fora/pendentes; esta change não define uma credencial ou setup de produção.
- Especificar a aprovação/rejeição administrativa da participação, com autorização e auditoria, mantendo usuários não aprovados impedidos de participar.
- Manter recuperação de senha HU-21 fora desta entrega e a autenticação Google como opcional/futura, sem misturar seus fluxos com confirmação de e-mail local.

## Capacidades afetadas

`identity` no backend, `features/auth` no frontend, contratos de API, envio de e-mail (OPS-03) e autorização administrativa (PROD-07/08). Fontes: requisito v3.4 e decisões PROD-07/08 → cenários em `specs/identity-email-link/spec.md` → tarefas em `tasks.md` → testes propostos. Nenhuma validação de runtime foi executada.

## Fora de escopo

Vínculo/autenticação Google (HU-22/23 e change dedicada futura), recuperação de senha HU-21, seleção de fornecedor de e-mail, implementação, edição da change de scaffold `2026-10-18-technical-foundation`, Docker e implantação em nuvem. Políticas técnicas ainda abertas não são fixadas por esta proposta.

## Governança

**Status: change documental atualizada com as decisões locais confirmadas pelo solicitante em 02/11/2026; NÃO aprovada para implementação.** O escopo da primeira entrega permanece cadastro/admissão e alteração de e-mail local; Google e HU-21 ficam fora. A confirmação das políticas de produto não constitui aprovação de desenho técnico nem autorização para executar tarefas de implementação. A revisão humana de especificação, design, rastreabilidade e validações permanece necessária antes de qualquer implementação. Aprovador organizacional formal não identificado.
