# Mapa de verificação do Bolão

Fonte mantida para verificar o comportamento visível do Bolão Copa FIFA 2027. Leia este índice antes de dirigir o app e use o arquivo da funcionalidade como recipe.

## Pré-condições de base

- Pilha isolada criada por `$H up "$RUN_ID"` (`H=.claude/skills/verify-bolao/bin/verify-bolao.sh`), a partir da raiz do repo.
- `$H doctor "$RUN_ID"` termina em `DOCTOR OK`.
- O banco nasce vazio: só a tabela `alembic_version`, sem seed. Nenhuma funcionalidade atual depende de dados.
- Nunca dirija uma pilha que esta run não criou (ex.: a do desenvolvedor nas portas 3000/8000).

## Convenções de condução

- Todo recipe parte do estado de base, salvo quando as pré-condições dizem outra coisa.
- Toda requisição passa por `$H get`, e toda consulta ao banco por `$H psql`. Use um `nome` explícito para cada evidência.
- Faça as asserções com `grep -q`/`python3 -c` sobre os arquivos em `.git/verify-bolao/$RUN_ID/evidence/`. Use `E=.git/verify-bolao/$RUN_ID/evidence`.
- Prefira handles estáveis: caminho da rota, `<title>`, texto de heading, `href`, chaves do JSON.
- Restaure o estado depois de uma ação que muda algo (ex.: `start db` depois de `stop db`). Não apague evidência.

## Prova e relato de lacunas

- Capture a ação e o estado resultante. O `requests.log` guarda a sequência com status.
- A prova da web é o HTML do SSR mais os headers. Não há screenshot (sem navegador autorizado). Não diga que algo visual foi verificado se o HTML não mostra.
- Registre o RUN_ID e a entrada usada em cada artefato citado.
- Entrada inalcançável: relate o comando tentado e a pré-condição que faltou. Não troque por outra entrada.

## Contrato de cada arquivo

H1 com o título e um parágrafo com o comportamento visível. Depois, exatamente quatro H2, nesta ordem: `Sub-features`, `How to get to it (user POV)`, `Driving it with verify-bolao` (começa com `Preconditions:`) e `Gotchas`.

## Funcionalidades

- [Página inicial](./pagina-inicial.md): título, aviso de scaffold, informações do torneio e links para desenvolvedores.
- [Página não encontrada](./pagina-nao-encontrada.md): 404 em pt-BR com retorno ao início.
- [Saúde e prontidão](./saude-e-prontidao.md): `/live`, `/ready` com o banco ok, parado e de volta, e `/api/health` do frontend.
- [API e documentação](./api-e-documentacao.md): raiz da API, Swagger em `/docs` e o contrato `/openapi.json`.
