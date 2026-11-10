# Tasks: Technical Foundation Setup

Convenção: [x] só após executar e registrar a verificação. Caminhos marcados "(a criar)" ainda não existem.

- [x] Requisito / Decisão: Stack definida (Next.js/TypeScript, FastAPI/Python, PostgreSQL)
  - Tarefa Técnica: Manter o scaffold de módulos; a organização por fatias dentro dos módulos foi aprovada como direção no ADR-001, mas pertence a change específica
  - Arquivo / Componente: backend/app/modules/, backend/app/shared/, backend/app/bootstrap/, frontend/app/, frontend/features/
  - Verificação / Teste: find backend/app/modules -maxdepth 1 -mindepth 1 -type d, comparado com a tabela de módulos da §10 de docs/architecture/arquitetura-software.md
  - Verificação registrada (30/10/2026): find retornou os 7 módulos da §10 (gamification, identity, predictions, ranking, scoring, support, tournament).

- [x] Requisito / Decisão: Suporte a Windows 11 WSL 2/Ubuntu e Linux
  - Tarefa Técnica: Validar docker-compose.yml com serviços backend, frontend e postgres
  - Arquivo / Componente: docker-compose.yml
  - Verificação / Teste: docker compose config --quiet
  - Verificação registrada (30/10/2026): `docker compose config --quiet` ok; build e `up --wait` executados em Ubuntu/WSL 2 com Docker Desktop. Linux nativo não testado.

- [x] Requisito / Decisão: Health checks para serviços
  - Tarefa Técnica: Validar o healthcheck do backend (alinhado a /live em 19/10/2026, não validado por execução) e fazer /ready consultar o banco
  - Arquivo / Componente: docker-compose.yml, backend/app/bootstrap/main.py
  - Verificação / Teste: docker compose up --wait; com o banco parado, GET /ready deve responder erro (teste de integração a criar)
  - Verificação registrada (30/10/2026): `docker compose up --wait` com 3 serviços healthy; `/ready` respondeu 503 com o `db` parado e 200 após religá-lo; `/live` seguiu 200; `GET /api/health` do frontend 200. Teste: backend/tests/integration/test_ready.py (4 passed, incluindo banco real).

- [x] Requisito / Decisão: Controle de versão do esquema de banco
  - Tarefa Técnica: Inicializar Alembic
  - Arquivo / Componente: backend/migrations/ (alembic.ini a criar)
  - Verificação / Teste: alembic --version e verificação da configuração de migração; autogeração somente após existirem modelos/metadata aprovados e banco acessível
  - Verificação registrada (30/10/2026): `alembic --version` (1.20.1) e `alembic current` ok no host e no container contra o PostgreSQL; sem `DATABASE_URL` o env.py falha com erro explícito. Sem metadata/autogeração (modelos não aprovados); `versions/` vazio.

- [x] Requisito / Decisão: Especificações técnicas PROD-01/TEC-01/PROD-07 (aprovação de Jean em 10/11/2026)
  - Tarefa Técnica: Registrar a aprovação integral de PROD-01 (com 409 Conflict no corte) e a aprovação parcial de TEC-01/PROD-07 nos documentos e em decisoes-pendentes.md
  - Arquivo / Componente: docs/architecture/decisoes-tecnicas/PROD-01-corte-confiavel-palpites.md, docs/architecture/decisoes-tecnicas/TEC-01-PROD-07-autenticacao-admissao.md, docs/requirements/decisoes-pendentes.md
  - Verificação / Teste: grep -n '^\*\*Status:\*\* Aprovada' nos dois arquivos de docs/architecture/decisoes-tecnicas/ (uma linha por arquivo) e grep -n '(especificação técnica)' docs/requirements/decisoes-pendentes.md (linhas de PROD-01 e TEC-01/PROD-07)
  - Verificação registrada (10/11/2026): o grep de Status retornou a linha 5 de cada arquivo ("Aprovada em 10/11/2026" e "Aprovada parcialmente em 10/11/2026"); o grep em decisoes-pendentes.md retornou as linhas 211 e 212.

- [ ] Requisito / Decisão: Isolamento de dependências entre módulos (ADR-001; import-linter aprovado em 10/11/2026)
  - Tarefa Técnica: Adicionar o import-linter às dependências de dev e configurar em backend/pyproject.toml, com root_package app, os três contratos da seção "Isolamento de dependências" do design.md: app.shared não importa app.modules, app.bootstrap nem app.entrypoints; app.modules não importa app.bootstrap nem app.entrypoints; os módulos de app.modules são independentes entre si. Incluir lint-imports nos checks de backend de scripts/verificar.sh
  - Arquivo / Componente: backend/pyproject.toml (a alterar), scripts/verificar.sh (a alterar)
  - Verificação / Teste: cd backend && .venv/bin/lint-imports passa na árvore atual e falha ao adicionar temporariamente em backend/app/shared/ um módulo com import app.modules.identity; scripts/verificar.sh --tudo registra "backend: lint-imports"

- [ ] Requisito / Decisão: Modelo de entrada/saída (arquitetura §198/§201; escopo reduzido aprovado em 10/11/2026, sem mudança de contrato)
  - Tarefa Técnica: Criar a classe Settings (pydantic-settings) com CORS_ORIGINS e DATABASE_URL opcional e usá-la no lugar de os.getenv em main.py e database.py; declarar modelos de resposta Pydantic para /live e /ready que reproduzam exatamente o JSON atual, inclusive o 503 {"status": "unavailable"}. Envelope de erro, paginação e modelos base por módulo ficam fora desta tarefa
  - Arquivo / Componente: backend/app/bootstrap/settings.py (a criar), backend/app/bootstrap/main.py, backend/app/bootstrap/database.py, backend/tests/
  - Verificação / Teste: novo teste que exige que /openapi.json referencie schemas de resposta para /live (200) e /ready (200 e 503) e falha antes da mudança; novo teste unitário de leitura de CORS_ORIGINS pela Settings; backend/tests/integration/test_ready.py continua passando sem alteração; curl -fsS http://localhost:8000/live e http://localhost:8000/ready após docker compose up --wait retornam o mesmo JSON de antes

- [x] Requisito / Decisão: Build reproduzível do backend
  - Tarefa Técnica: Declarar pacotes no setuptools, garantir README.md no passo de instalação, copiar os executáveis (uvicorn) para o estágio final, adicionar __init__.py e .dockerignore
  - Arquivo / Componente: backend/pyproject.toml, backend/Dockerfile, backend/app/ (__init__.py criados), backend/.dockerignore (criado)
  - Verificação / Teste: docker compose build backend
  - Verificação registrada (30/10/2026): `docker compose build backend` ok com `psycopg[binary]`.

- [x] Requisito / Decisão: Build reproduzível do frontend
  - Tarefa Técnica: Gerar e versionar o lockfile, criar a configuração do ESLint, criar um estágio de desenvolvimento no Dockerfile e atualizar a imagem Node
  - Arquivo / Componente: frontend/package-lock.json (gerado, a versionar), frontend/.eslintrc.json (criado), frontend/Dockerfile, frontend/.dockerignore (criado)
  - Verificação / Teste: npm ci, npm run lint, npm run type-check e docker compose build frontend
  - Verificação registrada (30/10/2026): `npm ci`, `npm run lint` (sem avisos), `npm run type-check` e `docker compose build frontend` ok.

- [x] Requisito / Decisão: Configuração por ambiente e driver de banco
  - Tarefa Técnica: Projetar e validar a persistência síncrona aprovada como ponto de partida no ADR-001; selecionar driver e alinhar DATABASE_URL/manifesto, usar env_file no Compose e documentar CORS_ORIGINS no .env.example
  - Arquivo / Componente: .env.example, docker-compose.yml, backend/pyproject.toml
  - Verificação / Teste: docker compose config e conexão real ao banco na verificação do /ready
  - Verificação registrada (30/10/2026): Driver psycopg 3 aprovado em 30/10/2026; `DATABASE_URL` com `postgresql+psycopg://`; backend usa `env_file` opcional; `CORS_ORIGINS` documentado; `docker compose config` ok e conexão real validada pelo `/ready`.
