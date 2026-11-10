# Classificação de comandos

Antes de executar, classifique o comando. Na dúvida, trate-o como 🟡.

## 🟢 Livre — somente leitura

### Verificações de ambiente

```bash
# Sistema e WSL
uname -sr                                   # "microsoft" no kernel indica WSL
pwd                                         # alerta se começar com /mnt/c (I/O lento no WSL)

# Ferramentas
git --version
docker --version
docker compose version
docker info --format '{{.ServerVersion}}'   # falha = daemon parado ou sem permissão
python3 --version
node --version
npm --version
command -v openspec && openspec --version
command -v graft

# Repositório
git status --short --branch
git log --oneline -5

# Configuração local (sem ler valores)
test -f .env && echo ".env existe" || echo ".env ausente"
test -f .env && { grep -qE '^LOCAL_ADMIN_PASSWORD=.+' .env && echo "LOCAL_ADMIN_PASSWORD definida" || echo "LOCAL_ADMIN_PASSWORD ausente"; }
git check-ignore -q .env && echo ".env ignorado pelo Git"

# Dependências locais
test -x backend/.venv/bin/python && backend/.venv/bin/python --version
test -x backend/.venv/bin/pytest && echo "pytest presente no venv" || echo "pytest ausente no venv"
test -d frontend/node_modules && echo "node_modules presente" || echo "node_modules ausente"

# Portas
ss -ltnp 2>/dev/null | grep -E ':(3000|8000|5432)\b' || echo "portas 3000/8000/5432 livres"

# Serviços
docker compose ps
docker compose config --quiet && echo "compose válido"   # valida sem imprimir valores
```

### Leitura e diagnóstico

- Ler arquivos versionados: `README.md`, docs, manifestos, código e testes.
- `docker compose logs --tail=100 <serviço>`.
- `curl -fsS http://127.0.0.1:8000/live` e `curl -fsS -o /dev/null -w '%{http_code}\n' http://localhost:3000`.
- `git diff --check`, `openspec validate --all --strict`, `graft map`, `graft ask`.

Nunca rode `cat .env`, `docker compose config` sem `--quiet`, `env`/`printenv` ou `docker compose exec backend env`: todos exibem segredos.

## 🟡 Com autorização explícita

| Comando | Efeito |
|---|---|
| `cp .env.example .env` | Cria o arquivo local de segredos. Só se `.env` não existir; nunca sobrescreva. |
| `python3 -m venv backend/.venv` | Cria o virtualenv dentro do repositório (ignorado pelo Git). |
| `backend/.venv/bin/pip install -e "backend[dev]"` | Baixa e instala as dependências Python do backend e de desenvolvimento. |
| `npm ci` (em `frontend/`) | Apaga e recria `frontend/node_modules` a partir do lockfile. |
| `docker compose build` / `up --build -d` | Baixa imagens, constrói, cria rede/volume e ocupa portas. |
| `docker compose restart <serviço>` | Interrompe o serviço por alguns segundos. |
| `docker compose down` | Para e remove containers; **preserva** o volume do banco. |
| `pytest`, `ruff`, `mypy`, `npm run lint`, `npm run type-check` | Leem o código, mas podem gerar caches (`.pytest_cache`, `.mypy_cache`, `tsconfig.tsbuildinfo`). Pedir uma vez no pacote da etapa 5. |
| `npm run build` | Gera `.next/`; demorado. |
| `git switch -c <branch>` | Cria uma branch local. Só na etapa 7, se pedido. |
| `git add` / `git commit` | Só se a pessoa pedir, e nunca na `main`. |
| `npm install -g @nanonets/graft`, `graft build` | Instalação global e geração do mapa `graft/`. |

## 🔴 Proibido nesta skill

Não execute. Se for necessário, explique o efeito e deixe que a pessoa decida e execute.

- `docker compose down -v`: apaga o volume `postgres_data` e todos os dados locais do banco.
- `docker system prune`, `docker volume rm`, `docker image prune -a`.
- `rm -rf` em qualquer caminho do repositório ou do ambiente.
- `git reset --hard`, `git clean -fd`, `git checkout -- .`, `git stash drop`, `git push` (qualquer variante), `git rebase`.
- Commit na `main`.
- Editar, desabilitar ou apagar testes para que passem.
- Ler, exibir ou versionar `.env`, chaves ou tokens.
- Operar em produção ou criar recursos de nuvem.
