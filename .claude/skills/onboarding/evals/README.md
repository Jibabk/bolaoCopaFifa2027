# Avaliações da Skill `onboarding`

Esta suíte verifica ativação, execução real das sete etapas, continuidade após checkpoints, neutralidade tecnológica, reconciliação do README, qualidade Mermaid e limites do runtime.

## Como executar

1. Instale a Skill em um cliente compatível com Agent Skills.
2. Prepare um repositório de teste correspondente a cada cenário.
3. Execute cada prompt em contexto limpo e registre trace/eventos, saída, duração e tokens quando disponíveis.
4. Avalie cada assertion como PASS/FAIL, com evidência do trace ou dos arquivos resultantes.
5. Compare a versão atual com a anterior usando os mesmos prompts e condições.

## Critério crítico de continuidade

Não basta encontrar mensagens `Etapa X/7 concluída` no texto final. Inspecione o trace do cliente e confirme que:

- houve uma operação real antes do checkpoint da etapa 1;
- cada checkpoint surgiu depois do resultado correspondente;
- após cada checkpoint o agente continuou a próxima etapa no mesmo fluxo, sem aguardar novo turno do usuário;
- não houve barra, percentuais ou mensagens retrospectivas.

## Cobertura

- Casos 1–5: ativação, projetos não tradicionais, ausência de README e README já adequado.
- Casos 6 e 10–16: falsos positivos próximos e tarefas fora do escopo.
- Casos 7–9: somente análise, runtime sem streaming e subagentes sem invocação habilitada.
- Caso 17: regressão específica para a falha observada de parar depois do primeiro status.

## Limitações

Os casos estão definidos, mas precisam ser executados em cada cliente-alvo (por exemplo, Claude Code e OpenCode). A validação estática dos arquivos não comprova que o runtime entrega checkpoints intermediários. O formato Agent Skills não define uma API universal de streaming.
