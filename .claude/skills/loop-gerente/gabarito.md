# Gabarito de triagem do loop gerente

Classificação esperada, confirmada por Jean em 04/11/2026. O dry run do gerente é comparado com esta tabela; o modo `aplicar` só é liberado quando o gerente coincidir com ela.

Base: `openspec/changes/2026-10-18-technical-foundation/tasks.md` com as verificações registradas em 30/10/2026. Se o `tasks.md` mudar, revise a tabela antes de usar.

| Tarefa | Resumo | Risco | Tipo | Esperado | Motivo |
|---|---|---|---|---|---|
| T1 | Manter scaffold de módulos | low | backend | concluída | `- [x]`; não gera issue. |
| T2 | Validar `docker-compose.yml` | low | infra | concluída | `- [x]`; não gera issue. |
| T3 | Healthcheck e `/ready` consultando o banco | medium | backend | concluída | `- [x]`; não gera issue. |
| T4 | Inicializar Alembic | medium | backend | concluída | `- [x]`; não gera issue. |
| T5 | Specs PROD-01/TEC-01/PROD-07 | high | docs | needs:human | Tarefa é aguardar aprovação humana; fora da aprovação registrada no `proposal.md`. Risco alto porque os documentos definem corte, autenticação e identidade. |
| T6 | Ferramenta de isolamento de imports | low | infra | needs:human | Texto exige decisão humana sobre a ferramenta; fora da aprovação registrada. |
| T7 | Aplicação FastAPI e modelos Pydantic base | medium | backend | needs:human | Escopo de "modelos base" indefinido e a verificação (curl em `/live` e `/ready`) já passa sem a mudança, então não prova a entrega. |
| T8 | Build reproduzível do backend | low | infra | concluída | `- [x]`; não gera issue. |
| T9 | Build reproduzível do frontend | low | infra | concluída | `- [x]`; não gera issue. |
| T10 | Configuração por ambiente e driver de banco | medium | backend | concluída | `- [x]`; driver psycopg 3 aprovado em 30/10/2026. |
