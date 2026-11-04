---
name: testes
description: Cria e executa os testes da mudança implementada. Obrigatória após qualquer implementação, antes da skill verificacao e de qualquer PR. Use também quando o usuário pedir "testes", "/testes" ou cobertura de uma mudança.
---

# Testes

Obrigatória após qualquer implementação, dentro ou fora do loop, e sempre antes da skill `verificacao`.

## Regras

- Todo comportamento novo ou alterado em `backend/app/` tem teste em `backend/tests/` na mesma mudança. Correção de defeito tem teste de regressão que falharia sem a correção.
- Camadas: `unit/` para domínio e regras puras; `integration/` para banco, Alembic e infraestrutura; `api/` para rotas FastAPI com `TestClient`; `contract/` só quando houver contrato aprovado entre frontend e backend.
- Regras críticas (pontuação 6/3/2/1/0, corte 1 h antes do kickoff oficial vigente, BRT, desempates, mata-mata aos 120 min, ocultação de palpites alheios, autorização) exigem testes unitários com a tabela completa de casos e as fronteiras, como exatamente no corte e imediatamente antes. O esperado vem do requisito canônico, nunca do código.
- Cenários derivam do requisito, da spec ou da tarefa (GIVEN/WHEN/THEN) e citam a origem (HU-xx, PROD-xx, `<change>` T<n>) no nome ou na docstring.
- Testes que precisam de PostgreSQL usam `skipif` sem `DATABASE_URL`, como em `tests/integration/test_ready.py`. Todo pulo aparece no relatório e é citado no PR.
- Não adicionar dependências nem frameworks de teste. O frontend ainda não tem ferramenta de testes escolhida (decisão humana pendente): não criar testes de frontend; registrar a lacuna e contar com lint e type-check.
- Mudança sem comportamento testável (docs, configuração já validada por comando, scaffold) não ganha teste artificial: o commit leva o trailer `Sem-Teste: <motivo>`, aceito pelo `scripts/verificar.sh`.
- Nunca afrouxar, pular ou apagar teste existente para a mudança passar. Teste existente que conflita com o requisito é escalado ao humano.

## Procedimento

1. Listar os comportamentos alterados a partir de `git diff origin/main` e da tarefa de origem.
2. Delegar ao `software-tester` com: requisito ou tarefa de origem, comportamentos, arquivos alterados e as regras acima. Ele escreve os testes e não altera código de produção.
3. Executar: `cd backend && .venv/bin/pytest -q -rs`.
4. Falha por defeito na implementação: devolver ao especialista da área. Falha por teste errado: corrigir o teste e justificar. No máximo 2 ciclos; depois escalar.
5. Entregar: testes criados (`arquivo::teste` → cenário e origem), comando executado com o resultado real, pulos e lacunas.
