# Saúde e prontidão

O operador (ou o healthcheck do Compose) consulta se cada serviço está vivo e se a API está pronta para atender, o que exige banco. `/live` independe do banco. `/ready` responde 503 sem detalhes de erro quando o banco cai e volta a 200 quando ele retorna.

## Sub-features

- `live`: `GET /live` no backend → 200 `{"status":"ok","service":"bolao-backend"}`.
- `ready-ok`: `GET /ready` com o banco no ar → 200 `{"status":"ready"}`.
- `ready-sem-banco`: com o banco parado → 503 `{"status":"unavailable"}`, sem vazar a mensagem do driver. O `/live` continua 200.
- `ready-recupera`: depois que o banco volta → 200 de novo, sem reiniciar o backend.
- `fe-health`: `GET /api/health` no frontend → 200 `{"status":"ok","service":"bolao-frontend"}`.

## How to get to it (user POV)

- Link "Healthcheck" da página inicial (aponta para `/live` na porta padrão).
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
- **Sem reinício.** Antes do `stop db` e depois do 200 final, rode `docker inspect -f '{{.State.StartedAt}}' "$($H compose "$RUN_ID" ps -q backend)" | tee -a $E/sem-reinicio.txt`. As duas linhas são idênticas. Não use `{{.RunningFor}}`: ele conta desde a criação do container e não muda num restart (medido na run `maintain-2`).
- **Prova.** O `requests.log` contém, nesta ordem (podendo haver outras linhas entre elas, como 503 de novas tentativas): ready 200 → ready 503 → live 200 → ready 200. Cada linha traz só hora, URL e status, sem o nome da evidência, então compare pelo caminho e pelo status. `$H logs "$RUN_ID"` grava no `compose.log` as linhas do Postgres `database system is shut down` e `database system is ready to accept connections`. Os eventos de stop/start do Compose não entram no log.

## Gotchas

- Não deixe o banco parado: o `doctor` e as outras funcionalidades falham. Sempre rode `start db` no fim.
- O `/ready` usa `connect_timeout` de 3 s, mas com o banco parado a resposta 503 levou 4,0 s na run `maintain-2`, tanto por `$H get` quanto por `curl` direto. O `$H get` não define timeout. Num `curl` avulso, use `--max-time` de pelo menos 10 s para não ter falso negativo.
- Logo depois do `start db`, o Postgres pode recusar conexões por alguns segundos. Repita o GET em vez de concluir que houve regressão.
- O `/ready` nunca deve expor a causa do erro (host, senha, driver). Um corpo diferente de `{"status":"unavailable"}` é falha de segurança, não só de forma.
- Sem `DATABASE_URL` o `/ready` também devolve 503. A pilha da run sempre define a variável, então esse caso fica coberto só por `backend/tests/integration/test_ready.py`.
