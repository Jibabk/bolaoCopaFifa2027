# Estágios do projeto — classificação adaptável

A classificação descreve o estado observado do projeto no momento do onboarding. Não é uma avaliação de qualidade nem pressupõe um ciclo de vida de software.

## Categorias de referência

- **Ideia ou especificação:** propósito, necessidade ou requisitos estão sendo definidos; entregáveis ainda são predominantemente conceituais.
- **Preparação ou protótipo:** estrutura inicial, prova de conceito, amostra ou experimento já existe, mas a solução ainda está em validação.
- **Em desenvolvimento:** os artefatos principais estão sendo construídos ou evoluídos.
- **Em uso ou operação:** o projeto já produz resultados ou é utilizado no contexto previsto.
- **Manutenção ou evolução:** o foco está em corrigir, atualizar, preservar ou ampliar algo já existente.
- **Híbrido:** partes do projeto estão em estágios diferentes.
- **Indeterminado:** as evidências disponíveis não permitem uma classificação confiável.

Use os rótulos como referência. Projetos de pesquisa, conteúdo, hardware, dados ou infraestrutura podem exigir descrições mais adequadas ao seu ciclo real.

## Adaptação por tipo de repositório

| Natureza observada | O que pode ser relevante | O que não presumir |
|---|---|---|
| Aplicação, serviço ou site | Capacidades, interfaces, componentes, execução, operação | Framework, banco, API ou arquitetura específica |
| Biblioteca ou pacote | Público consumidor, interface, compatibilidade, integração e exemplos de uso | Aplicação executável ou interface visual |
| Dados ou pesquisa | Fontes, formatos, metodologia, transformações, reprodutibilidade | Banco de dados, pipeline ou testes automatizados |
| Infraestrutura ou configuração | Recursos, relações, parâmetros, dependências e procedimentos | Permissão para provisionar ou alterar ambientes |
| Automação ou scripts | Entradas, saídas, pré-condições, efeitos e agendamento existente | Execução segura sem inspeção |
| Documentação ou especificação | Objetivo, público, organização, decisões e artefatos | Código ou build |
| Firmware/hardware/projeto físico | Componentes, interfaces, montagem, operação e validação documentadas | Procedimentos físicos ou de segurança não documentados |

## Como documentar o estágio

- Diferencie o que existe do que está planejado.
- Use evidências: arquivos, documentos, metadados, resultados de execução ou validação.
- Em projeto híbrido, classifique partes relevantes separadamente.
- Quando houver lacuna, registre-a como desconhecida; não invente status.
- Adapte as seções do README ao estágio, sem preencher itens não aplicáveis.
