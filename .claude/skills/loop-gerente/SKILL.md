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
| Avaliação | Comparar o relatório do dry run com [gabarito.md](gabarito.md). O modo `aplicar` só é liberado pelo humano quando as decisões coincidirem com a política. |
| Escalonamento | Toda dúvida vira `needs:human` com a pergunta objetiva no comentário. `agent:ready` é sempre aplicado pelo humano. |

## Modos

- `dry-run` (padrão): só lê e imprime o relatório. Não chama comandos `gh` que escrevem.
- `aplicar`: só quando o usuário pedir explicitamente nesta invocação.

## Pré-condições

1. `gh repo set-default --view` aponta para o fork, não para `malvesro/bolaoCopaFifa2027`. Se apontar para o upstream ou falhar, pare.
2. `gh auth status` está autenticado.

## Política de classificação

**Change elegível**: o `proposal.md` contém uma linha `Aprovação humana: <nome>, <AAAA-MM-DD>`. Sem essa linha, nenhuma tarefa da change gera issue.

**Risco**
- `risk:high`: toca pontuação 6/3/2/1/0, corte de 1 h, desempates, mata-mata aos 120 min, ocultação de palpites alheios, autenticação, sessão, identidade (HU-21/22/23), autorização administrativa, auditoria, dados pessoais ou migração que altera dados existentes.
- `risk:medium`: novo caso de uso, endpoint ou tela sem regra crítica; nova tabela ou migração de esquema; mudança de contrato de API.
- `risk:low`: scaffold, configuração, build, lint, docs técnicas; sem regra de produto; verificação executável e determinística.

**Tipo**: `type:infra` (Docker, Compose, CI, build), `type:backend`, `type:frontend`, `type:docs`, `type:test`. Uma issue tem um tipo; se tocar mais de uma área, use a dominante e cite a outra na justificativa.

**Sugerir `agent:ready`** somente quando todas forem verdadeiras:
- change elegível e tarefa ainda `- [ ]`;
- `risk:low`;
- a tarefa tem "Verificação / Teste" executável no ambiente local;
- o texto da tarefa não contém "decisão humana", "aprovação humana", "aguardar", "pendente", "a decidir" ou equivalente;
- nenhuma pendência aberta em `decisoes-pendentes.md` afeta a tarefa.

Caso contrário, sugerir `needs:human` e dizer o que falta decidir.

## Procedimento

1. Verificar as pré-condições.
2. Listar as changes ativas (`openspec list --json`) e ler o `proposal.md` de cada uma; separar elegíveis e não elegíveis.
3. Para cada change elegível, numerar as tarefas de nível superior do `tasks.md` em ordem (T1, T2, ...). Tarefas `- [x]` aparecem no relatório como concluídas e não geram issue.
4. Buscar issues existentes pelo marcador `<!-- loop-task: <change>#T<n> -->` (`gh issue list --state all --search "loop-task <change>" --json number,title,body,labels,state`). Se o título do `tasks.md` mudou para uma issue existente, reportar a divergência e não criar outra.
5. Classificar cada tarefa pela política acima.
6. Imprimir o relatório. Em `dry-run`, parar aqui.
7. Em `aplicar`, para cada tarefa sem issue:
   - título: `[<change>] T<n>: <Tarefa Técnica resumida>`;
   - corpo: marcador, requisito/decisão, tarefa técnica, arquivo/componente, verificação, link para a change;
   - labels `risk:*`, `type:*` e, se for o caso, `needs:human`;
   - comentário: sugestão (`agent:ready` ou `needs:human`) e justificativa com fonte.
   Para issues existentes, só atualizar `risk:*`, `type:*`, `needs:human` e comentar quando a classificação mudar.
8. Terminar com a lista de issues que o humano deve revisar para aplicar `agent:ready`.

## Setup inicial das labels (uma vez, com autorização do usuário)

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

Labels são metadados de roteamento, não barreira de segurança. A barreira real é o fork, as permissões do Claude Code e o merge humano.
