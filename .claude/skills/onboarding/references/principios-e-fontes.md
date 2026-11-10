# Princípios e fontes

## Princípios

- README é a entrega persistente do onboarding.
- Toda execução compara o README com as evidências atuais.
- A execução deve continuar automaticamente pelas sete etapas; checkpoints após etapas concluídas informam resultados, mas nunca são pontos de parada. A barra de progresso foi removida para priorizar execução.
- A Skill é agnóstica a tecnologias e tipos de repositório; adapta o processo ao que existe.
- Não existe estrutura de README universal: conteúdo é selecionado por relevância e evidência.
- Auditorias factual e visual são obrigatórias.
- A pergunta sobre novos diagramas Mermaid recebe resposta explícita e justificada.
- Mermaid deve explicar relações reais, não decorar o documento.
- Documentado, observado, executado, planejado, inferido e desconhecido são estados diferentes.
- Orquestrador verifica resultados delegados e é o único escritor do README.
- A ausência de subagentes, build, containers ou testes não bloqueia projetos nos quais esses recursos não se aplicam.
- A escrita é restrita ao README autorizado; todo o restante do repositório permanece preservado.

## Escolha de fontes

Não há hierarquia universal para todos os tipos de projeto. Escolha as fontes mais adequadas à afirmação:

- **Propósito e necessidade:** objetivos, requisitos, problema, contexto, brief ou documentação de origem.
- **Decisões e proposta:** decisões aprovadas, especificações, desenhos, modelos ou registros do projeto.
- **Estrutura e relações:** arquivos, diretórios, conteúdo, código, esquemas, dados de exemplo, diagramas e configurações.
- **Parâmetros e ferramentas:** metadados e arquivos de configuração relevantes, sem divulgar valores secretos.
- **Procedimentos de uso:** scripts, instruções, manuais, automações e resultados de execução quando seguros.
- **Estado atual:** artefatos existentes, histórico disponível e validação observada.
- **Atualidade do README:** comparação direta entre o conteúdo do README e as evidências atuais na execução presente.

Quando duas fontes relevantes divergirem, registre a divergência, verifique a origem e evite resolver silenciosamente.

## Referências gerais

- Markdown Guide: https://www.markdownguide.org/basic-syntax/
- Mermaid — documentação: https://mermaid.js.org/intro/
- Mermaid — flowcharts: https://mermaid.js.org/syntax/flowchart.html
- Mermaid — sequence diagrams: https://mermaid.js.org/syntax/sequenceDiagram.html
- Git documentation (somente se Git estiver presente): https://git-scm.com/docs

Essas referências apoiam formatos e práticas gerais. Não significam que a Skill deva impor Git, uma plataforma de hospedagem, linguagem, ferramenta ou arquitetura.

## Exemplos de ferramenta de IA (não obrigatórios)

Algumas ferramentas possuem configurações e mecanismos próprios de subagentes. Claude Code e OpenCode são exemplos, não dependências. A Skill deve consultar os mecanismos e a documentação da ferramenta efetivamente detectada, na versão em uso, e jamais extrapolar nomes, diretórios, permissões ou semânticas de um produto para outro.

- Claude Code — Subagents: https://code.claude.com/docs/en/sub-agents
- Claude Code — Agent teams: https://code.claude.com/docs/en/agent-teams
- OpenCode — Agents: https://opencode.ai/docs/agents
