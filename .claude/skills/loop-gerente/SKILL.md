---
name: loop-gerente
description: Loop gerente do bolão. Sincroniza tarefas de changes OpenSpec aprovadas com issues do fork e sugere risco, tipo e elegibilidade, sem escrever código. Use quando o usuário pedir "loop gerente", "triagem do backlog" ou "/loop-gerente". Padrão é dry run.
---

# Loop gerente

## Design card

| Campo | Definição |
|---|---|
| Trabalho | Transformar tarefas de changes OpenSpec aprovadas em issues e classificá-las (risco, tipo, elegibilidade) com justificativa curta. |
| Entradas | `openspec/changes/*/proposal.md` e `tasks.md`; `docs/requirements/decisoes-pendentes.md`; issues abertas do fork. |
| Permitido | Ler o repositório; `openspec list/status/instructions`; `gh issue list/view`; no modo `aplicar`: `gh issue create`, `gh issue comment` e `gh issue edit` só com as labels `risk:*`, `type:*` e `needs:human`. |
| Proibido | Editar arquivos do repositório, commitar, criar branch, abrir ou mesclar PR. Aplicar ou remover `agent:ready` ou `agent:in-progress`. Criar, editar ou apagar labels fora do setup inicial. Usar o repositório upstream. |
| Saída | Relatório de triagem (tabela por tarefa: issue, risco, tipo, sugestão `agent:ready` ou `needs:human`, justificativa e fonte). No modo `aplicar`, também as issues criadas e rotuladas. |
| Avaliação | O humano compara o relatório do dry run com `gabarito.md`. O gerente não lê o gabarito durante a execução. O modo `aplicar` só é liberado pelo humano quando as decisões coincidirem com a política. |
| Escalonamento | Toda dúvida vira `needs:human` com a pergunta objetiva no comentário. `agent:ready` é sempre aplicado pelo humano. |

## Modos

- `dry-run` (padrão): só lê e imprime o relatório. Não chama comandos `gh` que escrevem.
- `aplicar`: só quando o usuário pedir explicitamente nesta invocação.

## Pré-condições

1. `gh repo set-default --view` aponta para o fork, não para `malvesro/bolaoCopaFifa2027`. Se apontar para o upstream ou falhar, pare.
2. `gh auth status` está autenticado.
3. `gh repo view --json hasIssuesEnabled` retorna `true` (forks vêm com issues desligadas).

## Política de classificação

**Change elegível**: o `proposal.md` contém uma linha `Aprovação humana: <nome>, <AAAA-MM-DD>`. Sem essa linha, nenhuma tarefa da change gera issue. Se o texto da aprovação ou a seção "Fora de escopo" da proposta excluir o assunto de uma tarefa, essa tarefa é `needs:human` (aprovação parcial).

**Risco**
- `risk:high`: toca pontuação 6/3/2/1/0, corte de 1 h, desempates, mata-mata aos 120 min, ocultação de palpites alheios, autenticação, sessão, identidade (HU-21/22/23), autorização administrativa, auditoria, dados pessoais ou migração que altera dados existentes. Documentos que definem essas regras também contam como `high`.
- `risk:medium`: novo caso de uso, endpoint ou tela sem regra crítica; nova tabela ou migração de esquema; mudança de contrato de API.
- `risk:low`: scaffold, configuração, build, lint, docs técnicas; sem regra de produto; verificação executável e determinística.

**Tipo**: `type:infra` (Docker, Compose, CI, build, lint e análise estática), `type:backend`, `type:frontend`, `type:docs`, `type:test`. Uma issue tem um tipo; se tocar mais de uma área, use a dominante e cite a outra na justificativa. Tarefas concluídas não recebem risco nem tipo.

**Sugerir `agent:ready`** somente quando todas forem verdadeiras:
- change elegível, tarefa ainda `- [ ]` e assunto não excluído da aprovação;
- `risk:low`;
- a tarefa tem "Verificação / Teste" executável no ambiente local (WSL com Docker Desktop) **e que prova a entrega**: se a verificação já passa no estado atual, sem a mudança, ela não prova nada e a tarefa é `needs:human`;
- o escopo é concreto: nenhum termo indefinido (por exemplo "modelos base") e nenhuma possível mudança de contrato de API;
- o texto da tarefa não contém "decisão humana", "aprovação humana", "aguardar", "pendente", "a decidir" ou equivalente;
- nenhuma pendência aberta em `decisoes-pendentes.md` trata diretamente do assunto da tarefa (pendências genéricas de governança ou versões não contam).

Caso contrário, sugerir `needs:human` e dizer o que falta decidir. Na dúvida entre os dois, `needs:human`.

## Procedimento

1. Verificar as pré-condições.
2. Listar as changes ativas (`openspec list --json`; sem a CLI, os diretórios de `openspec/changes/` exceto `archive/`) e ler o `proposal.md` de cada uma; separar elegíveis e não elegíveis.
3. Para cada change elegível, numerar as tarefas de nível superior do `tasks.md` em ordem (T1, T2, ...). Tarefas `- [x]` aparecem no relatório como concluídas e não geram issue.
4. Listar todas as issues (`gh issue list --state all --limit 500 --json number,title,body,labels,state`) e filtrar localmente pelo marcador `<!-- loop-task: <change>#T<n> -->`; não usar `--search`, que não garante achar texto em comentário HTML. Se a "Tarefa Técnica" no corpo de uma issue existente diferir da atual da T<n> (a numeração é posicional), reportar a divergência e não criar outra.
5. Classificar cada tarefa pela política acima.
6. Imprimir o relatório. Em `dry-run`, parar aqui.
7. Em `aplicar`, para cada tarefa sem issue:
   - título: `[<change>] T<n>: <Tarefa Técnica resumida>`;
   - corpo: marcador, requisito/decisão, "Tarefa Técnica" copiada literalmente, arquivo/componente, verificação, link para a change;
   - labels `risk:*`, `type:*` e, se for o caso, `needs:human`;
   - comentário: sugestão (`agent:ready` ou `needs:human`) e justificativa com fonte.
   Para issues existentes, só atualizar `risk:*`, `type:*`, `needs:human` e comentar quando a classificação mudar.
8. Terminar com a lista de issues (no `dry-run`, das tarefas candidatas) que o humano deve revisar para aplicar `agent:ready`.

## Setup inicial das labels (uma vez, com autorização do usuário)

Já feito no fork em 04/11/2026. Antes de repetir, conferir com `gh label list`; não rodar de novo só para "garantir", porque `--force` sobrescreve descrições.

```bash
gh label create "agent:ready"        --color 0E8A16 --description "Liberada por humano para o loop worker" --force
gh label create "agent:in-progress"  --color FBCA04 --description "Em execução pelo loop worker" --force
gh label create "needs:human"        --color D93F0B --description "Exige decisão ou ação humana" --force
gh label create "risk:low"           --color C2E0C6 --force
gh label create "risk:medium"        --color FEF2C0 --force
gh label create "risk:high"          --color F9D0C4 --force
gh label create "type:infra"         --color BFD4F2 --force
gh label create "type:backend"       --color BFD4F2 --force
gh label create "type:frontend"      --color BFD4F2 --force
gh label create "type:docs"          --color BFD4F2 --force
gh label create "type:test"          --color BFD4F2 --force
```

Labels são metadados de roteamento, não barreira de segurança. As permissões do projeto negam `--add-label agent:ready` e comandos `gh` com `--repo`/`-R`, mas regras de Bash não são barreira forte; a barreira real é o merge humano.
