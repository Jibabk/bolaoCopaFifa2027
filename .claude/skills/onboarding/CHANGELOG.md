# Changelog — Onboarding Skill

## 1.9.0

- Removida a barra de progresso, os percentuais, a contagem regressiva e a mensagem inicial de status: esses elementos estavam desviando a atenção da execução e foram associados a encerramentos prematuros.
- Substituídas as nove microetapas por sete fases de trabalho mais significativas, mantendo a cobertura do onboarding.
- Introduzidos checkpoints curtos somente após a conclusão verificada de cada fase.
- Tornado explícito que um checkpoint não é uma resposta final: o agente deve iniciar imediatamente a próxima fase no mesmo fluxo, sem aguardar nova mensagem do usuário.
- Determinado que a primeira ação após ativação seja inspecionar o workspace; carregar a Skill, planejar ou anunciar início não conclui trabalho.
- Atualizados checklist, modelo de resumo e suíte de avaliação para detectar a falha de parar após o primeiro checkpoint.
- Preservados o README como artefato central, a independência tecnológica, a avaliação Mermaid, a delegação read-only e a validação pós-edição.

## 1.8.0

- Reestruturado `SKILL.md` para instruções centrais concisas e referências sob demanda, seguindo a divulgação progressiva do padrão Agent Skills.
- Melhorada a descrição para ativação e incluída suíte inicial de avaliações positivas, negativas e de borda.
- Documentado o limite do formato: Agent Skills não padroniza uma API universal de streaming.

## 1.7.0

- Execução automática e contínua pelas nove etapas, sem pedir continuação entre etapas.
- Progresso com início em 0/9 e comunicação recorrente.
- Independência em relação a tecnologias, domínios e tipos de repositório.
- Avaliação visual obrigatória e pergunta justificada sobre novos diagramas Mermaid.

## 1.6.0

- Descoberta da ferramenta de IA e recursos de subagentes.
- Delegação paralela segura e fallback sequencial.
- Agente principal como orquestrador e único escritor do README.

## 1.5.0

- Progresso visível e reconciliação obrigatória do README em toda execução.

## 1.4.0

- README como entrega central do onboarding; criação ou evolução padrão.

## 1.3.0

- README como principal porta de entrada e suporte a projetos sem código executável.

## 1.2.0

- Suporte a repositórios documentais e estágios de maturidade distintos.

## 1.1.0

- Independência de outros componentes do Harness.

## 1.0.0

- Versão inicial.
