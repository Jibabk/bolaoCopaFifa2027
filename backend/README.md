# Backend - FastAPI/Python

Esta pasta contém o scaffold da API FastAPI/Python. A direção aprovada no `docs/architecture/decisoes-tecnicas/ADR-001-vsa-monorepo-e-persistencia.md` organiza casos de uso em fatias verticais por módulo; o scaffold atual de camadas não fixa a estrutura da implementação.

## Estrutura

- `app/entrypoints/http/` - Diretório reservado do scaffold; routers podem pertencer às fatias conforme design da change de VSA
- `app/modules/` - Módulos por capacidade (atualmente apenas scaffold; fatias por caso de uso serão criadas nas changes):
  - `identity/` - Identidade e acesso
  - `tournament/` - Torneio e calendário
  - `predictions/` - Palpites
  - `scoring/` - Apuração e pontuação
  - `ranking/` - Ranking e estatísticas
  - `support/` - Suporte
  - `gamification/` - Gamificação
- `app/shared/` - Primitivas realmente comuns (clock, IDs, erros)
- `app/bootstrap/` - Composição/configuração por ambiente
- `tests/` - Testes organizados por categoria:
  - `unit/` - Testes unitários
  - `integration/` - Testes de integração com PostgreSQL
  - `api/` - Testes de API/contrato
  - `contract/` - Testes de contrato
- `migrations/` - Migrações do banco de dados (Alembic)

## Convenções

- Domínio: objetos/valores e políticas puras, sem ORM nem framework
- Casos de uso: fatias por capacidade reúnem entradas, aplicação e saídas necessárias; não duplicar regras proprietárias do domínio
- Entrada: routers FastAPI e modelos Pydantic adaptam HTTP aos casos de uso, conforme design específico
- Saída: repositórios SQLAlchemy, e-mail, relógio e observabilidade implementam portas quando necessárias
- Persistência: SQLAlchemy síncrono como direção inicial; driver, URL, versões e escopo concreto de transações ainda precisam de change e validação
- Validação: Pydantic/HTTP valida forma/tipo; domínio valida regras
- Erros: contrato estável sem revelar detalhes internos
- Configuração: variáveis não secretas por ambiente; segredos via gerenciador aprovado
- Observabilidade: logs estruturados com correlation/request ID

## Cadastro e confirmação local (primeira fatia)

A implementação em andamento na change OpenSpec `2026-10-19-identity-email-link` cobre apenas solicitação de cadastro e confirmação de e-mail local (tarefas 2.1–2.2). O contrato planejado é `POST /registrations`, `POST /registrations/resend` e `POST /registrations/confirm`, com token opaco no corpo JSON para reenvio/confirmação (nunca na URL); não concede sessão nem acesso ao bolão. A especificação aprovada estabelece e-mail ASCII válido, espaços externos removidos e comparação case-insensitive; código de seis dígitos, uso único, 10 minutos e três tentativas por verificação; bcrypt 12 rounds para senha, rejeitando acima de 72 bytes; HMAC-SHA-256 para proteger o código com chave estável fora do Git; e rate-limit persistido em PostgreSQL em janela móvel de 60 minutos.

Em desenvolvimento, o adaptador de entrega será um arquivo local sob `/tmp/bolao-registration-outbox/` com diretório 0700 e arquivos 0600. Como PostgreSQL e filesystem não têm transação atômica conjunta, falhas/crashes deixam a solicitação em `pending_delivery`. Retry/reconciliação é oportunístico nas requisições de cadastro/reenvio, sem worker dedicado e com trabalho limitado: verifica o arquivo correspondente, considera-o entregue idempotentemente se já existir; se não existir, tenta gravar. Falha mantém o estado pendente, não permite confirmação e mantém a resposta externa genérica. Confirmação só é aceita após entrega concluída. O rate-limit considera somente `request.client.host` da conexão direta, ignorando `X-Forwarded-For` e outros headers; implantação atrás de proxy requer decisão/configuração explícita de proxies confiáveis. Cadastro/reenvio respondem HTTP 202 genérico; cadastro duplicado não reenvia e retorna o token opaco original, preservado com Fernet e chave dedicada estável fora do Git (arquivo 0600, distinta da chave HMAC); o serviço falha fechado sem chave válida. Reenvio requer o token opaco original. Não registrar token, ciphertext, código nem chave em logs. Confirmação inválida, expirada, consumida ou de solicitação incorreta retorna erro genérico. A integração de envio ainda não é apropriada para produção: fora de development o fluxo deve falhar fechado até haver integração segura configurada. Não registre códigos, chaves ou tokens em logs, não versione as chaves/outbox, e não use essa entrega local fora de desenvolvimento.

A change e a implementação ainda não passaram por todos os testes de aplicação; conferir `docs/STATE.md` e a change OpenSpec para o status real antes de executar. Não instale dependências sem autorização.

## Login administrativo local de desenvolvimento

Com o Docker Compose local (`ENVIRONMENT=development`), crie um arquivo `.env` na raiz do repositório (já ignorado pelo Git) e defina `LOCAL_ADMIN_PASSWORD` com uma senha de desenvolvimento. O Compose exige essa variável; se estiver ausente, a configuração falha, e se estiver vazia o login é rejeitado. Não compartilhe nem versione esse arquivo. A API disponibiliza `/admin/session` para login administrativo local. Use o usuário `admin` e a senha configurada; o e-mail não é verificado nesse fluxo. O backend emite sessão opaca em memória por cookie `HttpOnly`; `DELETE /admin/session` encerra a sessão e reiniciar o backend invalida todas as sessões. O backend deve permanecer em um único processo para esse armazenamento em memória. Esse mecanismo é exclusivo de desenvolvimento local e não deve ser usado em outros ambientes. A sessão apenas autentica a identidade administrativa: não implementa cadastro, aprovação de participantes, nem libera acesso privilegiado a palpites antes do corte.