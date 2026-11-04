---
name: loop-worker
description: Loop worker do bolão. Pega uma issue `agent:ready` do fork, implementa a tarefa OpenSpec correspondente em branch isolada, verifica, revisa, commita e abre PR no fork para merge humano. Use quando o usuário pedir "loop worker", "/loop-worker" ou rodar `/loop /loop-worker`.
---

# Loop worker

## Design card

| Campo | Definição |
|---|---|
| Trabalho | Implementar uma tarefa OpenSpec por execução, a partir de uma issue `agent:ready`, e entregar um PR com evidências. |
| Entradas | Issue elegível do fork; change OpenSpec citada no marcador `<!-- loop-task: <change>#T<n> -->`; arquivos de contexto do `openspec instructions apply`. |
| Permitido | Editar os arquivos listados em "Arquivo / Componente" da tarefa e marcar a caixa da tarefa no `tasks.md`; rodar a verificação da tarefa e os checks da área; delegar a subagentes; commitar; `git push origin agent/*`; `gh pr create` no fork; comentar e trocar `agent:ready`/`agent:in-progress`/`needs:human` na própria issue. |
| Proibido | Merge, push na `main`, push no upstream, `--force`, `--no-verify`, `reset --hard`, `rebase`. Editar requisitos, ADRs, `proposal.md`, `design.md`, `specs/`, `CLAUDE.md`, `.claude/`, `.github/` ou `.env*`. Instalar dependências fora do que a tarefa manda (`npm ci` só quando a tarefa pedir). Corrigir problemas fora do escopo. Aplicar `agent:ready` em qualquer issue. |
| Saída | Branch `agent/<issue>-<slug>` com um commit por tarefa, PR no fork com o template do projeto preenchido e comentário na issue com as evidências. |
| Avaliação | Verificação da tarefa passando, checks da área passando, revisão sem achado bloqueante e diff restrito aos arquivos permitidos. |
| Escalonamento | Qualquer parada: remover `agent:in-progress`, aplicar `needs:human` e comentar motivo, evidência e pergunta objetiva. |

## Pré-condições (parar se alguma falhar)

1. Rodando no clone do WSL (`~/projetosgit/bolaoCopaFifa2027`).
2. `git status --porcelain` vazio.
3. `git remote get-url origin` é o fork e `git remote get-url upstream` é `malvesro/bolaoCopaFifa2027`.
4. `gh repo set-default --view` aponta para o fork e `gh auth status` está autenticado.

## Procedimento (uma issue por execução)

1. **Selecionar.** `gh issue list --state open --label agent:ready --json number,title,body,labels --limit 20`. Descartar issues com `agent:in-progress` ou `needs:human`. Pegar a de menor número. Se não houver nenhuma, relatar "fila vazia" e encerrar; dentro de `/loop`, encerrar o loop.
2. **Revalidar.** Ler o marcador, a change e a tarefa T<n>. Confirmar que o `proposal.md` tem `Aprovação humana: <nome>, <AAAA-MM-DD>` e que a caixa da tarefa ainda está `- [ ]`. Se não, escalar.
3. **Reivindicar.** `gh issue edit <n> --remove-label agent:ready --add-label agent:in-progress` e comentar o início.
4. **Branch.** `git fetch origin && git switch -c agent/<n>-<slug> origin/main`.
5. **Planejar.** Rodar `openspec instructions apply --change "<change>" --json`, ler os `contextFiles` e comentar na issue um plano curto: arquivos, passos, verificação.
6. **Implementar.** Delegar ao especialista da área com a tarefa, os arquivos permitidos, os `contextFiles` e o limite de escopo: `backend-expert` (backend), `frontend-expert` (frontend), `fast-worker` (Docker, scripts, configuração). Uma área por subagente; não paralelizar edições na mesma área.
7. **Verificar.** Executar exatamente o comando da "Verificação / Teste" da tarefa e os checks das áreas tocadas:
   - backend: `ruff check .`, `mypy app` e `pytest` dentro de `backend/` com a `.venv`; `pytest` sem testes coletados (código 5) não é falha;
   - frontend: `npm run lint` e `npm run type-check` dentro de `frontend/`.
   Guardar comando, código de saída e trecho relevante da saída. Se falhar, corrigir e tentar de novo, no máximo 2 vezes.
8. **Conferir escopo.** `git diff --name-only origin/main` só pode conter os arquivos da tarefa (ou arquivos novos dentro dos diretórios listados) e o `tasks.md` da change. Qualquer outro arquivo: escalar.
9. **Revisar.** Enviar o diff, a tarefa e as evidências ao `code-reviewer`. Enviar também ao `security-analyst` se o diff tocar autenticação, sessão, identidade, administração, segredos, variáveis de ambiente ou CORS. Achado bloqueante: voltar ao passo 6 (conta como tentativa do passo 7) ou escalar.
10. **Marcar.** Trocar `- [ ]` por `- [x]` só na linha da tarefa T<n>.
11. **Commitar.** Um commit com os arquivos da tarefa, mensagem em Conventional Commits em português, por exemplo `chore(infra): valida docker compose (#<n>)`, com corpo citando a change, a tarefa e a verificação executada, e o trailer de coautoria vigente da sessão.
12. **Grafo.** Se `graphify` existir, rodar `graphify update .` (o `graphify-out/` é ignorado pelo git).
13. **Publicar.** `git push -u origin agent/<n>-<slug>` e `gh pr create --base main --head agent/<n>-<slug>` no fork, com o corpo seguindo `.github/pull_request_template.md`: change e data de aprovação, requisito de origem, regras críticas tocadas, testes efetivamente executados com resultado e `Closes #<n>`.
14. **Fechar o ciclo.** Remover `agent:in-progress` e comentar na issue o link do PR, as verificações e os achados de revisão. O merge é sempre humano.

## Ao parar

- Não publicar trabalho parcial. Deixar a branch local, voltar para `main` (`git switch main`) só se a árvore estiver limpa e citar a branch no comentário.
- Aplicar `needs:human`, remover `agent:in-progress` e explicar: o que foi tentado, a evidência e a decisão necessária.
- Problemas fora do escopo encontrados durante o trabalho são citados no comentário, não corrigidos.

## Execução contínua

`/loop /loop-worker` processa uma issue por iteração. O loop termina quando a fila esvaziar ou quando duas iterações seguidas terminarem em escalonamento.
