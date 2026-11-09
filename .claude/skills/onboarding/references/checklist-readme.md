# Checklist de README para onboarding

O README é um guia de entrada conciso, não uma cópia de toda a documentação do projeto. Avalie os itens abaixo conforme o estágio e a natureza do repositório.

## Conteúdo mínimo recomendado

- [ ] **Sobre o projeto:** problema que resolve, público/contexto e proposta de solução.
- [ ] **Arquitetura:** componentes principais, responsabilidades e fluxo; incluir diagrama Mermaid renderizável quando houver evidência suficiente.
- [ ] **Tecnologias:** linguagens, frameworks, serviços e ferramentas relevantes, distinguindo definidas de planejadas.
- [ ] **Pré-requisitos:** ferramentas e versões necessárias, quando conhecidas.
- [ ] **Ambiente local:** passos para preparar e iniciar; informar se há execução por containers ou execução direta.
- [ ] **Configuração:** variáveis de ambiente, finalidade, obrigatoriedade e exemplo seguro; nunca valores secretos.
- [ ] **Build e execução:** comandos exatos e resultados esperados, quando existentes.
- [ ] **Testes:** como executar os testes disponíveis e quais categorias existem.
- [ ] **Estrutura do projeto:** diretórios/módulos importantes, sem listar cada arquivo.
- [ ] **Documentação complementar:** links para requisitos, decisões, arquitetura detalhada ou guias específicos.

## Qualidade das instruções

- Os comandos foram confirmados em scripts, manifests, documentação ou execução?
- Os passos funcionam a partir de um clone limpo, conforme as condições documentadas?
- As variáveis de ambiente têm explicação sem expor segredos?
- Os diagramas são Mermaid válido, renderizável e coerente com as fontes?
- Está claro o que é arquitetura implementada e o que é proposta?
- O README evita repetir documentos especializados?
- As lacunas e decisões pendentes estão explicitadas?

## Adaptação ao estágio

### Repositório sem código
Documente problema, proposta, escopo, arquitetura proposta, tecnologias decididas e pendências. Build, execução, testes, portas e variáveis ainda não definidos devem aparecer como “a definir” ou ser omitidos com indicação clara de que ainda não se aplicam.

### Repositório com código
Inclua comandos verificados de configuração, build, execução e testes. Descreva variáveis e serviços requeridos. Não invente passos nem assuma que containers são usados.

## Resultado da análise

Classifique cada item como:
- **Atendido:** informação suficiente e sustentada por fonte.
- **Parcial:** existe informação, mas faltam detalhes.
- **Ausente:** não foi encontrada informação.
- **Não aplicável:** não faz sentido no estágio atual.

Ao sugerir uma revisão, mostre as lacunas e a proposta. Só grave no repositório após autorização.
