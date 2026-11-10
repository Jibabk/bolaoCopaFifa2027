# Checklist de auditoria factual, estrutural e visual do README

Use este checklist em toda execução. Marque como não aplicável somente depois de verificar a natureza e o estágio do projeto.

## 1. Escopo e identidade

- [ ] README correto para o escopo (raiz, módulo, pacote ou projeto) foi identificado.
- [ ] Nome, resumo e finalidade correspondem ao conteúdo atual do repositório.
- [ ] O público/usuário/consumidor, quando identificável, está descrito.
- [ ] O README não mistura informações de projetos ou módulos independentes.

## 2. Problema, proposta e estado

- [ ] Problema ou necessidade está explicado com base em fontes.
- [ ] Proposta, objetivo, resultado e limites estão claros.
- [ ] Capacidades/entregáveis atuais estão separados do que é planejado.
- [ ] Estágio do projeto está descrito de forma compatível com as evidências.
- [ ] Incertezas, dependências e decisões pendentes importantes estão explícitas.

## 3. Estrutura e relações

- [ ] Organização do repositório e artefatos relevantes estão explicados.
- [ ] Componentes, papéis, interfaces, dependências e relações importantes estão descritos, se aplicáveis.
- [ ] Fluxos principais estão explicados quando necessários para começar.
- [ ] Relações e nomes usados no README correspondem às fontes atuais.
- [ ] Arquitetura/estrutura existente está separada de proposta ou planejamento.

## 4. Preparação e uso

- [ ] Pré-requisitos estão confirmados e adequados ao projeto.
- [ ] Configurações/parâmetros estão identificados por nome e finalidade, sem valores secretos.
- [ ] Procedimentos de preparação e uso são reproduzíveis ou claramente identificados como pendentes.
- [ ] Comandos foram encontrados em fontes reais e inspecionados antes de execução.
- [ ] Build, execução, instalação, validação, testes ou operação estão incluídos somente quando aplicáveis.
- [ ] Procedimentos de manutenção, atualização ou contribuição estão documentados quando úteis.
- [ ] Não foram introduzidos requisitos tecnológicos, ferramentas ou containers artificiais.

## 5. Navegação e documentação complementar

- [ ] Links relativos apontam para documentos e caminhos existentes.
- [ ] O README é uma porta de entrada, não uma cópia indiscriminada de toda a documentação.
- [ ] Referências adicionais ajudam a encontrar detalhes, decisões, especificações e procedimentos.
- [ ] Seções vazias, exemplos genéricos e instruções obsoletas foram removidos.

## 6. Auditoria visual — obrigatória

- [ ] Hierarquia e ordem dos títulos ajudam a localizar informação.
- [ ] Resumo inicial é direto e não exige ler longos blocos para compreender o propósito.
- [ ] Parágrafos longos foram avaliados para síntese, listas, tabelas ou diagramas.
- [ ] Tabelas são usadas para comparações ou dados tabulares, não para textos extensos.
- [ ] Arquitetura/estrutura principal pode ser compreendida visualmente, quando isso ajuda.
- [ ] Fluxos, sequências, dependências, etapas ou relações relevantes foram avaliados para Mermaid.
- [ ] Diagramas existentes continuam corretos, legíveis e úteis.
- [ ] Diagramas estão próximos do texto que explicam e não são redundantes.
- [ ] Diagramas usam nomes reais, relações fundamentadas e rótulos adequados para o estágio.
- [ ] README é navegável em telas menores e não depende exclusivamente de cores ou imagens externas.

## 7. Pergunta final obrigatória sobre Mermaid

Responda explicitamente:

> **O README.md do projeto pode ser melhorado com mais diagramas Mermaid para tornar mais visual, fácil de ver e entender?**

- [ ] Resposta **SIM** ou **NÃO** registrada.
- [ ] Se SIM, oportunidades identificadas por pergunta que o diagrama responderá.
- [ ] Se SIM, as fontes de cada elemento/relação foram identificadas e os diagramas úteis foram criados ou ajustados no README.
- [ ] Se NÃO, justificativa específica explica por que novos diagramas não trariam ganho material.
- [ ] Não foram criados diagramas apenas para aumentar quantidade.

## 8. Qualidade e validação Mermaid

- [ ] Cada diagrama responde a uma pergunta concreta.
- [ ] Tipo escolhido é adequado à relação apresentada.
- [ ] Nós, relações, direção e rótulos têm evidência.
- [ ] Diagramas são pequenos o bastante para leitura e divididos quando necessário.
- [ ] Delimitadores ` ```mermaid ` estão corretos e fechados.
- [ ] Sintaxe foi revisada estaticamente.
- [ ] Se havia renderizador já disponível, foi utilizado; se não, foi declarada a revisão estática.
- [ ] Não foi instalado software apenas para validar Mermaid.

## 9. Segurança e preservação

- [ ] Não há token, senha, chave, certificado, dado pessoal ou segredo no README.
- [ ] Variáveis e parâmetros estão documentados sem valores sensíveis.
- [ ] Comandos com efeitos foram inspecionados antes da execução.
- [ ] Não houve instalação, publicação, deploy, provisionamento ou alteração operacional não autorizada.
- [ ] Alterações staged, unstaged ou untracked preexistentes foram preservadas.
- [ ] O diff final está limitado ao README-alvo, salvo arquivos criados pelo próprio runtime fora do repositório.

## 10. Multiagentes e comunicação por etapas

- [ ] Ferramenta de IA e mecanismos de delegação foram identificados pela sessão real.
- [ ] Agentes foram verificados quanto à disponibilidade, adequação e permissão.
- [ ] Frentes paralelas eram independentes e read-only.
- [ ] Retornos foram verificados pelo orquestrador nas fontes originais.
- [ ] Se não houve delegação, a razão foi registrada e a análise prosseguiu sequencialmente.
- [ ] Cada checkpoint foi emitido somente depois da etapa correspondente ter sido executada e verificada.
- [ ] O checkpoint foi seguido imediatamente pela próxima ação no mesmo fluxo; não houve pausa para pedir “prossiga”.
- [ ] Não foram usadas barras, percentuais ou mensagens iniciais que substituíssem a execução.

## Decisão obrigatória

Escolha e registre uma decisão:

- **ATUALIZAR:** existe melhoria factual, estrutural, de navegação, segurança ou visual material. Atualize e valide o README.
- **SEM ALTERAÇÃO NECESSÁRIA:** auditoria completa demonstra que o documento está correto e visualmente adequado. Justifique as dimensões factual e visual e responda NÃO à pergunta sobre novos Mermaid.
- **BLOQUEADO:** escopo, evidência, conflito ou permissão impede decidir com segurança. Não declare conclusão.
- **SOMENTE ANÁLISE:** o usuário proibiu escrita; respeite a instrução e informe que a reconciliação não foi feita.

A indisponibilidade de subagentes ou de ferramentas de renderização não impede o onboarding. A falta de auditoria atual e de reconciliação do README impede declarar conclusão.
