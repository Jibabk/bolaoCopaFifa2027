# Etapas, comunicação e critérios de conclusão

## Sete etapas de trabalho

| Etapa | Nome | Evidência mínima de conclusão |
|---|---|---|
| 1/7 | Escopo, preservação e recursos | Raiz/alvo, tipo de repositório, instruções, estado local e delegação disponível verificados. |
| 2/7 | Investigação e evidências | Fontes relevantes examinadas; delegação executada ou fallback justificado. |
| 3/7 | Compreensão do projeto | Problema, proposta, estágio, artefatos e relações sintetizados. |
| 4/7 | Preparação e operação | Configuração, pré-requisitos e procedimentos verificados quando aplicáveis. |
| 5/7 | Auditoria do README | Auditoria factual, estrutural, visual e Mermaid concluída. |
| 6/7 | Reconciliação do README | Documento atualizado ou ausência de melhoria material justificada. |
| 7/7 | Validação e entrega | README final relido e verificações pós-edição realizadas. |

## Comunicação de conclusão

Não há barra, percentuais ou mensagem inicial. Depois de concluir cada etapa, o agente informa o resultado com uma frase curta e, em seguida, continua automaticamente.

Formato recomendado:

`Etapa 3/7 concluída — propósito, estágio e principais relações identificados com base nas fontes consultadas. Próxima: verificar preparação e operação.`

A mensagem deve refletir resultado real, não plano. Não afirmar conclusão de investigação antes de ler fontes, nem conclusão de validação antes de executar as verificações.

## Evidências de conclusão

- As sete etapas foram executadas ou itens não aplicáveis foram justificados.
- O README foi relido e comparado com as evidências atuais.
- A pergunta Mermaid foi respondida SIM/NÃO e justificada.
- O README foi atualizado e validado, ou não havia melhoria material — conteúdo e visual — e isso foi demonstrado.
- Validações finais ocorreram depois da reconciliação.
- Escopo de escrita e alterações locais foram preservados.
- Limitações do runtime, delegação ou renderização foram relatadas com honestidade.

## Estados finais

| Estado | Critério |
|---|---|
| `CONCLUÍDO — README atualizado` | README criado/evoluído e verificado. |
| `CONCLUÍDO — nenhuma alteração necessária` | Auditorias completa e atual; nenhuma melhoria material; decisão fundamentada. |
| `INCOMPLETO — README não reconciliado` | Bloqueio impede atualização ou validação segura. |
| `SOMENTE ANÁLISE` | Escrita proibida por instrução explícita. |

A falta de código, build, testes, containers, Git, subagentes ou renderizador não impede conclusão quando não forem aplicáveis. A ausência de auditoria atual ou reconciliação impede declarar sucesso.
