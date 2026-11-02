## ADDED Requirements

### Requirement: Cadastro de conta local
O sistema MUST permitir que uma pessoa solicite cadastro local informando nome, e-mail e credencial de usuário/senha, e MUST exigir confirmação do endereço antes de permitir login local (PROD-07; HU-12/13).

#### Scenario: Solicitação de cadastro
- **GIVEN** uma pessoa informa os dados mínimos de cadastro e uma credencial local válida
- **WHEN** envia a solicitação de cadastro
- **THEN** o sistema MUST registrar a solicitação e iniciar a confirmação do endereço de e-mail sem conceder participação no bolão

#### Scenario: E-mail ainda não confirmado
- **GIVEN** uma solicitação local cujo endereço ainda não foi confirmado
- **WHEN** a pessoa tenta autenticar-se com usuário e senha
- **THEN** o sistema MUST recusar o login e informar que a confirmação do e-mail é necessária sem revelar dados de outras contas

#### Scenario: Login após confirmação
- **GIVEN** uma conta local com credencial válida e endereço de e-mail confirmado
- **WHEN** a pessoa autenticar-se com usuário e senha
- **THEN** o sistema MUST autenticar a conta, mantendo separada a autorização para participar até aprovação administrativa

#### Scenario: E-mail verificado antes da fila
- **GIVEN** uma conta local recém-cadastrada ainda não confirmada
- **WHEN** a pessoa não conclui a confirmação do e-mail
- **THEN** o sistema MUST NOT encaminhar a solicitação para revisão administrativa nem conceder acesso de participante

#### Scenario: Código de confirmação de cadastro
- **GIVEN** uma solicitação local aguardando confirmação
- **WHEN** o sistema emite ou reenvia o código de confirmação
- **THEN** o código MUST ser numérico, de uso único e válido por 10 minutos; MUST permitir no máximo três tentativas de apresentação por verificação; e reenvio MUST NOT reiniciar esse limite
- **AND** o sistema MUST NOT expor o código em logs nem armazená-lo em claro

### Requirement: Confirmação de e-mail para cadastro local
O sistema MUST enviar ao endereço informado um código numérico de confirmação de uso único, vinculado à solicitação correspondente, válido por 10 minutos e limitado a três tentativas de apresentação por verificação. Reenvio MUST NOT reiniciar o limite. O código MUST NOT ser exposto em logs nem armazenado em claro. Essa confirmação é distinta da verificação HU-22 para vínculo Google e da recuperação HU-21.

#### Scenario: Confirmação do endereço solicitado
- **GIVEN** uma solicitação de cadastro local ainda não confirmada
- **WHEN** a pessoa apresenta um mecanismo válido emitido para essa solicitação
- **THEN** o sistema MUST confirmar somente o endereço associado à solicitação e MUST impedir a reutilização do mecanismo consumido

#### Scenario: Mecanismo expirado ou inválido
- **GIVEN** uma solicitação de cadastro local não confirmada
- **WHEN** a pessoa apresenta um mecanismo expirado, inválido ou associado a outra solicitação
- **THEN** o sistema MUST manter o endereço não confirmado e MUST NOT autenticar a conta

### Requirement: Aprovação administrativa da participação
O sistema MUST exigir aprovação de uma conta administrativa para liberar a participação dos demais usuários; confirmação de e-mail ou autenticação local não substituem essa aprovação (PROD-07/08).

#### Scenario: Conta confirmada aguardando aprovação
- **GIVEN** uma conta local com e-mail confirmado e ainda não aprovada
- **WHEN** a pessoa autentica-se
- **THEN** o sistema MUST permitir acesso restrito para consultar o próprio estado e corrigir o próprio nome
- **AND** MUST NOT permitir palpites, ranking, dados de terceiros ou funções administrativas

#### Scenario: Rejeição não exclui histórico
- **GIVEN** uma solicitação de participação rejeitada
- **WHEN** a decisão é registrada
- **THEN** o sistema MUST manter a conta e o histórico sem exclusão automática e MUST manter bloqueadas as funções de participante

#### Scenario: Reativação ou saída
- **GIVEN** uma conta rejeitada ou admitida cuja situação de participação muda por reativação ou saída
- **WHEN** um administrador autorizado registra a transição
- **THEN** o sistema MUST auditar ator, instante, ação e estados anterior/novo, sem excluir automaticamente conta, palpites ou histórico

#### Scenario: Falha no e-mail de liberação
- **GIVEN** uma aprovação administrativa válida
- **WHEN** a notificação por e-mail falha
- **THEN** o sistema MUST preservar a decisão de aprovação, registrar a falha e permitir nova tentativa de envio

#### Scenario: Aprovação por administrador
- **GIVEN** uma solicitação de participação pendente e confirmada por e-mail
- **WHEN** a conta administrativa autorizada aprova a solicitação
- **THEN** o sistema MUST liberar as funções de participante, registrar ator, instante, ação e estados anterior/novo para auditoria e disparar o e-mail de liberação

#### Scenario: Rejeição por administrador
- **GIVEN** uma solicitação de participação pendente
- **WHEN** a conta administrativa autorizada rejeita a solicitação
- **THEN** o sistema MUST manter bloqueadas as funções de participante e registrar a ação administrativa para auditoria

### Requirement: Conta administrativa inicial
A autenticação administrativa local de desenvolvimento segue a decisão PROD-08 registrada: identidade `admin`, senha definida em variável de ambiente local não versionada e sem verificação de e-mail, exclusivamente com `ENVIRONMENT=development`. Esta exceção não estabelece provisionamento administrativo fora do ambiente local, que permanece pendente de decisão e design. Credenciais MUST NOT ser embutidas em imagens, logs ou configurações de produção.

#### Scenario: Login administrativo local de desenvolvimento
- **GIVEN** `ENVIRONMENT=development` e a senha da identidade `admin` está definida em variável de ambiente local não versionada
- **WHEN** a pessoa administradora autentica-se usando essa senha
- **THEN** o sistema MUST permitir o acesso administrativo sem exigir validação do e-mail

#### Scenario: Ambiente diferente do desenvolvimento local
- **GIVEN** a aplicação executa fora de `ENVIRONMENT=development`
- **WHEN** uma pessoa tenta usar a exceção de autenticação administrativa local
- **THEN** o sistema MUST rejeitar esse mecanismo

#### Scenario: Aprovação de participantes pela conta administrativa
- **GIVEN** uma solicitação de participação pendente
- **WHEN** a conta administrativa inicial autenticada e autorizada a revisa
- **THEN** o sistema MUST permitir aprovar ou rejeitar a solicitação e MUST auditar a decisão

### Requirement: Alteração de e-mail local
Uma pessoa autenticada MUST iniciar a alteração do e-mail local submetendo o novo endereço para verificação. A verificação MUST usar o código numérico de seis dígitos enviado ao novo endereço e permitir no máximo três tentativas por verificação, conforme HU-22. A validade e o reenvio deste código seguem pendentes no escopo futuro TEC-01; não presumir para este fluxo a política de 10 minutos/reenvio definida para confirmação de cadastro local.

#### Scenario: Endereço antigo permanece vigente
- **GIVEN** uma conta local com endereço vigente confirmado
- **WHEN** a pessoa solicita alteração para um endereço novo ainda não confirmado
- **THEN** o sistema MUST manter o endereço antigo como contato e login vigente até a confirmação do endereço novo

#### Scenario: Ativar somente endereço confirmado
- **GIVEN** uma solicitação de mudança de e-mail pendente
- **WHEN** a pessoa apresenta código válido para o novo endereço
- **THEN** o sistema MUST ativar somente o novo endereço solicitado e verificado

#### Scenario: Conflito com endereço existente
- **GIVEN** o novo endereço já está associado a outra conta
- **WHEN** a pessoa solicita a alteração
- **THEN** o sistema MUST rejeitar a alteração e MUST NOT fundir contas nem transferir identidades automaticamente; resolução explícita é necessária

#### Scenario: Alteração aguardando verificação
- **GIVEN** uma conta local com endereço vigente confirmado
- **WHEN** a pessoa solicita alteração para um endereço novo
- **THEN** o sistema MUST manter o endereço antigo vigente até a confirmação do novo

#### Scenario: Conflito com endereço existente
- **GIVEN** o novo endereço já está associado a outra conta
- **WHEN** a pessoa solicita a alteração
- **THEN** o sistema MUST rejeitar a alteração e MUST NOT fundir contas nem transferir identidades automaticamente

### Requirement: Integração Google opcional e separada
A autenticação e o vínculo com Google são opcionais para a primeira entrega de cadastro local e MUST NOT ser pré-requisito para solicitar cadastro, confirmar e-mail, autenticar com usuário/senha ou obter aprovação administrativa. Os comportamentos HU-22/23 permanecem aplicáveis caso a integração Google seja implementada futuramente.

#### Scenario: Fluxo local sem Google
- **GIVEN** a integração Google não está habilitada
- **WHEN** uma pessoa solicita cadastro, confirma seu e-mail ou autentica-se localmente
- **THEN** o sistema MUST permitir o fluxo local sem exigir identidade Google

#### Scenario: Primeiro vínculo Google por coincidência de e-mail
- **GIVEN** uma identidade Google não vinculada e uma conta local preexistente com o mesmo e-mail
- **WHEN** houver correspondência de endereço
- **THEN** o sistema MUST NOT conceder acesso à conta preexistente somente com base na coincidência de e-mail; qualquer primeiro vínculo futuro deve respeitar HU-22/23 e decisão TEC-01 aprovada
