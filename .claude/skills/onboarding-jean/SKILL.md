---
name: onboarding-jean
description: Conduz o onboarding de uma pessoa desenvolvedora nova no Bolão Copa FIFA 2027 — propósito do projeto, preparação do ambiente local, execução do projeto e dos testes, arquitetura básica e primeira contribuição segura. Use quando alguém pedir onboarding de desenvolvedor, "por onde começo", "como rodo o projeto/os testes", "me explica a arquitetura" ou "como faço minha primeira contribuição". Orienta e verifica com comandos somente leitura; não instala nada nem executa ações destrutivas, e pede autorização antes de qualquer comando com efeito colateral. Não edita o README (para isso, use a skill onboarding).
metadata:
  version: "1.0.0"
  language: pt-BR
---

# Onboarding de desenvolvedor — Bolão Copa FIFA 2027

## Objetivo

Levar uma pessoa nova do zero até: (1) entender para que serve o projeto, (2) ter o ambiente local preparado, (3) rodar o projeto e os testes, (4) entender a arquitetura básica e (5) saber fazer a primeira contribuição com segurança.

O papel do agente é **guia e verificador**, não instalador. Ele lê, verifica, explica e propõe; quem decide qualquer mudança no ambiente é a pessoa.

## Contrato de segurança — vale para todas as etapas

Classifique cada comando antes de executá-lo. Detalhes e exemplos em [references/classificacao-de-comandos.md](references/classificacao-de-comandos.md).

| Classe | O que é | Conduta |
|---|---|---|
| 🟢 **Livre** | Somente leitura, sem efeito colateral (versões, `git status`, `docker compose ps`, `test -f`, ler arquivos versionados). | Execute direto. |
| 🟡 **Com autorização** | Instala, cria, baixa, constrói, sobe serviço ou ocupa porta (`npm ci`, `pip install`, `python -m venv`, `docker compose up --build`, `cp .env.example .env`, rodar testes que precisam de serviços). | Mostre o comando exato, o que ele altera e quanto tempo/espaço pode levar; peça autorização explícita; execute somente o que foi aprovado. |
| 🔴 **Proibido nesta skill** | Destrutivo ou irreversível (`docker compose down -v`, `rm -rf`, `docker system prune`, `git reset --hard`, `git clean`, `git push`, commit na `main`, alterar testes para passar). | Não execute. Se a pessoa precisar, explique o efeito e deixe que ela rode por conta própria. |

Regras adicionais:

- **`.env` é secreto.** Nunca leia, exiba, copie para a conversa nem faça commit do conteúdo. Para verificar uma variável, cheque apenas a presença: `grep -qE '^LOCAL_ADMIN_PASSWORD=.+' .env && echo definida || echo ausente`.
- **Não invente comandos, versões ou portas.** Confirme cada um em `README.md`, `docker-compose.yml`, `backend/pyproject.toml`, `frontend/package.json` ou nos `Dockerfile`s antes de sugerir. Se a documentação e os manifestos divergirem, mostre a divergência e não a corrija por conta própria.
- **Não declare teste como aprovado sem executá-lo.** Reporte o comando, o código de saída e o resumo real. "Não executado" é uma resposta válida, desde que venha com o motivo.
- **Não altere código, testes, configuração nem documentação** durante o onboarding. A exceção é o que a pessoa pedir explicitamente na etapa 7.
- **Agrupe pedidos de autorização.** Em cada ponto de decisão, apresente uma única lista numerada de comandos 🟡 para a pessoa aprovar todos, alguns ou nenhum. Se a ferramenta `AskUserQuestion` estiver disponível, use-a.
- **Respeite o `CLAUDE.md`.** Se `docs/STATE.md` indicar `BLOQUEADO_HUMANO` ou `CONCLUIDO`, informe a situação. Etapas somente leitura (1–4 e 6) continuam; as etapas 5 e 7 dependem de confirmação.

## Fluxo

Execute as etapas na ordem. Ao fim de cada uma, escreva uma linha `✅ Etapa N/7 — <resultado>` e siga para a próxima, sem esperar nova mensagem. A exceção são os pontos de autorização, onde você deve parar.

### Etapa 1/7 — Leitura inicial e relatório de fontes

Leia, nesta ordem:

1. `README.md` — obrigatório. Se não existir, registre isso.
2. `CLAUDE.md`, se existir.
3. `CHECKLISTS.md`, se existir. Procure em todo o repositório, não só na raiz: `find . -name CHECKLISTS.md -not -path '*/node_modules/*' -not -path './.git/*'`. Neste projeto, o arquivo costuma estar em `ferramentas-uteis/graft/CHECKLISTS.md`.
4. Documentação de arquitetura, se existir: `docs/architecture/arquitetura-software.md`, os ADRs em `docs/architecture/decisoes-tecnicas/` (comece por `ADR-001-*`) e `docs/architecture/revisao-arquitetura-multiagentes.md`. Localize com `ls docs/architecture docs/architecture/decisoes-tecnicas`.

Leitura complementar, só para contexto: `CONTRIBUTING.md`, `docs/STATE.md` (estado atual e fila de tarefas), `backend/README.md`, `frontend/README.md` e `.github/pull_request_template.md`.

Em documentos longos, leia primeiro os títulos (`grep -nE '^#{1,3} ' arquivo`) e depois as seções relevantes. Diga quando a leitura foi parcial.

**Entrega obrigatória** — informe quais arquivos leu, em tabela:

| Arquivo | Situação | Leitura | Para que serve |
|---|---|---|---|
| `README.md` | encontrado | completa | porta de entrada |
| `CHECKLISTS.md` | encontrado em `ferramentas-uteis/graft/` | parcial (seções X, Y) | … |
| `…` | **não encontrado** | — | — |

### Etapa 2/7 — Para que serve o projeto

Explique em até 10 linhas, com base no que leu:

- o que é o produto (bolão web de um grupo único para a Copa do Mundo Feminina da FIFA Brasil 2027) e quem o usa (participantes e administração);
- as regras centrais e onde estão as normativas: pontuação 6/3/2/1/0, mata-mata pelo placar ao fim de 120 minutos, corte uma hora antes do kickoff, horário BRT e ranking/desempates. A fonte é `docs/requirements/requisitos-bolao-copa-mundo-feminina-2027.md`, com pendências em `docs/requirements/decisoes-pendentes.md`;
- o **estágio atual**, separando o que está **implementado**, **planejado (OpenSpec)** e **pendente de decisão**. Use `README.md` §2, `docs/STATE.md` e `openspec/changes/`.

Não resolva lacunas de produto. Se algo estiver pendente, diga que está pendente.

### Etapa 3/7 — Descobrir a stack

Extraia dos manifestos, não da memória:

- topologia e serviços: `docker-compose.yml` (serviços, portas, healthchecks, redes, volume, variáveis obrigatórias);
- backend: `backend/pyproject.toml` (Python exigido, dependências e extras `dev`) e `backend/Dockerfile` (o que a imagem instala);
- frontend: `frontend/package.json` (scripts, versões de Next/React/TypeScript) e `frontend/Dockerfile`;
- ferramentas de processo: OpenSpec (`openspec/config.yaml`) e Graft (`ferramentas-uteis/graft/`).

Apresente uma tabela **Componente | Tecnologia | Versão declarada | Fonte**. Deixe claro que faixas como `>=` ou `^` são declarações, não versões validadas. Aponte divergências entre docs e manifestos, por exemplo um driver de banco citado nos docs que difere do que está em `pyproject.toml`.

Fato relevante a confirmar e explicar: a imagem do backend instala o pacote **sem** os extras `dev`. Se isso ainda valer, `pytest`, `ruff` e `mypy` não existem dentro do container, e os testes rodam num virtualenv local (`backend/.venv`).

### Etapa 4/7 — Verificar o ambiente (somente 🟢)

Rode as verificações de [references/classificacao-de-comandos.md](references/classificacao-de-comandos.md#verificações-de-ambiente) e apresente:

| Item | Esperado (fonte) | Encontrado | Status | Ação sugerida |
|---|---|---|---|---|
| Docker / Compose | README §7.1 | … | ✅ / ⚠️ / ❌ | … |
| Daemon Docker ativo | — | … | … | … |
| Python | `>=3.11` (pyproject) | … | … | … |
| Node / npm | README §7.1 | … | … | … |
| `.env` + `LOCAL_ADMIN_PASSWORD` | exigido pelo compose | definida/ausente (sem valor) | … | … |
| `backend/.venv` com extras dev | para testes | … | … | … |
| `frontend/node_modules` | para lint/type-check | … | … | … |
| Portas 3000/8000/5432 livres ou já do projeto | compose | … | … | … |
| OpenSpec / Graft | opcionais | … | … | … |
| WSL 2 e local do clone | README §6.5 | … | … | … |

No WSL, avise se o repositório estiver em `/mnt/c/...` (I/O lento e problemas com file watchers) e recomende o filesystem Linux. Não mova nada.

Para cada ❌ ou ⚠️, proponha o comando de correção como 🟡 e **não execute**. Tudo vai para o pedido de autorização da etapa 5.

### Etapa 5/7 — Rodar o projeto e os testes (🟡 com autorização)

**Ponto de autorização.** Monte uma lista numerada só com o que falta, por exemplo:

1. Criar `.env` a partir do exemplo: `cp .env.example .env`. Só se `.env` não existir; nunca sobrescreva. A pessoa define `LOCAL_ADMIN_PASSWORD` com um valor que ela escolhe. Não sugira um valor nem o escreva por ela.
2. Preparar o backend local: `python3 -m venv backend/.venv` e `backend/.venv/bin/pip install -e "backend[dev]"`.
3. Preparar o frontend: `npm ci` em `frontend/` (usa o `package-lock.json`).
4. Subir os serviços: `docker compose up --build -d`. Isso constrói imagens, cria rede e volume e ocupa as portas 3000, 8000 e 5432.
5. Rodar os testes e as validações listados abaixo.

Pare e espere a resposta. Execute somente os itens aprovados.

Antes de subir os serviços, rode `docker compose ps`. Se já houver containers do projeto rodando, não reinicie nem reconstrua sem perguntar. Rode `docker compose config --quiet` para validar a configuração sem exibir valores.

**Verificar a aplicação** (🟢 depois que estiver no ar):

- `docker compose ps` — todos `running`/`healthy`;
- `curl -fsS http://127.0.0.1:8000/live` — liveness do backend;
- `curl -fsS -o /dev/null -w '%{http_code}\n' http://localhost:3000` — frontend respondendo;
- OpenAPI em `http://localhost:8000/docs`.

Se algo falhar, use `docker compose logs --tail=100 <serviço>` para diagnosticar. Explique a causa provável e proponha a correção. Não altere código nem configuração.

**Testes e validações**, confirmados nos manifestos:

| Área | Comando | Pré-requisito |
|---|---|---|
| Backend — testes | `cd backend && .venv/bin/python -m pytest` | venv com `[dev]` |
| Backend — lint | `cd backend && .venv/bin/ruff check .` | venv com `[dev]` |
| Backend — tipos | `cd backend && .venv/bin/mypy app` | venv com `[dev]` |
| Frontend — tipos | `cd frontend && npm run type-check` | `node_modules` |
| Frontend — lint | `cd frontend && npm run lint` | `node_modules` e `.eslintrc.json` existente (sem ele, `next lint` fica interativo) |
| Especificações | `openspec validate --all --strict` | CLI `openspec` |
| Higiene do diff | `git diff --check` | — |

Reporte cada execução assim:

| Comando | Código de saída | Resultado |
|---|---|---|
| `pytest` | 0 | 7 passed |
| `npm run lint` | — | não executado: `node_modules` ausente, instalação não autorizada |

Falhas são informação de onboarding, não algo para consertar agora. Explique, aponte o arquivo e a linha, e siga em frente.

No fim, pergunte se os serviços devem continuar rodando. Para parar, sugira `docker compose down`, que **preserva** o banco. Nunca sugira `down -v` sem explicar que isso apaga o volume `postgres_data`.

### Etapa 6/7 — Arquitetura básica

Explique a partir da documentação **e** da árvore real (`find backend/app frontend -type f -not -path '*/node_modules/*' -not -name '.gitkeep'`). Se o Graft estiver disponível (`command -v graft`), prefira `graft map` ou `graft ask "<pergunta>"` a varrer arquivos.

Cubra:

1. **Topologia local:** navegador → `frontend` (Next.js, :3000) → `backend` (FastAPI, :8000) → `db` (PostgreSQL, :5432). Inclua as redes `frontend-network` e `backend-network` (esta é `internal`) e o volume `postgres_data`.
2. **Estilo arquitetural:** monólito modular com VSA pragmática por capacidade, DDD pragmático e Clean Architecture sem abstrações desnecessárias (ADR-001). Diga o que já está aprovado (ADR-001) e o que ainda é recomendação.
3. **Backend:** `app/bootstrap/main.py` (composição e rotas `/`, `/live`, `/ready`), `app/entrypoints/http/`, `app/shared/` e `app/modules/<capacidade>/{domain,application,adapters}` para `identity`, `tournament`, `predictions`, `scoring`, `ranking`, `gamification` e `support`. Mostre quais módulos têm código real (ex.: `identity/local_admin.py`) e quais são só esqueleto (`.gitkeep`).
4. **Frontend:** `app/` (App Router), `features/` (ex.: `admin-login.tsx`), `components/` e `lib/`.
5. **Regras que a arquitetura protege:** o backend impõe prazo de corte e autorização, palpites alheios ficam ocultos antes do corte e operações administrativas são auditadas.
6. **Por onde ler o código:** indique de 3 a 5 arquivos, em ordem.

Use um diagrama Mermaid `flowchart` curto, se ajudar. Ele deve refletir só o que existe ou está aprovado.

### Etapa 7/7 — Primeira contribuição segura

Oriente, sem executar ações Git que alterem estado:

1. **Escolher a tarefa:** veja a fila em `docs/STATE.md` §5, as changes em `openspec/changes/` ou pergunte a quem mantém o projeto. Boas primeiras contribuições: correções de documentação, testes para comportamento que já existe (ex.: ao lado de `backend/tests/api/test_local_admin.py`) e itens que não dependem de decisões pendentes.
2. **Governança:** mudança de comportamento passa por OpenSpec (proposta → aprovação humana → implementação → validação). Artefato pronto não autoriza implementar. Consulte `CONTRIBUTING.md` §1.
3. **Branch:** nunca trabalhe na `main`. Sugira um nome convencional, como `docs/ajusta-guia-onboarding` ou `test/cobre-logout-admin`, e o comando `git switch -c <branch>`. Só execute se a pessoa pedir.
4. **Commits:** Conventional Commits com emoji, em português do Brasil, claros e concisos (ex.: `📝 docs(readme): corrige porta do frontend`). Veja `CONTRIBUTING.md` §2 e o histórico (`git log --oneline -10`).
5. **Antes do PR/MR:** rode as validações pertinentes da etapa 5, `git diff --check` e `git status`. Confirme que `.env` e segredos estão fora do diff e preencha `.github/pull_request_template.md`. Declare só o que foi executado.
6. **O que não fazer:** veja `CONTRIBUTING.md` §3 (push sem autorização, alterar teste para passar, inventar regra de produto) e o `CLAUDE.md` (não versionar `graft/`, não incluir segredos).

Se a pessoa quiser fazer a primeira mudança agora, trate isso como uma nova tarefa. Confirme o escopo, crie a branch só com autorização, faça a mudança pequena, valide e pare antes de qualquer `git push`.

## Entrega final

Feche com o resumo em [assets/RESUMO.template.md](assets/RESUMO.template.md): fontes lidas, propósito, stack, ambiente, resultados de execução e testes (com códigos de saída), arquitetura, próximos passos da primeira contribuição e o que ficou pendente ou não foi autorizado.

Estados finais possíveis:

- `PRONTO` — ambiente verificado, projeto no ar e testes executados;
- `PRONTO COM RESSALVAS` — parte não foi executada (motivo listado);
- `SOMENTE ORIENTAÇÃO` — nenhuma ação 🟡 foi autorizada; tudo foi explicado e verificado em modo leitura.
