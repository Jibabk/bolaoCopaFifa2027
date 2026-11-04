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
| Permitido | Editar os arquivos listados em "Arquivo / Componente" da tarefa, marcar a caixa e registrar a verificação da tarefa no `tasks.md`; rodar a verificação da tarefa e os checks da área; delegar a subagentes; commitar; `git push origin agent/*`; `gh pr create` no fork; comentar e trocar `agent:ready`/`agent:in-progress`/`needs:human` na própria issue. |
| Proibido | Merge, push na `main`, push no upstream, `--force`, `--no-verify`, `reset --hard`, `rebase`. Editar requisitos, ADRs, `proposal.md`, `design.md`, `specs/`, `CLAUDE.md`, `.claude/`, `.github/` ou `.env*`. Instalar dependências fora do que a tarefa manda (`npm ci` só quando a tarefa pedir). Corrigir problemas fora do escopo. Aplicar `agent:ready` em qualquer issue. |
| Saída | Branch `agent/<issue>-<slug>` com um commit por tarefa, PR no fork com o template do projeto preenchido e comentário na issue com as evidências. |
| Avaliação | Skills `testes` e `verificacao` concluídas, carimbo do `scripts/verificar.sh` no HEAD publicado, revisão sem achado bloqueante e diff restrito aos arquivos permitidos. |
| Escalonamento | Qualquer parada: remover `agent:in-progress`, aplicar `needs:human` e comentar motivo, evidência e pergunta objetiva. |

## Pré-condições (parar se alguma falhar)

1. Rodando no clone do WSL (`~/projetosgit/bolaoCopaFifa2027`).
2. `git status --porcelain` vazio.
3. `git remote get-url origin` é o fork e `git remote get-url upstream` é `malvesro/bolaoCopaFifa2027`.
4. `gh repo set-default --view` aponta para o fork e `gh auth status` está autenticado.

## Procedimento (uma issue por execução)

1. **Selecionar.** `gh issue list --state open --label agent:ready --json number,title,body,labels --limit 20`. Descartar issues com `agent:in-progress` ou `needs:human`. Pegar a de menor número. Se não houver nenhuma, relatar "fila vazia" e encerrar; dentro de `/loop`, encerrar o loop.
2. **Revalidar.** Ler o marcador, a change e a tarefa T<n>. Confirmar que o `proposal.md` tem `Aprovação humana: <nome>, <AAAA-MM-DD>`, que a caixa da tarefa ainda está `- [ ]` e que a "Tarefa Técnica" atual da T<n> é a mesma do corpo da issue (a numeração é posicional). Se não, escalar.
3. **Reivindicar.** `gh issue edit <n> --remove-label agent:ready --add-label agent:in-progress` (nesta ordem: o deny das permissões bloqueia `--add-label` antes de `agent:ready`) e comentar o início.
4. **Branch.** `git fetch origin && git switch -c agent/<n>-<slug> origin/main`. Se já existir branch `agent/<n>-*`, não recriar nem apagar: escalar citando a branch.
5. **Planejar.** Rodar `openspec instructions apply --change "<change>" --json`, ler os `contextFiles` e comentar na issue um plano curto: arquivos, passos, verificação.
6. **Implementar.** Delegar ao especialista da área com a tarefa, os arquivos permitidos, os `contextFiles` e o limite de escopo: `backend-expert` (backend), `frontend-expert` (frontend), `fast-worker` (Docker, scripts, configuração). Uma área por subagente; não paralelizar edições na mesma área.
7. **Testar e verificar (obrigatório).** Invocar a skill `testes` e depois a skill `verificacao` (verificação da tarefa + `scripts/verificar.sh`). Guardar comandos, códigos de saída e trechos das saídas. Em falha, corrigir e repetir, no máximo 2 vezes; depois escalar. Se a skill `testes` concluiu `Sem-Teste`, a linha FAIL "backend/app alterado sem teste… nem trailer" é esperada antes do commit e não conta como tentativa; ela precisa virar PASS no passo 12. Todas as outras linhas precisam passar já aqui.
8. **Conferir escopo.** `{ git diff --name-only origin/main; git ls-files --others --exclude-standard; } | sort -u` só pode conter os arquivos da tarefa (ou arquivos novos dentro dos diretórios listados), os testes em `backend/tests/` criados pela skill `testes`, correções em `.claude/skills/verify-*/` ou `.cursor/skills/verify-*/` vindas do `/pstack:maintain-verification-skill` e o `tasks.md` da change. Qualquer outro arquivo: escalar.
9. **Revisar.** Enviar o diff, a tarefa e as evidências ao `code-reviewer`. Enviar também ao `security-analyst` se o diff tocar autenticação, sessão, identidade, administração, segredos, variáveis de ambiente ou CORS. Achado bloqueante: voltar ao passo 6 e repetir o passo 7 (conta como tentativa) ou escalar.
10. **Marcar.** Trocar `- [ ]` por `- [x]` na linha da tarefa T<n> e acrescentar sob ela, como nas tarefas já concluídas, `  - Verificação registrada (<DD/MM/AAAA>): <comando> -> <resultado real>; pulos: <...>`, copiado das evidências do passo 7. Não alterar outras linhas.
11. **Commitar.** Um commit com os arquivos da tarefa e os testes, mensagem em Conventional Commits em português, por exemplo `chore(infra): valida docker compose (#<n>)`, com corpo citando a change, a tarefa e a verificação executada, o trailer `Sem-Teste: <motivo>` quando a skill `testes` concluiu que não há comportamento testável, e o trailer de coautoria vigente da sessão.
12. **Portão final (obrigatório).** Com a árvore limpa, executar `scripts/verificar.sh`. Ele precisa terminar com "carimbo gerado"; caso contrário, voltar ao passo 7 ou escalar. Sem carimbo o hook bloqueia o PR.
    Se o relatório trouxer o AVISO de superfície do usuário e a issue ainda não tiver um comentário humano `maintain: clean` ou `maintain: changed` para esta branch, parar sem publicar: aplicar `needs:human`, remover `agent:in-progress` e comentar "Rode `/pstack:maintain-verification-skill` na branch `agent/<n>-<slug>`, commite as correções da skill `verify-*` nessa branch se houver, comente `maintain: <resultado>` e rode `/loop-worker retomar <n>`".
13. **Grafo.** Se `graphify` existir, rodar `graphify update .` (o `graphify-out/` é ignorado pelo git).
14. **Publicar.** `git push -u origin agent/<n>-<slug>` e `gh pr create --base main --head agent/<n>-<slug>` no fork, com o corpo seguindo `.github/pull_request_template.md`: change e data de aprovação, requisito de origem, regras críticas tocadas, relatório do `scripts/verificar.sh` (PASS/FAIL e testes pulados), testes criados e `Closes #<n>`.
15. **Fechar o ciclo.** Remover `agent:in-progress` e comentar na issue o link do PR, as verificações e os achados de revisão. O merge é sempre humano.

## Ao parar

- Não publicar trabalho parcial. Deixar a branch local, voltar para `main` (`git switch main`) só se a árvore estiver limpa e citar a branch no comentário.
- Aplicar `needs:human`, remover `agent:in-progress` e explicar: o que foi tentado, a evidência e a decisão necessária.
- Problemas fora do escopo encontrados durante o trabalho são citados no comentário, não corrigidos.

## Retomada (`/loop-worker retomar <n>`)

Interrupção fora do passo 12 (contexto esgotado, Ctrl+C, queda do WSL): a issue fica em `agent:in-progress`. O humano remove essa label e aplica `needs:human` ou `agent:ready`; se a branch `agent/<n>-*` existir, o passo 4 escala para o humano decidir entre descartar e retomar.

Parada no passo 12 por falta do `maintain-verification-skill`: Conferir o comentário humano `maintain: clean` ou `maintain: changed` (com `blocked`, manter `needs:human`), trocar `needs:human` por `agent:in-progress`, fazer `git switch agent/<n>-<slug>`, repetir os passos 8, 12, 13, 14 e 15 e citar o resultado do maintain no PR.

## Execução contínua

`/loop /loop-worker` processa uma issue por iteração. O loop termina quando a fila esvaziar ou quando duas iterações seguidas terminarem em escalonamento.
