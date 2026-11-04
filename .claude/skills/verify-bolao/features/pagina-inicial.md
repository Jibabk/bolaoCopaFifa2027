# Página inicial

Quem abre a raiz do site vê o cabeçalho do Bolão, o aviso de que o ambiente é um scaffold, as informações do torneio (32 seleções, 64 jogos, BRT, corte 1 h antes do kickoff) e links para a API, o Swagger e o healthcheck.

## Sub-features

- `home-render`: `/` responde 200 com `<html lang="pt-BR">`, o `<title>` do Bolão, o h1 do cabeçalho e o rodapé "© 2027 Bolão Copa do Mundo Feminina da FIFA Brasil".
- `home-aviso`: aviso "Ambiente de Desenvolvimento — Scaffold Inicial" com "Funcionalidades de negócio ainda não foram implementadas.".
- `home-info`: a lista "Informações do Projeto" com os 6 itens (competição, local, 32 seleções, 64 partidas, BRT UTC-3, corte de 1 hora).
- `home-links`: os três links para desenvolvedores, com `href` e rótulos ("API Backend", "Swagger OpenAPI", "Healthcheck").

## How to get to it (user POV)

- Abrir `http://<frontend>/` no navegador.
- Clicar em "Voltar para início" na página 404 (ver [página não encontrada](./pagina-nao-encontrada.md)).

## Driving it with verify-bolao

Preconditions:

- `DOCTOR OK` para `$RUN_ID`, com `E=.git/verify-bolao/$RUN_ID/evidence`.

- **Abrir a página.** Rode `$H get "$RUN_ID" frontend / home`. Ele imprime `-> 200`.
- **Identidade, idioma e layout.** Rode `grep -q '<html lang="pt-BR"' $E/home.body && grep -q '<title>Bolão Copa do Mundo Feminina da FIFA 2027™</title>' $E/home.body && grep -q 'Bolão Copa do Mundo Feminina da FIFA 2027™</h1>' $E/home.body && grep -q '© 2027 Bolão Copa do Mundo Feminina da FIFA Brasil' $E/home.body`. Sai com 0.
- **Heading e aviso.** Rode `grep -q 'Bolão da Copa do Mundo Feminina da FIFA Brasil 2027™</h2>' $E/home.body && grep -q 'Ambiente de Desenvolvimento — Scaffold Inicial' $E/home.body && grep -q 'Funcionalidades de negócio ainda não foram implementadas.' $E/home.body`. Sai com 0.
- **Informações do torneio.** Rode `grep -o 'Copa do Mundo Feminina da FIFA 2027</li>\|Brasil</li>\|32 seleções participantes\|64 partidas\|BRT (UTC-3)\|1 hora antes do kickoff oficial' $E/home.body | sort -u`. Mostra as 6 linhas.
- **Links.** Rode `grep -o 'href="http://localhost:8000[^"]*"' $E/home.body | sort -u`, que mostra `href="http://localhost:8000"`, `.../docs` e `.../live`. Depois rode `grep -o 'API Backend (http://localhost:8000)\|Swagger OpenAPI (http://localhost:8000/docs)\|Healthcheck (http://localhost:8000/live)' $E/home.body | sort -u`, que mostra os 3 rótulos.
- **Chegar pela 404.** A partir da 404, rode `$H get "$RUN_ID" frontend /rota-inexistente nf-para-home` e `grep -q 'href="/"' $E/nf-para-home.body`. Depois, o `get /` acima vale como destino.
- **Prova.** Cite `requests.log` (linha `GET .../ -> 200`) e os trechos de `home.body`.

## Gotchas

- Os `href` dos links são fixos em `http://localhost:8000` (default do Compose do desenvolvedor), **não** a porta do backend da run. Seguir o link a partir da run cai na pilha do desenvolvedor ou em lugar nenhum. Para provar o destino, use `$H get "$RUN_ID" backend /docs`, e não o `href`.
- O corpo contém o payload RSC (`self.__next_f`) além do HTML, então os textos aparecem duas vezes. Ancore os greps em tags (`</h2>`, `<title>`) quando precisar do HTML renderizado.
- O primeiro `get /` depois de um restart do frontend pode demorar porque o `next dev` compila. O `up` já faz o aquecimento.
- `loading.tsx` ("Carregando...") só é renderizado em navegação no cliente. O texto aparece 1 vez no payload RSC do corpo, mas não como `<p>` renderizado (run `maintain-1`). Para afirmar que ele não aparece, ancore em tag (`<p[^>]*>Carregando`), nunca use `grep` solto.
