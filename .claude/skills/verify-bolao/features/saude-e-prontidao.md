# Saúde e prontidão

O operador (ou o healthcheck do Compose) consulta se cada serviço está vivo e se a API está pronta para atender, o que exige banco. `/live` independe do banco. `/ready` responde 503 sem detalhes de erro quando o banco cai e volta a 200 quando ele retorna.

## Sub-features

- `live`: `GET /live` no backend → 200 `{"status":"ok","service":"bolao-backend"}`.
- `ready-ok`: `GET /ready` com o banco no ar → 200 `{"status":"ready"}`.
- `ready-sem-banco`: com o banco parado → 503 `{"status":"unavailable"}`, sem vazar a mensagem do driver. O `/live` continua 200.
- `ready-recupera`: depois que o banco volta → 200 de novo, sem reiniciar o backend.
- `fe-health`: `GET /api/health` no frontend → 200 `{"status":"ok","service":"bolao-frontend"}`.

## How to get to it (user POV)

- Links "Healthcheck" da página inicial (apontam para `/live` na porta padrão).
- Operador chamando `/live`, `/ready` e `/api/health` diretamente.
- Healthchecks do `docker-compose.yml`, que usam `/live` no backend e `/api/health` no frontend.

## Driving it with verify-bolao

Preconditions:

- `DOCTOR OK` para `$RUN_ID`, com `E=.git/verify-bolao/$RUN_ID/evidence`.

- **Vivo.** Rode `$H get "$RUN_ID" backend /live live`. Imprime `-> 200`, e `cat $E/live.body` mostra `"service":"bolao-backend"`.
- **Pronto.** Rode `$H get "$RUN_ID" backend /ready ready-ok`. Imprime `-> 200`, e o corpo é `{"status":"ready"}`.
- **Banco cai.** Rode `$H compose "$RUN_ID" stop db`, depois `$H get "$RUN_ID" backend /ready ready-db-parado`. Imprime `-> 503`, e o corpo é exatamente `{"status":"unavailable"}`.
- **Vivo sem banco.** Rode `$H get "$RUN_ID" backend /live live-db-parado`. Imprime `-> 200`.
- **Banco volta.** Rode `$H compose "$RUN_ID" start db`. Repita `$H get "$RUN_ID" backend /ready ready-db-voltou` até `-> 200` (normalmente menos de 10 s). O corpo é `{"status":"ready"}`.
- **Frontend.** Rode `$H get "$RUN_ID" frontend /api/health fe-health`. Imprime `-> 200`, com `"service":"bolao-frontend"`.
- **Prova.** O `requests.log` mostra, em ordem: ready 200 → ready 503 → live 200 → ready 200. Também vale `$H logs "$RUN_ID"`, que mostra o stop/start do `db` no `compose.log`.

## Gotchas

- Não deixe o banco parado: o `doctor` e as outras funcionalidades falham. Sempre rode `start db` no fim.
- O `/ready` usa `connect_timeout` de 3 s. Com o banco parado, a resposta 503 pode levar até cerca de 3 s, e um timeout do curl abaixo disso daria falso negativo.
- Logo depois do `start db`, o Postgres pode recusar conexões por alguns segundos. Repita o GET em vez de concluir que houve regressão.
- O `/ready` nunca deve expor a causa do erro (host, senha, driver). Um corpo diferente de `{"status":"unavailable"}` é falha de segurança, não só de forma.
