# Página não encontrada

Uma rota inexistente do site mostra a página 404 em pt-BR ("Página não encontrada") com o layout do Bolão e um link "Voltar para início".

## Sub-features

- `nf-status`: a rota desconhecida responde **HTTP 404**, não 200, inclusive caminhos aninhados e em `/api/`.
- `nf-conteudo`: aparecem o heading "404", "Página não encontrada" e o texto "A página que você está procurando não existe ou foi movida.", com `<title>Página não encontrada</title>` e `<meta name="robots" content="noindex">`.
- `nf-voltar`: o link "Voltar para início" aponta para `/`.

## How to get to it (user POV)

- Digitar no navegador qualquer caminho inexistente do frontend, ex.: `/rota-inexistente`.
- Seguir um link quebrado para um caminho aninhado, ex.: `/a/b/c`.

## Driving it with verify-bolao

Preconditions:

- `DOCTOR OK` para `$RUN_ID`, com `E=.git/verify-bolao/$RUN_ID/evidence`.

- **Rota simples.** Rode `$H get "$RUN_ID" frontend /rota-inexistente notfound`. Ele imprime `-> 404`.
- **Rota aninhada.** Rode `$H get "$RUN_ID" frontend /a/b/c notfound-aninhada`. Ele imprime `-> 404`.
- **Caminho de API inexistente.** Rode `$H get "$RUN_ID" frontend /api/inexistente notfound-api`. Ele imprime `-> 404` com a mesma página.
- **Conteúdo (as três entradas).** Para `n` em `notfound notfound-aninhada notfound-api`, rode `grep -q '>404</h1>' $E/$n.body && grep -q 'Página não encontrada' $E/$n.body && grep -q 'A página que você está procurando não existe ou foi movida.' $E/$n.body && grep -q 'Voltar para início' $E/$n.body`. Sai com 0 nas três.
- **Título e indexação.** Rode `grep -o '<title>[^<]*</title>' $E/notfound.body`. Mostra `<title>Página não encontrada</title>`. Depois rode `grep -q 'name="robots" content="noindex"' $E/notfound.body`, que sai com 0.
- **Layout preservado.** Rode `grep -q 'Bolão Copa do Mundo Feminina da FIFA 2027™</h1>' $E/notfound.body`. Sai com 0.
- **Voltar.** Rode `grep -q 'href="/"' $E/notfound.body`, depois `$H get "$RUN_ID" frontend / home-via-404`. Ele imprime `-> 200`.
- **Prova.** Cite as três linhas `-> 404` e a linha `-> 200` do `requests.log`, além do trecho do corpo.

## Gotchas

- O status 404 vem do header HTTP. O texto "Página não encontrada" sozinho não prova o status, então sempre confira o `requests.log` ou o `.headers`.
- No App Router não há roteamento de API separado. `/api/health` é só um `route.ts`, e qualquer outro caminho em `/api/` cai no mesmo `not-found.tsx` com 404 HTML (provado na run `maintain-1`).
