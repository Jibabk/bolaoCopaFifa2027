#!/usr/bin/env bash
# Hook PreToolUse (Bash): bloqueia `gh pr create` se o HEAD atual não tiver o carimbo
# gerado por scripts/verificar.sh com a árvore limpa.
entrada=$(cat)
case "$entrada" in
  *"gh pr create"*) ;;
  *) exit 0 ;;
esac

cd "${CLAUDE_PROJECT_DIR:-.}" || exit 0
carimbo="$(git rev-parse --absolute-git-dir 2>/dev/null)/loop/verificado"
head=$(git rev-parse HEAD 2>/dev/null)

if [ -n "$(git status --porcelain)" ]; then
  echo "PR bloqueado: há alterações não commitadas. Commite e rode scripts/verificar.sh (skill verificacao)." >&2
  exit 2
fi
if [ ! -f "$carimbo" ] || [ "$(cat "$carimbo")" != "$head" ]; then
  echo "PR bloqueado: o HEAD $(git rev-parse --short HEAD) não passou por scripts/verificar.sh. Rode as skills testes e verificacao." >&2
  exit 2
fi
exit 0
