# Execução contínua e comunicação por etapas

## Princípio

A prioridade é executar o onboarding. A comunicação serve para informar resultados reais, não para substituir o trabalho nem criar uma cerimônia de progresso.

A versão 1.9.0 remove a barra de progresso, percentuais, contagem regressiva e mensagem inicial de status. O agente informa o usuário **depois que cada etapa foi realmente concluída e verificada**.

## Sequência operacional obrigatória

1. Após carregar a Skill, comece imediatamente com ações reais de inspeção do workspace. Não envie somente uma mensagem de início, um plano, uma barra ou uma confirmação.
2. Execute integralmente a etapa atual e reúna evidências suficientes para marcá-la como concluída.
3. Emita um checkpoint curto, por exemplo:

   > Etapa 1/7 concluída — README-alvo e estado local identificados; alterações preexistentes preservadas. Próxima: investigar as fontes do projeto.

4. **Continue imediatamente a próxima etapa no mesmo fluxo de execução.** O checkpoint não é uma resposta final, não é uma pausa e não pede interação do usuário. Logo após emiti-lo, faça a próxima chamada de ferramenta ou continue a análise substantiva.
5. Repita até a etapa 7. Só então apresente o resumo final.

## Regras que evitam o problema observado

- Não envie mensagem de progresso antes da primeira ação real.
- Não use barra, percentuais, contagem ou expressões como `0/7`, `1/7`, `100%`.
- Não anuncie a etapa como concluída apenas porque a Skill foi carregada, um plano foi criado ou uma lista de arquivos foi exibida.
- Não termine o turno, não retorne uma resposta final e não aguarde o usuário depois de um checkpoint enquanto houver etapas pendentes.
- Não gere todos os checkpoints de uma só vez, nem os reconstrua no resumo final.
- Não emita um checkpoint sem resultado verificável. Seja conciso: uma frase de resultado e a próxima atividade.
- Não faça atualizações repetitivas durante uma etapa apenas para parecer ativo. Se uma operação longa exigir comunicação, use os mecanismos de status nativos reais do cliente, quando disponíveis, e relate somente fatos observados.
- Não pergunte `prossiga`, não peça autorização entre etapas que já estão dentro do escopo autorizado.

## Exemplo correto: evento intercalado com execução

A sequência abaixo é ilustrativa. Cada checkpoint ocorre somente depois das operações da etapa correspondente e é seguido por trabalho real na etapa seguinte; não é um bloco para copiar inteiro numa resposta.

```text
[O agente inspeciona raiz, README, instruções locais e estado do repositório.]

Etapa 1/7 concluída — README-alvo identificado, alterações locais preservadas e recursos de delegação verificados. Próxima: investigar as fontes do projeto.
[O agente lê documentação, examina artefatos e inicia as delegações read-only pertinentes.]

Etapa 2/7 concluída — documentação canônica e artefatos principais examinados; achados dos agentes conferidos. Próxima: consolidar problema, proposta e estrutura.
[O agente sintetiza o entendimento, consulta os artefatos necessários e verifica configuração/uso.]

...

Etapa 6/7 concluída — README atualizado com os ajustes justificados. Próxima: reler e validar o documento final.
[O agente relê o README após a edição e executa as verificações finais.]

Etapa 7/7 concluída — README relido e validações finais concluídas. Estado: CONCLUÍDO — README atualizado.
[Resumo final com alterações, decisão Mermaid, evidências e limitações.]
```

## Se o agente parar após o checkpoint

É uma falha de execução. A mensagem de checkpoint não encerra a tarefa. A execução deve retomar da próxima etapa não concluída, sem reiniciar etapas já verificadas, e prosseguir até a entrega. Não peça ao usuário que repita o pedido.

## Limite do runtime

O formato Agent Skills especifica instruções e recursos, mas não define uma API universal de mensagens intermediárias. Se o cliente agrupar a saída ou não disponibilizar mensagens no meio da execução, o agente deve continuar o trabalho sem fingir comunicação em tempo real. No resultado final, informe que os checkpoints foram agrupados pelo runtime. Não tente contornar controles externos.
