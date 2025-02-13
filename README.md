# Minitok InviteApp

## Descrição

O Minitok InviteApp é um aplicativo flutter que permite aos usuários gerenciar convites e amizades. Ele utiliza o Parse Server junto ao Back4App para autenticação e armazenamento de dados. Este README fornece uma visão geral das funcionalidades do aplicativo e em uma autoreflexão sugere pontos de melhorias.

## Funcionalidades

### Autenticação

- **Registro de Usuário**: Permite que novos usuários se registrem com um número de telefone, nome de usuário e senha.
- **Login**: Permite que usuários existentes façam login com seu nome de usuário e senha.
- **Logout**: Permite que os usuários façam logout de suas contas.

### Gerenciamento de Convites

- **Enviar Convite**: Permite que os usuários enviem convites para outros usuários usando seus números de telefone.
- **Verificar Existência de Usuário**: Verifica se um número de telefone já pertence a um usuário com status "accepted".
- **Enviar Solicitação de Amizade**: Envia uma solicitação de amizade para um usuário com base no número de telefone.
- **Obter Convites Enviados**: Retorna a lista de convites enviados pelo usuário.
- **Remover Convite**: Remove um convite caso ainda não tenha sido aceito.

### Gerenciamento de Amizades

- **Obter Lista de Amigos**: Retorna a lista de amigos do usuário atual, incluindo detalhes como nome de usuário, tipo de amizade e data de criação.
- **Enviar Solicitação de Amizade**: Envia uma solicitação de amizade para um usuário com base no nome de usuário.

### Estatísticas da Página Inicial

- **Obter Estatísticas da Página Inicial**: Retorna estatísticas como o total de usuários, total de amizades, solicitações de amizade pendentes e o número de amizades do usuário atual.

## Pontos de Melhorias

1. **Validação de Dados**: Adicionar validação de dados mais robusta ao registrar usuários e enviar convites para garantir que os dados inseridos sejam válidos.
2. **Tratamento de Erros**: Melhorar o tratamento de erros para fornecer mensagens de erro mais detalhadas e amigáveis ao usuário.
3. **Interface do Usuário**: Melhorar a interface do usuário para torná-la mais intuitiva e visualmente atraente.
4. **Notificações em Tempo Real**: Implementar notificações em tempo real para informar os usuários sobre novas solicitações de amizade e convites.
5. **Testes Automatizados**: Adicionar testes automatizados para garantir a qualidade e a estabilidade do código.
6. **Segurança**: Melhorar a segurança do aplicativo, incluindo a criptografia de dados sensíveis e a implementação de autenticação de dois fatores.
7. **Desempenho**: Otimizar consultas ao banco de dados e operações de rede para melhorar o desempenho do aplicativo; débito técnico por não dominio do back4app.
8. **Documentação**: Melhorar a documentação do código para facilitar a manutenção e o desenvolvimento futuro.

Obs: Atividades não feitas devido ao tempo limite.

## Como Executar

1. Clone o repositório:

   ```sh
   git clone https://github.com/seu-usuario/minitok_chalenge.git
   cd minitok_chalenge
   ```

2. Instale as dependêncis

```
  	flutter pub get
```

3. Rode o projeto

```
  flutter run
```

4. Escolha a plataforma

```
  android | web | ios | linux | windows
```
