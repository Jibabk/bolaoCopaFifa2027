#!/usr/bin/env bash
# Hook PreToolUse (Bash): bloqueia a criação de PR (gh pr create/new) se a árvore estiver suja,
# se o HEAD não tiver o carimbo de scripts/verificar.sh, se --head apontar para outra branch
# ou se a branch publicada em origin não for exatamente o HEAD verificado.
entrada=$(cat)
cmd=$(printf '%s' "$entrada" | python3 -c 'import json,sys; print(json.load(sys.stdin).get("tool_input",{}).get("command",""))' 2>/dev/null)
[ -n "$cmd" ] || cmd=$entrada

# Só em posição de comando: mensagens de commit ou grep que citem o texto não disparam.
printf '%s\n' "$cmd" | grep -Eq '(^|[;&|(][[:space:]]*)gh[[:space:]]+pr[[:space:]]+(create|new)([[:space:]]|$)' || exit 0

cd "${CLAUDE_PROJECT_DIR:-.}" || exit 0
bloquear() { echo "PR bloqueado: $*" >&2; exit 2; }

[ -z "$(git status --porcelain)" ] || bloquear "há alterações não commitadas. Commite e rode scripts/verificar.sh (skill verificacao)."

head=$(git rev-parse HEAD)
carimbo="$(git rev-parse --absolute-git-dir)/loop/verificado"
{ [ -f "$carimbo" ] && [ "$(cat "$carimbo")" = "$head" ]; } ||
  bloquear "o HEAD $(git rev-parse --short HEAD) não passou por scripts/verificar.sh. Rode as skills testes e verificacao."

ramo=$(git branch --show-current)
alvo=$(printf '%s\n' "$cmd" | grep -Eo -- '(--head|-H)[= ]+[^[:space:]]+' | head -1 | sed -E 's/^(--head|-H)[= ]+//' | tr -d "\"'" | sed 's/^[^:]*://')
[ -z "$alvo" ] || [ "$alvo" = "$ramo" ] || bloquear "--head '$alvo' difere da branch verificada '$ramo'."

publicado=$(git rev-parse -q --verify "refs/remotes/origin/$ramo" || true)
[ "$publicado" = "$head" ] || bloquear "origin/$ramo não é o HEAD verificado; rode git push -u origin $ramo."
exit 0
