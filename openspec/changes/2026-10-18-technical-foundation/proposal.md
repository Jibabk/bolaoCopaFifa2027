# Proposta: Fundação técnica

## Por quê

Estabelecer a base técnica mínima para o desenvolvimento orientado a especificações do Bolão Copa FIFA 2027, conforme a stack e a direção arquitetural aprovadas. O repositório tem scaffold de backend, frontend e Compose ainda não validado por execução; lockfile e configuração de lint do frontend foram criados localmente em 19/10/2026, sem instalação/build. ADR-001 aprovou a direção VSA pragmática no mesmo repositório, sem incluir a reorganização interna no escopo desta change. Este trabalho precisa funcionar em Windows 11 com WSL 2/Ubuntu e em Linux.

## O que muda

- Validar e corrigir o scaffold do backend FastAPI (build, pacotes, entrypoint e `/ready` com verificação de banco).
- Validar e corrigir o scaffold do frontend Next.js/TypeScript (lockfile, ESLint, estágio de desenvolvimento).
- Validar o Docker Compose e os healthchecks de backend, frontend e PostgreSQL.
- Inicializar o Alembic em `backend/migrations/`.
- Registrar a aprovação das especificações técnicas PROD-01 (integral) e TEC-01/PROD-07 (parcial).
- Configurar o import-linter para verificar imports entre `shared`, `modules`, `bootstrap` e `entrypoints` do backend.
- Tipar a configuração do backend (`Settings`) e as respostas de `/live` e `/ready`, sem mudar o contrato da API.

## Capacidades afetadas

Nenhuma regra de produto muda. Esta mudança trata apenas de scaffolding e ambiente de desenvolvimento, sem impacto em pontuação, prazos, ranking ou badges.

## Fora de escopo

- Implementar regras de negócio, telas ou casos de uso.
- Implementar a organização interna dos módulos em fatias verticais por caso de uso, direção aprovada no ADR-001. Exige change própria para design, tarefas e validação.
- Criar recursos de nuvem ou configurar implantação.
- Escolher a ferramenta de testes do frontend (decisão humana pendente).
- Definir envelope de erro, paginação ou modelos base por módulo; pertencem à primeira change de caso de uso.

## Impacto

Permite que as próximas changes do OpenSpec partam de um ambiente validado. Não altera requisitos nem decisões aprovadas.

## Governança humana

Aprovação humana: Jean, 2026-11-04

Aprovação registrada em 30/10/2026: o solicitante do projeto aprovou a implementação desta change na conversa com o Claude Code e escolheu o driver psycopg 3 (aprovador organizacional não identificado; registro informal, sem ata). Ampliação aprovada em 10/11/2026 por Jean: import-linter como ferramenta de verificação de fronteiras (T6) e T7 reduzida a `Settings` e modelos de resposta de `/live` e `/ready`, sem mudança de contrato. Na mesma data, a especificação PROD-01 foi aprovada integralmente (com 409 Conflict no corte) e a TEC-01/PROD-07 parcialmente (registro em `docs/requirements/decisoes-pendentes.md`); essas aprovações não autorizam implementar autenticação ou corte nesta change. Permanece fora desta aprovação a ferramenta de testes do frontend.

Este artefato exige aprovação humana antes da implementação. As tarefas devem citar esta proposta e manter a rastreabilidade entre requisito ou decisão e tarefa técnica.
