# Design: Technical Foundation

## Arquitetura

Monólito modular com DDD pragmático. O backend FastAPI expõe a API, o frontend Next.js é a camada de apresentação e o PostgreSQL é o repositório de dados, todos orquestrados via Docker Compose. A direção de fatias verticais por caso de uso dentro dos módulos está aprovada no ADR-001; sua implementação não é escopo desta change e exige design específico.

## Estrutura existente (scaffold)

- `backend/app/bootstrap/main.py`: aplicação FastAPI com `/`, `/live` e `/ready`.
- `backend/app/modules/{identity,tournament,predictions,scoring,ranking,support,gamification}/`: apenas diretórios reservados (`.gitkeep`), sem código.
- `backend/app/shared/`, `backend/app/entrypoints/http/`, `backend/migrations/`, `backend/tests/`: reservados, sem código.
- `frontend/app/{layout,loading,not-found,page}.tsx`, `frontend/{features,components,lib,tests}/`.

## Healthchecks

Verificar e alinhar ao que o código expõe, sem presumir:

- backend: o Compose foi alinhado em 19/10/2026 à rota `/live` de `main.py` (antes chamava `/health/live`). `/ready` consulta o banco (`SELECT 1`, timeout de 3 s) e responde 503 sem detalhes quando indisponível; `/live` não depende do banco. Validado por execução em 30/10/2026.
- frontend: `GET /api/health` (route handler) usado como healthcheck no Compose, validado em 30/10/2026.
- postgres: `pg_isready`.

Intervalos e tentativas: manter os valores já configurados em `docker-compose.yml`, revisando-os na implementação.

## Isolamento de dependências

Regra mínima: o domínio não importa FastAPI nem SQLAlchemy, e módulos não leem tabelas de outros módulos. A ferramenta de verificação é o import-linter (aprovado em 10/11/2026), configurado em `backend/pyproject.toml` e executado por `lint-imports`. Contratos iniciais:

1. `app.shared` não importa `app.modules`, `app.bootstrap` nem `app.entrypoints`.
2. `app.modules` não importa `app.bootstrap` nem `app.entrypoints`.
3. Os módulos de `app.modules` são independentes entre si; a change que precisar de dependência entre dois módulos relaxa o contrato para esse par no próprio design.

O contrato que impede o domínio de importar FastAPI e SQLAlchemy fica para a change das fatias verticais, quando existir o pacote de domínio.

## Entrada e saída

- A API usa JSON. O prefixo `/api/v1` é proposta, não implementado.
- O frontend consome o backend por HTTP, sem segredos no código.
- Configuração por variáveis de ambiente (`.env.example`). ADR-001 aprova SQLAlchemy síncrono como ponto de partida; `DATABASE_URL`, driver e manifesto ainda precisam ser compatibilizados e validados antes da execução.
- Alembic para migrações em `backend/migrations/` (a inicializar).
- Configuração tipada por uma classe `Settings` (pydantic-settings) em `backend/app/bootstrap/settings.py`, com `CORS_ORIGINS` e `DATABASE_URL` opcional; sem `DATABASE_URL`, `/ready` continua respondendo 503, como em `test_ready.py`.
- `/live` e `/ready` declaram modelos de resposta Pydantic que reproduzem exatamente o JSON atual, inclusive o 503 `{"status": "unavailable"}`. Envelope de erro, paginação e modelos base por módulo ficam para a primeira change de caso de uso.

## Convenções

- Python 3.11+ com FastAPI e Pydantic; versões a validar.
- TypeScript em modo estrito no Next.js.
- Docker Compose para orquestração local.
