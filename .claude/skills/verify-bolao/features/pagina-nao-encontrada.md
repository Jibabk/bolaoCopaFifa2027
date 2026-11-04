# Página não encontrada

Uma rota inexistente do site mostra a página 404 em pt-BR ("Página não encontrada") com o layout do Bolão e um link "Voltar para início".

## Sub-features

- `nf-status`: a rota desconhecida responde **HTTP 404**, não 200.
- `nf-conteudo`: aparecem o heading "404", "Página não encontrada" e o texto explicativo.
- `nf-voltar`: o link "Voltar para início" aponta para `/`.

## How to get to it (user POV)

- Digitar no navegador qualquer caminho inexistente do frontend, ex.: `/rota-inexistente`.
- Seguir um link quebrado para um caminho aninhado, ex.: `/a/b/c`.

## Driving it with verify-bolao

Preconditions:

- `DOCTOR OK` para `$RUN_ID`, com `E=.git/verify-bolao/$RUN_ID/evidence`.

- **Rota simples.** Rode `$H get "$RUN_ID" frontend /rota-inexistente notfound`. Ele imprime `-> 404`.
- **Rota aninhada.** Rode `$H get "$RUN_ID" frontend /a/b/c notfound-aninhada`. Ele imprime `-> 404`.
- **Conteúdo.** Rode `grep -o '>404<\|Página não encontrada\|Voltar para início' $E/notfound.body | sort -u`. Mostra as 3 entradas.
- **Layout preservado.** Rode `grep -q 'Bolão Copa do Mundo Feminina da FIFA 2027™</h1>' $E/notfound.body`. Sai com 0.
- **Voltar.** Rode `grep -q 'href="/"' $E/notfound.body`, depois `$H get "$RUN_ID" frontend / home-via-404`. Ele imprime `-> 200`.
- **Prova.** Cite as duas linhas `-> 404` e a linha `-> 200` do `requests.log`, além do trecho do corpo.

## Gotchas

- O status 404 vem do header HTTP. O `<title>` da página continua sendo o do layout ou "Página não encontrada". Sempre confira o status no `requests.log`, não só o texto.
- Caminhos dentro de `/api/` passam pelo roteamento de API. Só `/api/health` existe, e outros caminhos de API não são a página 404 do usuário.
