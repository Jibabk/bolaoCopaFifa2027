---
name: verify-bolao
description: Sobe e dirige o Bolão Copa FIFA 2027 real (Next.js em web + FastAPI + PostgreSQL via Docker Compose) numa pilha isolada, exercita as funcionalidades por HTTP como um usuário e guarda evidência. Use para provar comportamento de mudanças em backend/, frontend/, docker-compose.yml ou Dockerfile, no passo 3 da skill verificacao ou quando pedirem "verify-bolao".
---

# verify-bolao

Prova comportamento no app real. Não substitui `scripts/verificar.sh` nem os testes: complementa os dois com a pilha de verdade rodando.

**Superfícies.** A principal é a web do Next.js (página inicial, 404). A API FastAPI (`/`, `/live`, `/ready`, `/docs`, `/redoc`, `/openapi.json`) é a segunda superfície e sustenta a web. O produto ainda é um scaffold sem login, palpites ou ranking. Quando essas funcionalidades chegarem, entram em `features/`.

**Harness.** O script `bin/verify-bolao.sh` faz tudo: compose isolado, `curl` e `psql` somente leitura. Não há navegador nem Playwright no ambiente, e o CLAUDE.md proíbe instalar dependências sem autorização. Por isso a prova da web é o HTML do SSR (todas as páginas atuais são server components, então o HTML já é o que o usuário vê). Quando surgir interação no cliente (formulários, `'use client'`), o HTML deixa de bastar: registre a lacuna e peça autorização ao humano para um navegador. Não declare como verificado o que só um navegador mostraria.

## Isolamento

- Cada run tem projeto Compose `bolao-verify-<RUN_ID>`, portas livres aleatórias em `127.0.0.1`, volume próprio do Postgres (nasce vazio) e `.next` em volume anônimo.
- A pilha do desenvolvedor (`docker compose up` na raiz, portas 3000/8000/5432, projeto `bolaocopafifa2027`) **nunca** é dirigida nem derrubada por esta skill. Se você precisa dela, peça ao humano.
- Duas runs podem coexistir, cada uma com seu RUN_ID.
- O código é bind mount do working tree (`./backend`, `./frontend`), então a run testa o que está no disco agora, inclusive o que não foi commitado. O `next dev` da run reescreve `frontend/next-env.d.ts`, que é ignorado pelo git.

## Launch

```bash
H=.claude/skills/verify-bolao/bin/verify-bolao.sh   # sempre a partir da raiz do repo
RUN_ID=$(date +%Y%m%d-%H%M%S)                     # ou um nome [a-z0-9-], ex.: issue-42
$H up "$RUN_ID"
```

Pré-requisito: Docker Desktop aberto com integração WSL (`docker info` responde). O `up`:

1. Gera `override.yml` com portas próprias e faz `docker compose up -d --build --wait` (até 420 s).
2. Roda `alembic upgrade head` no backend. Hoje não há revisões, só a tabela `alembic_version`.
3. Espera ficar **usável**: `/ready` = `ready` (banco consultado pela API) **e** a `/` do frontend devolve o heading "Bolão da Copa do Mundo Feminina", ou seja, o `next dev` já compilou.

A pilha está pronta quando a última linha é:

```
READY <RUN_ID> frontend=http://127.0.0.1:<FE> backend=http://127.0.0.1:<BE> evidence=<repo>/.git/verify-bolao/<RUN_ID>/evidence
```

Para ler as URLs depois: `cat .git/verify-bolao/$RUN_ID/state.env`. Na primeira vez o build leva cerca de 3–4 min, e depois o cache encurta. Em falha, o `up` mostra o fim de `up.log`. Rode `down` antes de tentar de novo.

## Doctor

Rode primeiro sempre que algo parecer estranho. É somente leitura:

```bash
$H doctor "$RUN_ID"
```

Ele confere 3/3 containers em execução, se as portas publicadas pertencem a **este** projeto, `/live` (`bolao-backend`), `/ready` (`ready`), `/api/health` (`bolao-frontend`) e o título do OpenAPI. Também avisa se o HEAD mudou desde o `up`: o código recarrega sozinho, mas as dependências da imagem não, então refaça a run se `pyproject.toml` ou `package*.json` mudou. Só dirija com `DOCTOR OK`.

## Drive

| Comando | Para quê |
|---|---|
| `$H get <RUN_ID> frontend\|backend <caminho> [nome]` | GET como usuário. Grava `<nome>.body`, `<nome>.headers` e uma linha em `requests.log` (hora, URL, status). Imprime o status. |
| `$H psql <RUN_ID> "<sql>"` | Consulta no banco da run em transação **read only** (escrita falha com `read-only transaction`). Saída em `psql.log`. |
| `$H compose <RUN_ID> <args...>` | `docker compose` restrito ao projeto da run, ex.: `stop db`, `start db`, `ps`, `exec -T backend ...`. |
| `$H logs <RUN_ID>` | Grava `compose.log` com os logs de todos os serviços. |
| `$H ls` | Lista as runs ativas e as já derrubadas. |

As asserções são feitas sobre os arquivos gravados, com `grep`/`python3 -c json`, nunca sobre a memória do que você "viu". Os recipes por funcionalidade estão em [`features/README.md`](features/README.md). Uma prova que cobre só uma entrada de uma funcionalidade que o mapa lista com várias está incompleta.

Para requisições que não são GET (quando a API ganhar POST), use `curl` contra `$BE_URL` do `state.env` com `-o/-D` dentro de `.git/verify-bolao/$RUN_ID/evidence/` e anexe a linha em `requests.log`. Se o padrão se repetir, estenda o helper.

## Evidence

Tudo fica em `.git/verify-bolao/<RUN_ID>/evidence/`. Fica dentro de `.git`, então nunca é commitado e sobrevive ao `down`. Os arquivos são `up.log`, `migrations.log`, `requests.log`, `*.body`, `*.headers`, `psql.log`, `compose.log` e `down.log`.

Padrões de prova:

- Exercite o caminho real do usuário: rotas públicas pelas portas publicadas. Nada de importar módulos, chamar setters internos, `TestClient` ou endpoints só de teste.
- Capture a ação **e** o estado resultante. Ex.: `requests.log` mostra o 503 com o banco parado e o 200 depois de `start db`, não só o estado final.
- Verifique efeitos colaterais além do que aparece: linhas no banco via `psql`, logs via `logs`.
- Mock só onde uma fronteira de produção já isola o sistema externo. Hoje não há nenhum.
- No relatório (PR, skill verificacao), cite o RUN_ID, os comandos, os status e trechos dos arquivos de evidência. Se a run não chegou a `DOCTOR OK`, a verificação **não** foi feita: diga isso.

## Cleanup

```bash
$H down "$RUN_ID"
```

Salva `compose.log` e roda `docker compose down --volumes --remove-orphans --rmi local` **só** no projeto `bolao-verify-<RUN_ID>` (recusa qualquer outro). Depois confere que não sobrou container e apaga `state.env`/`override.yml`. A evidência fica. A saída esperada é `DOWN <RUN_ID> | evidência preservada em ...`. Rode o `down` também depois de um `up` que falhou. Nunca mate processo por nome nem use `docker compose down` sem `-p`. A evidência antiga pode ser apagada pelo humano com `rm -rf .git/verify-bolao/<RUN_ID>`.

## Helpers

- `bin/verify-bolao.sh` (executável, `bash`). O repo tem `core.fileMode=false`: ao commitar, use `git add --chmod=+x`. Sem argumentos imprime o uso. Variável opcional: `VERIFY_BOLAO_HOME` troca a raiz das runs, que por padrão é `.git/verify-bolao`. Depende de `docker compose` ≥ 2.24 (por causa da tag `!override`), `curl`, `python3` e `git`.
