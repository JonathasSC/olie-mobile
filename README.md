# Olie Mobile

App Flutter organizado em Clean Architecture.

## Como rodar

```bash
flutter pub get
flutter run
```

## Estrutura

```
lib/
  core/                    # Código compartilhado por todas as features
    di/                    # Injeção de dependências (get_it)
    error/                 # Failures (domínio) e Exceptions (data)
    network/               # Checagem de conectividade
    theme/                 # Tema do app
    usecases/              # Contrato base de use case
  features/
    <feature>/
      domain/              # Entidades, contratos de repositório e use cases (puro Dart)
        entities/
        repositories/
        usecases/
      data/                # Implementação concreta da camada domain
        models/            # Entidades com (de)serialização
        datasources/       # Fontes de dados local/remoto
        repositories/
      presentation/        # UI e gerenciamento de estado
        bloc/
        screens/
        widgets/
```

A feature `todo` em `lib/features/todo` serve como exemplo de referência local (armazenamento em memória), cobrindo o fluxo completo (domain → data → presentation) com `flutter_bloc` para estado, `get_it` para DI e `dartz` para tratamento de erros com `Either<Failure, T>`.

A feature `auth` em `lib/features/auth` consome a API real descrita em `reference/API.md` (`POST /auth/register` e `POST /auth/login`), persiste o token JWT com `flutter_secure_storage` e navega para `/home` após autenticar. Ajuste `AppConstants.baseUrl` (`lib/core/constants/app_constants.dart`) conforme o ambiente (Web/iOS usam `localhost`; emulador Android precisa de `10.0.2.2`).

## Stack

- **Estado**: flutter_bloc
- **DI**: get_it
- **Erros**: dartz (`Either<Failure, T>`)
- **Rede**: dio + internet_connection_checker_plus
- **Testes**: flutter_test, bloc_test, mocktail

## Adicionando uma nova feature

1. Crie `lib/features/<nome>/{domain,data,presentation}`.
2. Defina entidades e o contrato do repositório em `domain`.
3. Implemente `data` (model, datasource, repository impl).
4. Registre as dependências em `lib/core/di/injection_container.dart`.
5. Construa a UI em `presentation`.
