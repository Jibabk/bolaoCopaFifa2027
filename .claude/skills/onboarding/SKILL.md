---
name: onboarding
description: Investiga qualquer tipo de repositório, compreende seu propósito e reconcilia o README.md com evidências atuais. Use quando o usuário pedir onboarding de projeto, compreensão do repositório, criação ou atualização do README para orientar novos colaboradores.
metadata:
  version: "1.9.0"
  language: pt-BR
---

# Onboarding de repositório

## Objetivo

Investigar o repositório atual e criar ou reconciliar seu `README.md` para que seja a principal porta de entrada do projeto. A Skill é independente de tecnologia e tipo de artefato: não presume código, linguagem, arquitetura, build, testes, containers, Git ou aplicação executável.

## Contrato operacional — leia antes de agir

1. **Priorize executar, não narrar.** Depois de carregar esta Skill, comece imediatamente a inspecionar o workspace e executar a Etapa 1. Não responda apenas com “iniciando”, uma barra, um plano ou uma confirmação.
2. Execute as sete etapas na ordem, no mesmo fluxo de trabalho, até concluir ou encontrar um bloqueio real. O pedido de onboarding autoriza criar/atualizar **somente o README-alvo**. Respeite instrução explícita de somente análise.
3. **Não use barra de progresso, percentuais, contagem regressiva nem mensagem inicial de progresso.** Eles não são objetivo da Skill e não devem competir com a execução.
4. Ao terminar e verificar uma etapa, comunique brevemente sua conclusão em uma mensagem intermediária: `Etapa X/7 concluída — [resultado verificável]. Próxima: [atividade seguinte].`
5. Essa comunicação é um checkpoint, **não uma resposta final nem ponto de parada**. Imediatamente depois, continue a próxima etapa com as ferramentas/ações necessárias no mesmo fluxo de execução. Não aguarde nova mensagem do usuário, não peça `prossiga` e não encerre o turno após um checkpoint enquanto houver etapas pendentes.
6. **Não anuncie uma etapa como concluída antes de executar suas ações e verificar o resultado.** Carregar a Skill, planejar, listar arquivos ou emitir um status não conclui uma etapa.
7. Não pré-escreva os sete checkpoints, não os agrupe numa lista retrospectiva e não os reproduza somente no resumo final. Cada checkpoint deve aparecer depois do trabalho correspondente e antes de continuar o próximo.
8. Se o cliente não entregar mensagens intermediárias em tempo real, continue o trabalho normalmente; não simule streaming. No resultado final, informe com transparência que o runtime agrupou as mensagens. A Skill não cria capacidades de interface ausentes.
9. Se uma atividade não se aplicar, registre por quê e avance. Em falha recuperável, use fallback: sem subagente, investigue diretamente; sem renderizador, valide Mermaid estaticamente; sem build/teste aplicável, não invente comandos.
10. Não contorne permissões, aprovações ou limites externos do runtime. Se uma operação for bloqueada, prossiga com atividades independentes e seguras, registrando a limitação.

### Padrão de checkpoint

Use uma única linha concisa ao final de cada etapa realmente concluída. Exemplo:

> Etapa 1/7 concluída — README-alvo e estado local identificados; alterações preexistentes preservadas e recursos de delegação verificados. Próxima: investigar as fontes do projeto.

Depois dessa linha, execute a etapa seguinte. Não termine a resposta, não retorne o controle e não espere o usuário. O primeiro trabalho após a ativação deve ser uma ação real de inspeção do repositório, não um anúncio de progresso.

## Fluxo de trabalho

| Etapa | Nome | Resultado exigido |
|---|---|---|
| 1/7 | Escopo, preservação e recursos | README-alvo, natureza do repositório, instruções, estado local e recursos reais de delegação identificados. |
| 2/7 | Investigação e evidências | Fontes relevantes examinadas; investigação paralela útil delegada ou fallback direto justificado. |
| 3/7 | Compreensão do projeto | Problema, proposta, público/atores, estágio, artefatos, estrutura e relações sintetizados. |
| 4/7 | Preparação e operação | Configuração, pré-requisitos, procedimentos e validações existentes verificados quando aplicáveis. |
| 5/7 | Auditoria do README | Conteúdo, estrutura, navegação, qualidade visual e oportunidades Mermaid avaliados. |
| 6/7 | Reconciliação do README | README criado/atualizado ou ausência de mudanças materiais justificada. |
| 7/7 | Validação e entrega | README final relido, verificações pós-edição executadas e resultado apresentado. |

## Instruções das etapas

### 1/7 — Escopo, preservação e recursos

- Identifique raiz do repositório, README-alvo e escopo solicitado. Em monorepo, use o README da raiz por padrão quando o pedido for geral; selecione README de módulo quando o pedido indicar esse módulo. Pergunte somente se a ambiguidade for material e arriscada.
- Determine o tipo de repositório a partir dos artefatos observados, sem pressupor que seja uma aplicação.
- Leia instruções locais pertinentes (`AGENTS.md`, `CLAUDE.md` ou equivalentes encontrados), sem modificá-las.
- Se Git existir, verifique branch e alterações staged, unstaged ou untracked que possam afetar o README. Sem Git, preserve o estado por meios disponíveis.
- Descubra, pela sessão e pelas capacidades realmente expostas, se há subagentes delegáveis e suas permissões. Arquivos de configuração isolados não provam que a delegação está disponível.
- Não altere configurações, agentes, ferramentas, permissões ou modelos.
- **Só conclua esta etapa quando a raiz, o alvo, o estado de preservação e a capacidade real de inspeção/delegação estiverem determinados ou sua limitação registrada.**

### 2/7 — Investigação e evidências

- Examine fontes primárias adequadas ao projeto: documentação, código, dados, esquemas, contratos, manifests, configurações, scripts, especificações, históricos e exemplos.
- Use subagentes em paralelo somente para frentes independentes, úteis, permitidas e preferencialmente read-only. Dê a cada um objetivo, escopo, fontes, limites e formato de retorno com evidências.
- O agente principal coordena e confere achados nas fontes originais. Ele é o único responsável por editar o README.
- Não delegue por obrigação nem divida tarefas artificialmente. Sem agente adequado ou ganho prático, investigue diretamente e registre a razão.
- Não inicie operações destrutivas ou de efeito externo.

### 3/7 — Compreensão do projeto

Consolide, conforme aplicável:

- problema ou necessidade que motivou o projeto;
- proposta, propósito, público, consumidores ou atores;
- resultados, capacidades, limites e estágio atual;
- estrutura dos artefatos, componentes, responsabilidades e dependências;
- fluxos, relações, contratos e decisões relevantes.

Diferencie fatos observados, documentação aprovada, implementação confirmada, proposta, hipótese e informação desconhecida. Não imponha arquitetura de software a projetos de dados, documentação, pesquisa, automação, hardware, infraestrutura ou outros domínios.

### 4/7 — Preparação e operação

- Descubra, se aplicável, pré-requisitos, configurações, parâmetros, preparação, instalação, acesso, uso, reprodução, build, testes, validação, publicação ou operação.
- Confirme comandos, versões e variáveis em fontes reais antes de documentar. Nunca invente comandos ou valores.
- Documente nomes e finalidade de configurações, mas nunca exponha segredos ou valores sensíveis.
- Execute somente verificações locais seguras, não destrutivas e dentro da autorização. Não instale ferramentas, containers ou infraestrutura para completar o onboarding.
- Omita itens não aplicáveis com justificativa curta.

### 5/7 — Auditoria factual, estrutural e visual do README

Leia o README atual nesta execução e compare-o com as evidências coletadas. Avalie propósito, escopo, estágio, estrutura, relações, instruções, configurações, comandos, referências, segurança, legibilidade, hierarquia, densidade e navegação.

Avalie explicitamente se novos diagramas Mermaid agregariam clareza. Responda literalmente no resultado da auditoria:

> **O README.md do projeto pode ser melhorado com mais diagramas Mermaid para tornar mais visual, fácil de ver e entender?**

Responda **SIM** ou **NÃO** e justifique. Se SIM, identifique quais diagramas respondem a quais perguntas e incorpore os que tiverem evidência na etapa 6. Se NÃO, explique por que os diagramas existentes são suficientes ou por que novos diagramas seriam redundantes. Não adicione diagramas decorativos.

Carregue `references/checklist-readme.md` e `references/diagramas-mermaid.md` durante esta etapa.

### 6/7 — Reconciliação do README

- Crie ou atualize o README quando houver melhoria material de precisão, conteúdo, organização, navegação, segurança ou apresentação visual.
- Preserve conteúdo correto, links úteis e alterações locais conciliáveis. Não descarte mudanças locais conflitantes.
- Adapte as seções à natureza e maturidade do repositório. Use `assets/README.template.md` apenas como referência, nunca como formulário obrigatório.
- Escreva diagramas Mermaid nativos no Markdown, próximos ao conteúdo que explicam, somente quando apoiados por evidências.
- Se não houver mudança necessária, comprove a atualidade factual e a adequação visual e justifique a decisão. Não reescreva cosmeticamentе só para gerar diff.
- Não altere qualquer arquivo além do README-alvo, salvo artefatos temporários exigidos pelo próprio runtime fora do repositório. Subagentes não editam o README.

### 7/7 — Validação e entrega

Depois de editar — ou decidir justificadamente não editar — releia o README completo e execute as verificações pertinentes disponíveis:

- consistência com as fontes e distinção entre existente, proposto e desconhecido;
- links e caminhos locais;
- estrutura Markdown, código e delimitadores Mermaid;
- comandos e configurações documentados;
- ausência de segredos;
- preservação de alterações locais e escopo do diff;
- validação pós-edição adequada ao projeto.

Uma verificação executada antes da edição não substitui a validação final. Se não houver renderizador Mermaid, informe que a validação foi estática. Em seguida, emita `Etapa 7/7 concluída` e apresente o resumo.

## Critérios de conclusão

O onboarding só termina quando:

- as sete etapas foram executadas ou tiveram itens não aplicáveis justificados;
- o README foi auditado contra o estado atual do repositório;
- a pergunta Mermaid foi respondida SIM/NÃO com justificativa;
- o README foi atualizado e validado, ou a ausência de alteração material foi demonstrada;
- o escopo de escrita e a preservação foram respeitados;
- as limitações de comunicação em tempo real, delegação ou validação foram declaradas com honestidade.

Estados finais:

- `CONCLUÍDO — README atualizado`;
- `CONCLUÍDO — nenhuma alteração necessária`;
- `INCOMPLETO — README não reconciliado`;
- `SOMENTE ANÁLISE — escrita não autorizada`.

A falta de código, build, testes, Git, containers, subagentes ou renderizador não impede conclusão quando esses recursos não forem aplicáveis. A falta de auditoria atual ou de reconciliação impede declarar onboarding concluído.

## Referências sob demanda

- Comunicação após cada etapa e continuidade: [references/execucao-continua.md](references/execucao-continua.md).
- Evidências, escrita e segurança: [references/evidencias-e-seguranca.md](references/evidencias-e-seguranca.md).
- Descoberta e delegação de agentes: [references/orquestracao-multiagentes.md](references/orquestracao-multiagentes.md).
- Checklist factual, estrutural e visual: [references/checklist-readme.md](references/checklist-readme.md).
- Diretrizes e exemplos Mermaid: [references/diagramas-mermaid.md](references/diagramas-mermaid.md).
- Estágios por tipo de projeto: [references/estagios-do-projeto.md](references/estagios-do-projeto.md).
- Template de README: [assets/README.template.md](assets/README.template.md).
- Modelo de resumo final: [assets/RESUMO-ONBOARDING.template.md](assets/RESUMO-ONBOARDING.template.md).
