# API e documentação

O desenvolvedor que consome a API encontra a mensagem de boas-vindas na raiz, a documentação interativa Swagger em `/docs` e o contrato OpenAPI em `/openapi.json`, com o título "Bolão Copa 2027" e as rotas expostas.

## Sub-features

- `api-raiz`: `GET /` no backend → 200 `{"message":"Welcome to Bolão Copa 2027 API"}`.
- `api-docs`: `GET /docs` → 200, HTML do Swagger UI com `<title>Bolão Copa 2027 - Swagger UI</title>`.
- `api-openapi`: `GET /openapi.json` → 200, `info.title` = `Bolão Copa 2027`, `info.version` = `0.1.0`, e `paths` com exatamente as rotas públicas atuais.
- `api-cors`: requisição com `Origin` do frontend da run recebe `access-control-allow-origin`.

## How to get to it (user POV)

- Links "API Backend" e "Swagger OpenAPI" da página inicial (porta padrão).
- Abrir `http://<backend>/docs` ou `http://<backend>/openapi.json` diretamente.

## Driving it with verify-bolao

Preconditions:

- `DOCTOR OK` para `$RUN_ID`, com `E=.git/verify-bolao/$RUN_ID/evidence` e `. .git/verify-bolao/$RUN_ID/state.env` carregado (para `FE_URL`/`BE_URL`).

- **Raiz.** Rode `$H get "$RUN_ID" backend / api-root`. Imprime `-> 200`, e `cat $E/api-root.body` mostra a mensagem de boas-vindas.
- **Swagger.** Rode `$H get "$RUN_ID" backend /docs docs`. Imprime `-> 200`, e `grep -q '<title>Bolão Copa 2027 - Swagger UI</title>' $E/docs.body` sai com 0.
- **Contrato.** Rode `$H get "$RUN_ID" backend /openapi.json openapi` e depois `python3 -c 'import json,sys; d=json.load(open(sys.argv[1])); print(d["info"]["title"], d["info"]["version"], sorted(d["paths"]))' $E/openapi.body`. Imprime `Bolão Copa 2027 0.1.0 ['/', '/live', '/ready']`. Quando uma mudança adiciona rota, a lista esperada muda junto e o mapa precisa ser atualizado.
- **CORS.** Rode `curl -sS -D $E/cors.headers -o /dev/null -H "Origin: $FE_URL" "$BE_URL/live"` e depois `grep -i "access-control-allow-origin: $FE_URL" $E/cors.headers`. Encontra a linha.
- **Prova.** Cite as linhas do `requests.log`, a saída do `python3` e o header de CORS.

## Gotchas

- O HTML do Swagger carrega JS/CSS de `cdn.jsdelivr.net`. O `get` só prova que o HTML foi servido. Renderizar a UI exigiria navegador e rede externa, o que não é verificado aqui.
- O CORS da run é `http://127.0.0.1:<FE_PORT>` (definido no override). Na pilha do desenvolvedor, vale o `CORS_ORIGINS` do `.env`. Não compare as duas.
- Em produção, `/docs` poderá ser desativado. Isso ainda não foi decidido, então não trate a ausência dele como regressão sem conferir a decisão.
