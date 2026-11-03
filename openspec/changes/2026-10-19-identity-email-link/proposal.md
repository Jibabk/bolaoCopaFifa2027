# Proposta: Cadastro local, verificação de e-mail e admissão

## Por quê

A primeira entrega funcional prioriza cadastro local, confirmação do endereço, login por credencial local, admissão administrativa e alteração do endereço de e-mail local. A participação continua condicionada à aprovação administrativa (PROD-07). A integração Google, o primeiro vínculo Google/local e a recuperação de senha HU-21 ficam fora desta entrega. A alteração do e-mail local deve observar a verificação prevista pela HU-22 (código de seis dígitos e até três tentativas), sem importar para esse fluxo a validade ou a política de reenvio do código de cadastro, ainda não definida para a alteração.

## O que muda

- Especificar solicitação de cadastro local com nome, e-mail e credencial local, confirmação do e-mail, autenticação por usuário/senha após a confirmação e alteração de e-mail local com ativação apenas após verificar o endereço novo.
- Reutilizar no desenvolvimento local a exceção administrativa já decidida em PROD-08 (`admin`, senha configurada em variável local não versionada, sem validação de e-mail, exclusivamente em `ENVIRONMENT=development`). Provisionamento e recuperação de acesso administrativo fora do ambiente local permanecem fora/pendentes; esta change não define uma credencial ou setup de produção.
- Especificar a aprovação/rejeição administrativa da participação, com autorização e auditoria, mantendo usuários não aprovados impedidos de participar.
- Manter recuperação de senha HU-21 fora desta entrega e a autenticação Google como opcional/futura, sem misturar seus fluxos com confirmação de e-mail local.

## Capacidades afetadas

`identity` no backend, `features/auth` no frontend, contratos de API, envio de e-mail (OPS-03) e autorização administrativa (PROD-07/08). Fontes: requisito v3.4 e decisões PROD-07/08 → cenários em `specs/identity-email-link/spec.md` → tarefas em `tasks.md` → testes propostos. Nenhuma validação de runtime foi executada.

## Fora de escopo

Integração e autenticação Google, primeiro vínculo Google/local (incluindo os fluxos de HU-22/23 correspondentes), recuperação de senha HU-21, seleção/operação de fornecedor de e-mail, implementação, edição da change de scaffold `2026-10-18-technical-foundation`, Docker e implantação em nuvem. A verificação de endereço local alterado, incluída nesta entrega e referenciada pela HU-22, não habilita vínculo Google. Políticas técnicas ainda abertas não são fixadas por esta proposta.

## Governança

**Status: desenho técnico e escopo da primeira fatia aprovados pelo solicitante em 02/11/2026; implementação explicitamente autorizada para cadastro e confirmação local, mas ainda não iniciada por solicitação do usuário.** A aprovação cobre o recorte e o desenho técnico mínimo documentados para essa fatia, não resolve mecanismos ou políticas ainda listados como pendentes e não aprova as fatias posteriores. A autorização atual não é instrução para começar a codificar neste turno. Aprovador organizacional formal não identificado.
