# Design proposto: Identidade local e Google por e-mail

## Estado e fontes

Requisito v3.4, HU-22 fixa correspondência por e-mail, reverificação do novo endereço local com código numérico de seis dígitos e no máximo três tentativas por verificação; HU-23 permite autenticação Google de identidade já vinculada à conta validada. HU-21 mantém recuperação de senha distinta e PROD-07 mantém aprovação administrativa. ADR-001 aprova direção de sessão opaca revogável, sem fixar parâmetros. Esta change ainda não tem desenho implementável completo. A minuta `docs/architecture/decisoes-tecnicas/TEC-01-PROD-07-autenticacao-admissao.md` contém mecanismos prévios conflitantes e segue não aprovada.

## Fronteiras previstas

O backend `identity` (existente somente como scaffold) deve ser dono da confirmação local e autorização de admissão; `frontend/features/auth` e contratos HTTP serão criados depois de aprovar o desenho. Google e vínculo de identidades ficam fora desta entrega local. Para mudança de e-mail local, o novo endereço exige verificação e não herda o status do antigo. A persistência precisa garantir unicidade e concorrência para solicitações, endereços e tentativas, sem definir agora tabelas, constraints ou regras de exclusão (OPS-01). O código não pode ser exposto em logs ou armazenado em claro; controles de armazenamento seguro, limitação de solicitações e antiabuso serão detalhados e aprovados no desenho técnico. A política de produto já fixa validade de 10 minutos e reenvio sem reiniciar as três tentativas por verificação.

## Decisões de produto confirmadas e questões técnicas abertas

Em 02/11/2026, o solicitante confirmou as recomendações locais de PROD-07 para esta change: cadastro cria solicitação pendente; verificação local precede a fila de aprovação; pessoa verificada e pendente pode consultar o próprio estado e corrigir o nome, sem recursos de participante/admin; aprovação/rejeição são ações explícitas e auditadas; rejeição, saída e reativação não apagam histórico automaticamente; endereço antigo permanece vigente até o novo ser verificado; conflito de endereço não permite fusão; código de cadastro de uso único com validade de 10 minutos, até três tentativas e reenvio sem reset. Falhas de e-mail de liberação são registradas/repetíveis sem reverter aprovação. Estas decisões de produto não são autorização de implementação.

- **Vínculo automático só por igualdade do e-mail:** não adotado; não comprova controle de conta preexistente. Google e o primeiro vínculo ficam fora da entrega local; prova de controle e conflitos ficam pendentes para change futura.
- **Identificar Google por e-mail:** não adotado; o `sub` identifica a identidade Google já vinculada; validação das declarações e fluxo futuro ainda precisam de design.
- **Reaproveitar o token de recuperação HU-21:** rejeitado por finalidade/política distintas; a confirmação local de cadastro também é distinta da verificação HU-22 de vínculo Google.
- **Sessão JWT/refresh da minuta:** não adotada; ADR-001 orienta sessão opaca revogável no servidor. Cookie, CSRF, duração, revogação e invalidação após mudança de e-mail ainda exigem análise de ameaça.
- **Administrador inicial:** PROD-08 mantém a exceção local já implementada (`admin`, senha por variável de ambiente local, somente development); a proposta anterior de provisionamento controlado com e-mail e troca obrigatória de senha não é decisão aprovada. Provisionamento não local segue aberto.

Antes de implementar, ainda requerem revisão/aprovação técnica: armazenamento seguro do código, limitação de solicitações/antiabuso e comportamento operacional de reenvio; autorização/admin fora do login local; sessões/CSRF e unicidade/concorrência/migrações; entrega/bounce e OPS-03; retenção/exclusão OPS-01. Google/HU-22/23, prova do primeiro vínculo e conflitos de identidade permanecem fora do escopo atual.

## Validação futura desta entrega local

Quando houver aprovação de implementação, validar cadastro e verificação local (código de uso único, validade de 10 minutos, três tentativas e reenvio sem reset), autenticação não confirmada/pendente, autorização negativa de palpites/ranking/dados de terceiros/admin, aprovação/rejeição e auditoria, falha/reenvio de e-mail de liberação, alteração/conflito de e-mail e ausência de exclusão automática. Cobrir enumeração e vazamento de dados/códigos. Validar concorrência/unicidade sob PostgreSQL real conforme desenho aprovado. Nenhum teste de runtime foi executado e não há driver escolhido.

Retorno Google por `sub`, prova/bloqueio do primeiro vínculo e testes E2E Google pertencem a uma change futura, fora dos critérios desta entrega local.
