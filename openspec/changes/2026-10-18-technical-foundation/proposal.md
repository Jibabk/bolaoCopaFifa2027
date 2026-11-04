# Proposta: Fundação técnica

## Por quê

Estabelecer a base técnica mínima para o desenvolvimento orientado a especificações do Bolão Copa FIFA 2027, conforme a stack e a direção arquitetural aprovadas. O repositório tem scaffold de backend, frontend e Compose ainda não validado por execução; lockfile e configuração de lint do frontend foram criados localmente em 19/10/2026, sem instalação/build. ADR-001 aprovou a direção VSA pragmática no mesmo repositório, sem incluir a reorganização interna no escopo desta change. Este trabalho precisa funcionar em Windows 11 com WSL 2/Ubuntu e em Linux.

## O que muda

- Validar e corrigir o scaffold do backend FastAPI (build, pacotes, entrypoint e `/ready` com verificação de banco).
- Validar e corrigir o scaffold do frontend Next.js/TypeScript (lockfile, ESLint, estágio de desenvolvimento).
- Validar o Docker Compose e os healthchecks de backend, frontend e PostgreSQL.
- Inicializar o Alembic em `backend/migrations/`.
- Manter as especificações técnicas PROD-01, TEC-01 e PROD-07 como documentos para aprovação humana.

## Capacidades afetadas

Nenhuma regra de produto muda. Esta mudança trata apenas de scaffolding e ambiente de desenvolvimento, sem impacto em pontuação, prazos, ranking ou badges.

## Fora de escopo

- Implementar regras de negócio, telas ou casos de uso.
- Implementar a organização interna dos módulos em fatias verticais por caso de uso, direção aprovada no ADR-001. Exige change própria para design, tarefas e validação.
- Criar recursos de nuvem ou configurar implantação.
- Escolher ferramentas de verificação de fronteiras e de testes do frontend (decisão humana pendente).

## Impacto

Permite que as próximas changes do OpenSpec partam de um ambiente validado. Não altera requisitos nem decisões aprovadas.

## Governança humana

Aprovação humana: Jean, 2026-11-04

Aprovação registrada em 30/10/2026: o solicitante do projeto aprovou a implementação desta change na conversa com o Claude Code e escolheu o driver psycopg 3 (aprovador organizacional não identificado; registro informal, sem ata). Permanecem fora desta aprovação a ferramenta de verificação de fronteiras, a ferramenta de testes do frontend e as especificações PROD-01/TEC-01/PROD-07, que seguem pendentes de decisão humana.

Este artefato exige aprovação humana antes da implementação. As tarefas devem citar esta proposta e manter a rastreabilidade entre requisito ou decisão e tarefa técnica.
