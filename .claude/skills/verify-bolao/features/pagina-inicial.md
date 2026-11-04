# Página inicial

Quem abre a raiz do site vê o cabeçalho do Bolão, o aviso de que o ambiente é um scaffold, as informações do torneio (32 seleções, 64 jogos, BRT, corte 1 h antes do kickoff) e links para a API, o Swagger e o healthcheck.

## Sub-features

- `home-render`: `/` responde 200 com `<html lang="pt-BR">` e o `<title>` do Bolão.
- `home-aviso`: aviso "Ambiente de Desenvolvimento — Scaffold Inicial".
- `home-info`: a lista "Informações do Projeto" traz as regras exibidas (BRT UTC-3, corte de 1 hora).
- `home-links`: os três links para desenvolvedores, com seus `href`.

## How to get to it (user POV)

- Abrir `http://<frontend>/` no navegador.
- Clicar em "Voltar para início" na página 404 (ver [página não encontrada](./pagina-nao-encontrada.md)).

## Driving it with verify-bolao

Preconditions:

- `DOCTOR OK` para `$RUN_ID`, com `E=.git/verify-bolao/$RUN_ID/evidence`.

- **Abrir a página.** Rode `$H get "$RUN_ID" frontend / home`. Ele imprime `-> 200`.
- **Identidade e idioma.** Rode `grep -q '<html lang="pt-BR"' $E/home.body && grep -q '<title>Bolão Copa do Mundo Feminina da FIFA 2027™</title>' $E/home.body`. Sai com 0.
- **Heading e aviso.** Rode `grep -q 'Bolão da Copa do Mundo Feminina da FIFA Brasil 2027™</h2>' $E/home.body && grep -q 'Ambiente de Desenvolvimento — Scaffold Inicial' $E/home.body`. Sai com 0.
- **Informações do torneio.** Rode `grep -o '32 seleções participantes\|64 partidas\|BRT (UTC-3)\|1 hora antes do kickoff oficial' $E/home.body | sort -u`. Mostra as 4 linhas.
- **Links.** Rode `grep -o 'href="http://localhost:8000[^"]*"' $E/home.body | sort -u`. Mostra `href="http://localhost:8000"`, `.../docs` e `.../live`.
- **Chegar pela 404.** A partir da 404, rode `$H get "$RUN_ID" frontend /rota-inexistente nf-para-home` e `grep -q 'href="/"' $E/nf-para-home.body`. Depois, o `get /` acima vale como destino.
- **Prova.** Cite `requests.log` (linha `GET .../ -> 200`) e os trechos de `home.body`.

## Gotchas

- Os `href` dos links são fixos em `http://localhost:8000` (default do Compose do desenvolvedor), **não** a porta do backend da run. Seguir o link a partir da run cai na pilha do desenvolvedor ou em lugar nenhum. Para provar o destino, use `$H get "$RUN_ID" backend /docs`, e não o `href`.
- O corpo contém o payload RSC (`self.__next_f`) além do HTML, então os textos aparecem duas vezes. Ancore os greps em tags (`</h2>`, `<title>`) quando precisar do HTML renderizado.
- O primeiro `get /` depois de um restart do frontend pode demorar porque o `next dev` compila. O `up` já faz o aquecimento.
- `loading.tsx` ("Carregando...") só aparece em navegação no cliente. Não espere vê-lo no HTML do SSR.
