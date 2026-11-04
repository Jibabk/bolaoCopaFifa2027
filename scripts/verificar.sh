#!/usr/bin/env bash
# Portão de verificação obrigatório após qualquer implementação e antes de qualquer PR.
# Roda os checks das áreas alteradas desde a base e, se tudo passar com a árvore limpa,
# grava o carimbo do HEAD exigido por .claude/hooks/portao-pr.sh.
# Uso: scripts/verificar.sh [--base <ref>] [--tudo]
set -uo pipefail

BASE="origin/main"
TUDO=0
while [ $# -gt 0 ]; do
  case "$1" in
    --base) BASE="$2"; shift 2 ;;
    --tudo) TUDO=1; shift ;;
    *) echo "uso: $0 [--base <ref>] [--tudo]" >&2; exit 2 ;;
  esac
done

RAIZ=$(git rev-parse --show-toplevel) || exit 2
cd "$RAIZ" || exit 2
git rev-parse --verify -q "$BASE" >/dev/null || { echo "base '$BASE' não encontrada; rode git fetch" >&2; exit 2; }

DIR_LOOP="$(git rev-parse --absolute-git-dir)/loop"
RELATORIO="$DIR_LOOP/verificacao.txt"
CARIMBO="$DIR_LOOP/verificado"
mkdir -p "$DIR_LOOP"
rm -f "$CARIMBO"
: > "$RELATORIO"

ALTERADOS=$( { git diff --name-only "$BASE"...HEAD; git diff --name-only HEAD; git ls-files --others --exclude-standard; } | sort -u )
FALHAS=0

registrar() { printf '%s\n' "$*" | tee -a "$RELATORIO"; }
tocou() { [ "$TUDO" -eq 1 ] || printf '%s\n' "$ALTERADOS" | grep -Eq "$1"; }
falta() { registrar "FAIL  pré-requisito ausente: $1"; FALHAS=$((FALHAS + 1)); }

# checar <nome> <diretório> <comando...>
checar() {
  local nome=$1 dir=$2 saida codigo
  shift 2
  saida=$(cd "$dir" && "$@" 2>&1)
  codigo=$?
  if [ "$codigo" -eq 0 ]; then
    registrar "PASS  $nome"
    printf '%s\n' "$saida" | grep -E '^SKIPPED|passed|failed' | sed 's/^/      /' | tee -a "$RELATORIO"
  else
    registrar "FAIL  $nome (código $codigo)"
    printf '%s\n' "$saida" | tail -40 | sed 's/^/      /' | tee -a "$RELATORIO"
    FALHAS=$((FALHAS + 1))
  fi
}

# pytest sem testes coletados (código 5) não é falha.
pytest_backend() {
  .venv/bin/pytest -q -rs
  local codigo=$?
  [ "$codigo" -eq 5 ] && return 0
  return "$codigo"
}

registrar "Verificação $(date -Iseconds) | HEAD $(git rev-parse --short HEAD) | base $BASE"

if tocou '^backend/'; then
  if [ -x backend/.venv/bin/pytest ]; then
    checar "backend: ruff check" backend .venv/bin/ruff check .
    checar "backend: ruff format --check" backend .venv/bin/ruff format --check .
    checar "backend: mypy app" backend .venv/bin/mypy app
    checar "backend: pytest" backend pytest_backend
  else
    falta "backend/.venv com as dependências de dev"
  fi
fi

if [ "$TUDO" -eq 0 ] && tocou '^backend/app/.*\.py$'; then
  if printf '%s\n' "$ALTERADOS" | grep -Eq '^backend/tests/.*\.py$'; then
    registrar "PASS  testes acompanham backend/app"
  elif git log --format=%B "$BASE"..HEAD | grep -Eq '^Sem-Teste: .+'; then
    registrar "PASS  testes acompanham backend/app (Sem-Teste justificado no commit)"
  else
    registrar "FAIL  backend/app alterado sem teste em backend/tests nem trailer 'Sem-Teste: <motivo>'"
    FALHAS=$((FALHAS + 1))
  fi
fi

if tocou '^frontend/'; then
  if [ -d frontend/node_modules ]; then
    checar "frontend: lint" frontend npm run lint
    checar "frontend: type-check" frontend npm run type-check
  else
    falta "frontend/node_modules (npm ci)"
  fi
fi

if tocou '(^|/)(docker-compose\.yml|Dockerfile|\.dockerignore)$|^\.env\.example$'; then
  if docker info >/dev/null 2>&1; then
    checar "infra: docker compose config" . docker compose config --quiet
    for svc in backend frontend; do
      if tocou "^$svc/(Dockerfile|\.dockerignore|package(-lock)?\.json|pyproject\.toml)$"; then
        checar "infra: docker compose build $svc" . docker compose build "$svc"
      fi
    done
  else
    falta "Docker acessível no WSL (Docker Desktop aberto, integração WSL ativa)"
  fi
fi

if tocou '^openspec/'; then
  # O openspec instalado no Windows (/mnt/...) travou o WSL em I/O; só o nativo é aceito.
  OPENSPEC=$(command -v openspec || true)
  if [ -n "$OPENSPEC" ] && [ "${OPENSPEC#/mnt/}" = "$OPENSPEC" ] && timeout 30 openspec --version >/dev/null 2>&1; then
    checar "openspec: validate --all --strict" . timeout 300 openspec validate --all --strict
  else
    falta "openspec instalado no WSL (exige Node >= 20.19; o do Windows em /mnt não é usado)"
  fi
fi

# Verificação comportamental (pstack): obrigatória quando o app muda.
if tocou '^(backend|frontend)/|(^|/)(docker-compose\.yml|Dockerfile)$'; then
  if ls .claude/skills/verify-*/SKILL.md .cursor/skills/verify-*/SKILL.md >/dev/null 2>&1; then
    registrar "PASS  skill verify-* presente (executá-la é obrigatório pela skill verificacao)"
  else
    falta "skill verify-* do projeto; rode /pstack:create-verification-skill"
  fi
fi

if tocou '^frontend/(app|components|features)/|^backend/app/(entrypoints/|bootstrap/main\.py$)'; then
  registrar "AVISO superfície do usuário alterada: /pstack:maintain-verification-skill é obrigatório antes do PR"
fi

checar "git: diff --check" . git diff --check "$BASE"

if [ "$FALHAS" -gt 0 ]; then
  registrar "RESULTADO: FALHOU ($FALHAS)"
  exit 1
fi
if [ -n "$(git status --porcelain)" ]; then
  registrar "RESULTADO: PASSOU, mas há alterações não commitadas; carimbo não gerado"
  exit 0
fi
git rev-parse HEAD > "$CARIMBO"
registrar "RESULTADO: PASSOU; carimbo gerado para $(git rev-parse --short HEAD)"
