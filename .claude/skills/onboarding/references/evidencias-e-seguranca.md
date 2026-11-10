# Evidências, escrita e segurança

## Tipos de evidência

- **Documentado:** declarado em README, especificação, decisão, manual, contrato ou outro documento; registre caminho e seção.
- **Observado:** confirmado diretamente em artefatos do repositório, estrutura, conteúdo, metadados ou configuração.
- **Executado:** procedimento ou comando realmente executado; registre comando, escopo e resultado.
- **Planejado:** intenção ou decisão futura registrada, mas não comprovada como existente.
- **Inferido:** interpretação ainda não confirmada; não apresente como fato.
- **Desconhecido:** não há evidência suficiente.

Não trate o próprio README como prova de que suas afirmações estão corretas. Quando fontes divergirem, registre a divergência e evite resolver por suposição ou votação de subagentes.

## Neutralidade tecnológica

- Não presuma linguagem, runtime, arquitetura, hospedagem, ambiente, sistema de arquivos, gerenciador de pacotes, CI ou ferramenta de versionamento.
- Não imponha convenções típicas de uma aplicação quando o repositório for de dados, documentação, pesquisa, infraestrutura, automação, firmware ou outro tipo.
- Detecte tecnologias e ferramentas pelo que existe; registre somente o que for relevante para compreender e utilizar o projeto.
- Não recomende adicionar ferramentas ou processos só para preencher o README.

## Autorização de escrita

A solicitação de onboarding autoriza criar ou atualizar somente o README do escopo definido, salvo restrição explícita do usuário.

Não abrange código, testes, dados, arquivos de dependência, parâmetros, configuração, infraestrutura, ferramentas, agentes, permissões, outros documentos ou serviços.

## Preservação

- Comece com inspeção somente leitura.
- Se houver Git, inspecione status e diffs staged/unstaged do README-alvo.
- Se Git não existir, use mecanismos disponíveis para preservar o conteúdo atual.
- Preserve alterações locais que possam ser conciliadas com segurança.
- Em conflito ou risco de perda, não sobrescreva; registre o bloqueio.
- Não execute comandos destrutivos de limpeza, restauração ou descarte para facilitar a escrita.
- Revise o diff final e confirme o limite de escrita.

## Subagentes e configurações

- Descubra somente mecanismos e agentes acessíveis no runtime atual.
- Prefira tarefas independentes, read-only e delimitadas.
- Não crie ou modifique agentes, permissões, modelos ou configurações.
- Não compartilhe valores secretos nos contextos delegados.
- O agente principal é o único responsável por editar o README e validar as afirmações finais.
- Resultado de subagente é indício qualificado, não prova automática.
- Ausência de subagentes não bloqueia: prossiga sequencialmente.

## Execução de comandos e procedimentos

- Inspecione comandos e scripts antes de executá-los.
- Não presuma que uma operação de leitura seja sempre sem efeitos; observe o contexto e os parâmetros.
- Não execute deploy, publicação, provisionamento, migração compartilhada, exclusão, limpeza, envio externo ou operação privilegiada sem autorização específica.
- Considere impacto em serviços, dados, custos, rede, recursos físicos e ambientes externos.
- Se a validação for arriscada ou não aplicável, documente o procedimento encontrado sem executá-lo.

## Segredos e dados sensíveis

- Nunca copie ou imprima senhas, tokens, chaves, certificados privados, credenciais ou valores secretos.
- Não registre dados pessoais ou dados operacionais confidenciais no README.
- Documente apenas nomes e finalidade de parâmetros quando puderem ser confirmados com segurança.
- Use exemplos fictícios, não funcionais e claramente identificados como ilustrativos.
- Não crie arquivo de configuração de exemplo como parte do onboarding, pois o escopo de escrita é somente o README.

## Reconciliação obrigatória

Em toda execução, confronte o README atual com a análise atual, mesmo que tenha sido atualizado antes. Se houver melhoria, atualize. Se não houver, justifique a decisão factual e visual. Se a avaliação for impedida, declare bloqueio; não declare conclusão.

## Comunicação contínua

Depois de executar e verificar cada uma das sete etapas, informe brevemente o resultado e continue imediatamente a etapa seguinte. Não use barra de progresso, não envie mensagem inicial antes de agir e não peça “prossiga” ou autorização intermediária. Respeite aprovações externas obrigatórias do runtime e não contorne mecanismos de segurança. Consulte [execucao-continua.md](execucao-continua.md).
