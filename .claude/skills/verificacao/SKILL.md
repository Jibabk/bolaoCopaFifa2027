---
name: verificacao
description: Portão obrigatório de verificação. Executa a verificação da tarefa e scripts/verificar.sh após qualquer implementação e antes de qualquer PR, gerando o carimbo exigido pelo hook que bloqueia gh pr create. Use quando o usuário pedir "verificar", "/verificacao" ou antes de abrir PR.
---

# Verificação

Obrigatória depois da skill `testes` e de novo imediatamente antes de qualquer PR. O hook `.claude/hooks/portao-pr.sh` bloqueia `gh pr create` quando o HEAD não tem carimbo do `scripts/verificar.sh` ou a árvore tem alterações não commitadas.

## O que `scripts/verificar.sh` executa

Somente as áreas alteradas desde `origin/main` (`--tudo` executa todas; `--base <ref>` troca a base):

| Área alterada | Checks |
|---|---|
| `backend/` | `ruff check`, `ruff format --check`, `mypy app`, `pytest -q -rs` |
| `backend/app/**.py` | exige teste alterado em `backend/tests/` ou trailer `Sem-Teste: <motivo>` |
| `frontend/` | `npm run lint`, `npm run type-check` |
| Compose, Dockerfile, `.dockerignore`, `.env.example` | `docker compose config --quiet`; `docker compose build <serviço>` quando o Dockerfile ou o manifesto do serviço mudou |
| `openspec/` | `openspec validate --all --strict` |
| sempre | `git diff --check` |

Pré-requisito ausente conta como falha: o portão fecha. Exemplos: `openspec` sem Node ≥ 20.19, Docker Desktop fechado, `.venv` ou `node_modules` ausentes.

O relatório fica em `.git/loop/verificacao.txt` e o carimbo em `.git/loop/verificado`.

## Procedimento

1. Executar a "Verificação / Teste" específica da tarefa, quando houver, e guardar comando, código de saída e trecho da saída.
2. Executar `scripts/verificar.sh`.
3. Em FAIL, corrigir pelo especialista da área ou pela skill `testes` e repetir. No máximo 2 ciclos; depois escalar.
4. Antes do PR, commitar tudo e executar `scripts/verificar.sh` de novo com a árvore limpa. Só essa execução gera o carimbo do HEAD.
5. Levar para a seção "Testes e validação" do PR: as linhas PASS/FAIL, os testes pulados e a verificação da tarefa.

## Proibido

Editar `scripts/verificar.sh` ou o hook para passar, criar ou alterar o carimbo à mão, marcar teste como `skip` para passar, usar `--no-verify`, ou declarar verificação que não foi executada. O carimbo é um controle de processo, não uma barreira de segurança: a barreira final é o merge humano.
