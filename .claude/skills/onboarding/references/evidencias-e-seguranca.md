# Evidências, comandos e segurança

## Tipos de evidência

- **Documentado:** consta em README, especificação, ADR ou outro documento; indique caminho e seção.
- **Observado:** confirmado em código, manifest, script ou configuração.
- **Executado:** comando foi realmente executado; registre comando e resultado.
- **Inferido:** interpretação ainda não confirmada.
- **Desconhecido:** não há evidência suficiente.
- **Planejado:** consta como decisão/proposta para implementação futura.

Não trate documentação como prova de implementação. Quando fontes divergirem, exponha a divergência.

## Execução segura

- Comece com inspeção somente leitura.
- Verifique `git status --short --branch` antes de ações que possam alterar arquivos.
- Não sobrescreva alterações locais.
- Inspecione scripts e comandos antes de executá-los.
- Não instale ou atualize ferramentas sem autorização.
- Não execute deploy, publicação, migrations em ambientes compartilhados, operações destrutivas ou comandos privilegiados.
- Não imprima valores de `.env`, tokens, senhas, chaves ou certificados.
- Avalie efeitos sobre containers, volumes, bancos, rede, credenciais, serviços externos e custos.
- Solicite autorização específica para ações com efeitos colaterais relevantes; uma autorização não se estende automaticamente a outras ações.
- Não crie ou modifique README sem pedido ou autorização explícita.

## Containers

Se houver configuração de container no projeto, explique os comandos existentes e o que eles fazem. Antes de iniciar ou recriar serviços, avalie volumes, portas, dependências e risco de afetar recursos já existentes. Não presuma que `down`, `prune`, remoção de volumes ou rebuild são seguros.

## Variáveis de ambiente

Documente nomes e finalidades a partir de fontes. Não copie valores reais de arquivos locais. Se não for possível determinar se uma variável é obrigatória, marque como pendente. Nunca invente um `.env.example`.
