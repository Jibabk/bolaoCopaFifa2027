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

**Status: desenho técnico e escopo da primeira fatia aprovados pelo solicitante em 02/11/2026; implementação explicitamente autorizada.** Em 03/11/2026, o solicitante aprovou defaults locais para respostas genéricas HTTP 202, limites de cadastro/reenvio, erros genéricos de confirmação e entrega do código por arquivo local fora do Git, restrito ao desenvolvimento. Falhas/crashes entre PostgreSQL e filesystem mantêm a solicitação `pending_delivery`; retry oportunístico limitado ocorre durante requisições de cadastro/reenvio, sem worker dedicado, reconhece arquivo existente idempotentemente e mantém falha genérica enquanto pendente; confirmação só é aceita após entrega. Rate-limit usa somente `request.client.host`, ignorando headers de encaminhamento; proxy exige configuração explícita de proxies confiáveis. Em produção, o fluxo deve permanecer desabilitado até integração segura de e-mail. Em 03/11/2026, para cadastro duplicado, o solicitante decidiu preservar e retornar o token opaco original sem reenviar código; o valor será cifrado com Fernet usando chave dedicada estável em arquivo 0600 fora do Git, distinta da chave HMAC do código, com falha fechada se ausente/inválida e sem registrar token/ciphertext/chave em logs. A aprovação cobre somente a primeira fatia; não aprova as posteriores nem a operação de provedor externo OPS-03. Aprovador organizacional formal não identificado.
