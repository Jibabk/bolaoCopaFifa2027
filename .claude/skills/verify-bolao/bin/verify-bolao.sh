#!/usr/bin/env bash
# Harness de verificação do Bolão: sobe uma pilha Docker Compose isolada (projeto e portas
# próprios), dirige-a por HTTP e guarda evidência que sobrevive ao teardown.
# Uso: verify-bolao <up|doctor|get|psql|compose|logs|down|ls> ...  (ver SKILL.md)
set -euo pipefail

RAIZ=$(git -C "$(dirname "$0")" rev-parse --show-toplevel)
BASE_RUNS="${VERIFY_BOLAO_HOME:-$(git -C "$RAIZ" rev-parse --absolute-git-dir)/verify-bolao}"
PREFIXO="bolao-verify-"

morrer() { echo "verify-bolao: $*" >&2; exit 1; }

porta_livre() { python3 -c 'import socket; s=socket.socket(); s.bind(("127.0.0.1",0)); print(s.getsockname()[1]); s.close()'; }

carregar() {
  RUN_ID=${1:?informe o RUN_ID}
  DIR="$BASE_RUNS/$RUN_ID"
  [ -f "$DIR/state.env" ] || morrer "run '$RUN_ID' não existe ou já foi derrubada (state em $DIR/state.env)"
  # shellcheck disable=SC1091
  . "$DIR/state.env"
  EVID="$DIR/evidence"
  mkdir -p "$EVID"
}

dc() { docker compose -p "$PROJETO" --project-directory "$RAIZ" -f "$RAIZ/docker-compose.yml" -f "$DIR/override.yml" "$@"; }

cmd_up() {
  local run_id=${1:-$(date +%Y%m%d-%H%M%S)}
  [[ "$run_id" =~ ^[a-z0-9][a-z0-9-]*$ ]] || morrer "RUN_ID deve ser [a-z0-9-]"
  DIR="$BASE_RUNS/$run_id"
  [ -e "$DIR/state.env" ] && morrer "run '$run_id' já existe; use outro RUN_ID ou 'down $run_id'"
  docker info >/dev/null 2>&1 || morrer "Docker inacessível (abra o Docker Desktop com integração WSL)"
  mkdir -p "$DIR/evidence"
  local fe be db
  fe=$(porta_livre); be=$(porta_livre); db=$(porta_livre)
  cat > "$DIR/state.env" <<EOF
RUN_ID=$run_id
PROJETO=$PREFIXO$run_id
FE_PORT=$fe
BE_PORT=$be
DB_PORT=$db
FE_URL=http://127.0.0.1:$fe
BE_URL=http://127.0.0.1:$be
HEAD_NO_UP=$(git -C "$RAIZ" rev-parse HEAD)
EOF
  # Override de verificação: portas próprias em loopback e .next em volume anônimo, para não
  # colidir com a pilha do desenvolvedor (que usa 3000/8000/5432 e o mesmo bind mount ./frontend).
  cat > "$DIR/override.yml" <<EOF
services:
  frontend:
    ports: !override
      - "127.0.0.1:$fe:3000"
    environment:
      - NEXT_PUBLIC_API_URL=http://127.0.0.1:$be
    volumes:
      - /app/.next
  backend:
    ports: !override
      - "127.0.0.1:$be:8000"
    environment:
      - CORS_ORIGINS=http://127.0.0.1:$fe
  db:
    ports: !override
      - "127.0.0.1:$db:5432"
EOF
  carregar "$run_id"
  echo "[up] projeto $PROJETO | frontend $FE_URL | backend $BE_URL | db 127.0.0.1:$DB_PORT"
  if ! dc up -d --build --wait --wait-timeout 420 >"$EVID/up.log" 2>&1; then
    tail -30 "$EVID/up.log" >&2
    morrer "compose up falhou (log em $EVID/up.log); rode 'down $RUN_ID'"
  fi
  echo "[up] migrações: alembic upgrade head"
  dc exec -T backend alembic upgrade head >"$EVID/migrations.log" 2>&1 \
    || { cat "$EVID/migrations.log" >&2; morrer "migração falhou; rode 'down $RUN_ID'"; }
  # Pronto = usável: banco respondendo pela API e a página inicial já compilada pelo next dev.
  local i
  for i in $(seq 1 60); do
    if curl -fsS "$BE_URL/ready" 2>/dev/null | grep -q '"ready"' \
      && curl -fsS "$FE_URL/" 2>/dev/null | grep -q 'Bolão da Copa do Mundo Feminina'; then
      echo "READY $RUN_ID frontend=$FE_URL backend=$BE_URL evidence=$EVID"
      return 0
    fi
    sleep 2
  done
  morrer "pilha subiu mas não ficou usável em 120 s; veja '$0 logs $RUN_ID'"
}

cmd_doctor() {
  carregar "$@"
  local ok=0
  chk() { if eval "$2" >/dev/null 2>&1; then echo "OK    $1"; else echo "FAIL  $1"; ok=1; fi; }
  echo "run $RUN_ID | projeto $PROJETO | HEAD no up ${HEAD_NO_UP:0:7} | HEAD atual $(git -C "$RAIZ" rev-parse --short HEAD)"
  chk "containers do projeto em execução (3/3)" '[ "$(dc ps --status running -q | wc -l)" -eq 3 ]'
  chk "porta frontend $FE_PORT pertence a $PROJETO" '[ "$(dc port frontend 3000)" = "127.0.0.1:$FE_PORT" ]'
  chk "porta backend $BE_PORT pertence a $PROJETO" '[ "$(dc port backend 8000)" = "127.0.0.1:$BE_PORT" ]'
  chk "backend /live = bolao-backend" 'curl -fsS "$BE_URL/live" | grep -q "\"bolao-backend\""'
  chk "backend /ready = ready (banco ok)" 'curl -fsS "$BE_URL/ready" | grep -q "\"ready\""'
  chk "frontend /api/health = bolao-frontend" 'curl -fsS "$FE_URL/api/health" | grep -q "\"bolao-frontend\""'
  chk "OpenAPI título Bolão Copa 2027" 'curl -fsS "$BE_URL/openapi.json" | grep -q "Bolão Copa 2027"'
  [ "$HEAD_NO_UP" = "$(git -C "$RAIZ" rev-parse HEAD)" ] \
    || echo "AVISO HEAD mudou desde o up: código é bind mount (recarrega), mas dependências da imagem não; refaça up se pyproject/package mudou"
  [ $ok -eq 0 ] && echo "DOCTOR OK" || { echo "DOCTOR FAIL"; return 1; }
}

# get <RUN_ID> <frontend|backend> <caminho> [nome]: requisição GET de usuário com evidência.
cmd_get() {
  carregar "$1"
  local alvo=$2 caminho=$3 nome=${4:-}
  local url
  case "$alvo" in frontend) url="$FE_URL$caminho" ;; backend) url="$BE_URL$caminho" ;; *) morrer "alvo deve ser frontend|backend" ;; esac
  [ -n "$nome" ] || nome="$alvo$(printf '%s' "$caminho" | tr -c 'a-zA-Z0-9' '_')"
  local status
  status=$(curl -sS -o "$EVID/$nome.body" -D "$EVID/$nome.headers" -w '%{http_code}' "$url")
  printf '%s GET %s -> %s\n' "$(date -Iseconds)" "$url" "$status" | tee -a "$EVID/requests.log"
  echo "body: $EVID/$nome.body"
}

# psql <RUN_ID> "<sql>": consulta somente leitura no banco da run (transação read only).
cmd_psql() {
  carregar "$1"
  dc exec -T db sh -c 'psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" -At' \
    <<<"SET default_transaction_read_only = on; $2" | tee -a "$EVID/psql.log"
}

# compose <RUN_ID> <args...>: docker compose restrito ao projeto da run (ex.: stop db).
cmd_compose() { carregar "$1"; shift; dc "$@"; }

cmd_logs() {
  carregar "$1"
  dc logs --no-color --timestamps >"$EVID/compose.log" 2>&1
  echo "logs: $EVID/compose.log"
}

cmd_down() {
  carregar "$1"
  [[ "$PROJETO" == "$PREFIXO"* ]] || morrer "projeto '$PROJETO' não é de verificação; recusando"
  dc logs --no-color --timestamps >"$EVID/compose.log" 2>&1 || true
  # Remove só containers, rede e volumes deste projeto; a evidência fica em $EVID.
  dc down --volumes --remove-orphans --rmi local >"$EVID/down.log" 2>&1 || true
  [ -z "$(docker ps -aq --filter "label=com.docker.compose.project=$PROJETO")" ] \
    || morrer "ainda há containers de $PROJETO; veja $EVID/down.log"
  rm -f "$DIR/state.env" "$DIR/override.yml"
  echo "DOWN $RUN_ID | evidência preservada em $EVID"
}

cmd_ls() {
  local d
  for d in "$BASE_RUNS"/*/; do
    [ -d "$d" ] || continue
    if [ -f "$d/state.env" ]; then echo "ATIVA     $(basename "$d")"; else echo "derrubada $(basename "$d") (evidência em ${d}evidence)"; fi
  done
}

sub=${1:-}; shift || true
case "$sub" in
  up|doctor|get|psql|compose|logs|down|ls) "cmd_$sub" "$@" ;;
  *) sed -n '2,4p' "$0"; exit 2 ;;
esac
