# API e documentação

O desenvolvedor que consome a API encontra a mensagem de boas-vindas na raiz, a documentação interativa Swagger em `/docs` e o contrato OpenAPI em `/openapi.json`, com o título "Bolão Copa 2027" e as rotas expostas.

## Sub-features

- `api-raiz`: `GET /` no backend → 200 `{"message":"Welcome to Bolão Copa 2027 API"}`.
- `api-docs`: `GET /docs` → 200, HTML do Swagger UI com `<title>Bolão Copa 2027 - Swagger UI</title>`. `GET /redoc` → 200, com `<title>Bolão Copa 2027 - ReDoc</title>` (padrão do FastAPI).
- `api-openapi`: `GET /openapi.json` → 200, `info.title` = `Bolão Copa 2027`, `info.version` = `0.1.0`, `info.description` = `API do Bolão da Copa do Mundo Feminina` e `paths` com exatamente as rotas públicas atuais.
- `api-404`: rota inexistente no backend → 404 `{"detail":"Not Found"}`.
- `api-cors`: requisição com `Origin` do frontend da run recebe `access-control-allow-origin` e `access-control-allow-credentials: true`. Origem estranha não recebe o header.

## How to get to it (user POV)

- Links "API Backend" e "Swagger OpenAPI" da página inicial (porta padrão).
- Abrir `http://<backend>/docs` ou `http://<backend>/openapi.json` diretamente.

## Driving it with verify-bolao

Preconditions:

- `DOCTOR OK` para `$RUN_ID`, com `E=.git/verify-bolao/$RUN_ID/evidence` e `. .git/verify-bolao/$RUN_ID/state.env` carregado (para `FE_URL`/`BE_URL`).

- **Raiz.** Rode `$H get "$RUN_ID" backend / api-root`. Imprime `-> 200`, e `cat $E/api-root.body` mostra a mensagem de boas-vindas.
- **Swagger e ReDoc.** Rode `$H get "$RUN_ID" backend /docs docs`. Imprime `-> 200`, e `grep -q '<title>Bolão Copa 2027 - Swagger UI</title>' $E/docs.body` sai com 0. Repita com `/redoc redoc` e `<title>Bolão Copa 2027 - ReDoc</title>`.
- **Contrato.** Rode `$H get "$RUN_ID" backend /openapi.json openapi` e depois `python3 -c 'import json,sys; d=json.load(open(sys.argv[1],encoding="utf-8")); i=d["info"]; print(i["title"], i["version"], i.get("description"), sorted(d["paths"]))' $E/openapi.body`. Imprime `Bolão Copa 2027 0.1.0 API do Bolão da Copa do Mundo Feminina ['/', '/live', '/ready']`. Quando uma mudança adiciona rota, a lista esperada muda junto e o mapa precisa ser atualizado.
- **404 da API.** Rode `$H get "$RUN_ID" backend /nao-existe be-404`. Imprime `-> 404`, e o corpo é `{"detail":"Not Found"}`.
- **CORS.** Rode `st=$(curl -sS -D $E/cors.headers -o /dev/null -w '%{http_code}' -H "Origin: $FE_URL" "$BE_URL/live")` e anexe a linha ao log: `printf '%s GET %s (Origin %s) -> %s\n' "$(date -Iseconds)" "$BE_URL/live" "$FE_URL" "$st" >> $E/requests.log`. O `$H get` não envia headers, por isso o `curl`. Depois, `grep -i "access-control-allow-origin: $FE_URL" $E/cors.headers` encontra a linha. Repita com `-H "Origin: http://evil.example"` em `cors-neg.headers` e confirme que não há `access-control-allow-origin`.
- **Prova.** Cite as linhas do `requests.log`, a saída do `python3` e o header de CORS.

## Gotchas

- O HTML do Swagger carrega JS/CSS de `cdn.jsdelivr.net`. O `get` só prova que o HTML foi servido. Renderizar a UI exigiria navegador e rede externa, o que não é verificado aqui.
- O CORS da run é `http://127.0.0.1:<FE_PORT>` (definido no override). Na pilha do desenvolvedor, vale o `CORS_ORIGINS` do `.env`, que é opcional; sem ele, o padrão é `http://localhost:3000`. Não compare as duas.
- Leia o JSON com `encoding="utf-8"`. Fora do WSL (cp1252 no Windows) o título sai corrompido como `BolÃ£o`.
- Em produção, `/docs` poderá ser desativado. Isso ainda não foi decidido, então não trate a ausência dele como regressão sem conferir a decisão.
