# Flutter Feature-First Clean Architecture Rules

Version: 1.0

This document defines the mandatory architecture for every Flutter project.

These rules must always be followed when generating, modifying, or refactoring code.

---

# Core Principles

The project follows:

- Feature-First Architecture
- Clean Architecture
- SOLID Principles
- Repository Pattern
- Provider State Management
- Dependency Injection
- Separation of Concerns
- Testable Design
- Reusable Components

No code should violate these principles.

---

# Dependency Rule

Dependencies always point inward.

```
Presentation
      ↓
Domain
      ↑
Data
```

Meaning:

Presentation depends only on Domain.

Data depends on Domain.

Domain depends on nothing.

Domain must NEVER import Flutter.

Domain must NEVER import Provider.

Domain must NEVER import Firebase.

Domain must NEVER import Supabase.

Domain must NEVER import Dio.

Domain contains pure Dart only.

---

# Project Structure

```
lib/

    core/

        constants/

        errors/

        services/

        network/

        utils/

        widgets/

        theme/

        routes/

        di/

    features/

        feature_name/

            data/

                datasources/

                models/

                repositories/

            domain/

                entities/

                repositories/

                usecases/

            presentation/

                providers/

                screens/

                widgets/

main.dart
```

Each feature must be completely isolated.

Features must not directly depend on each other.

Shared code belongs inside Core.

---

# Layer Responsibilities

---

## DATA LAYER

Purpose:

Responsible for retrieving and storing data.

This layer communicates with:

- REST APIs
- Firebase
- Supabase
- SQLite
- Hive
- SharedPreferences
- Local Cache

Never place business logic here.

---

### Data Sources

Folder:

```
data/datasources/
```

Responsible for:

- HTTP requests
- Supabase queries
- Firebase calls
- Local database access

Examples:

```
AuthRemoteDataSource

UserRemoteDataSource

ProductLocalDataSource
```

A DataSource should never know about Providers.

A DataSource should never know about UI.

---

### Models

Folder

```
data/models/
```

Models represent API or database structures.

Responsibilities:

- fromJson()

- toJson()

- serialization

- deserialization

Models may extend Entities.

Example

```
UserModel extends User
```

Models should not contain business logic.

---

### Repository Implementation

Folder

```
data/repositories/
```

Implements repository contracts defined inside Domain.

Responsibilities

- call Data Sources

- map Models to Entities

- map exceptions

- combine remote/local data

Never communicate directly with UI.

---

# DOMAIN LAYER

Purpose

Contains all business logic.

This layer must be pure Dart.

No Flutter imports allowed.

No Provider imports allowed.

No Firebase imports allowed.

No networking code allowed.

---

## Entities

Folder

```
domain/entities/
```

Entities represent business objects.

They should contain:

- immutable fields

- equality

- business representation

No JSON.

No serialization.

No API logic.

Example

```
User

Product

Cart

Booking
```

---

## Repository Contracts

Folder

```
domain/repositories/
```

Repository interfaces define what the application can do.

Example

```
abstract class AuthRepository {

Future<User> login(...);

}
```

Never implement repositories here.

Only define contracts.

---

## Use Cases

Folder

```
domain/usecases/
```

Each file represents one business action.

Examples

```
Login

Register

Logout

UpdateProfile

DeleteAccount

CreateBooking

FetchProducts
```

One use case = one responsibility.

Use Cases should never contain UI code.

Use Cases communicate only with Repository interfaces.

---

# PRESENTATION LAYER

Contains Flutter UI.

---

## Screens

Folder

```
presentation/screens/
```

Responsibilities

Compose widgets.

Handle navigation.

Connect Providers.

Should contain almost no business logic.

---

## Providers

Folder

```
presentation/providers/
```

Provider is the only state management solution.

Responsibilities

- Loading states

- Error states

- Success states

- Calling UseCases

- notifyListeners()

Providers should NEVER

- call APIs

- access Supabase

- access Firebase

- contain SQL

- contain HTTP requests

Always delegate to Use Cases.

Flow

```
Button Press

↓

Provider

↓

Use Case

↓

Repository

↓

Data Source

↓

Server
```

---

## Widgets

Folder

```
presentation/widgets/
```

Reusable UI components.

Widgets should be:

- Stateless whenever possible

- Small

- Reusable

- Independent

Do not place business logic inside widgets.

---

# Dependency Injection

Dependency Injection must be used everywhere.

Preferred solution:

```
GetIt
```

Example

```
Provider

↓

UseCase

↓

Repository

↓

RepositoryImpl

↓

DataSource
```

Objects must never instantiate their own dependencies.

Avoid

```
final repo = RepositoryImpl();
```

Instead

Inject dependencies.

---

# Naming Conventions

Good

```
LoginUseCase

UserRepository

UserRepositoryImpl

UserModel

UserEntity

AuthProvider

LoginScreen

LoginForm

UserRemoteDataSource
```

Bad

```
Utils

Helper

Common

Data

Manager

Functions
```

Names should describe exactly one responsibility.

---

# Feature Rules

Each feature owns its own:

- Data

- Domain

- Presentation

Never place feature code inside another feature.

Good

```
features/

auth/

profile/

booking/

products/
```

Bad

```
auth/

profile/

shared/

bookingInsideProfile/
```

---

# Error Handling

Repositories convert exceptions into Failures.

Presentation never catches API exceptions directly.

DataSource

↓

Exception

↓

Repository

↓

Failure

↓

UseCase

↓

Provider

↓

UI

---

# State Management Rules

Provider should expose:

```
loading

errorMessage

data

success
```

Provider should notify listeners only when state changes.

Business rules belong inside Use Cases.

---

# SOLID Rules

Every class must have one responsibility.

Depend on abstractions.

Avoid giant classes.

Avoid giant Providers.

Avoid giant Widgets.

Prefer composition over inheritance.

---

# File Size Guidelines

Entity

<100 lines

Model

<150 lines

UseCase

Usually <60 lines

Provider

Prefer <200 lines

Widget

Prefer <200 lines

Repository

Keep focused.

Split when necessary.

---

# AI Code Generation Rules

Whenever generating a new feature:

Always generate

```
feature/

data/

datasources/

models/

repositories/

domain/

entities/

repositories/

usecases/

presentation/

providers/

screens/

widgets/
```

Never skip layers.

Never merge responsibilities.

Always use Dependency Injection.

Always use Repository Pattern.

Always use Provider.

Always separate UI from business logic.

Always write scalable code.

Always respect Clean Architecture.

---

# Data Flow

```
User Action

↓

Screen

↓

Provider

↓

Use Case

↓

Repository Interface

↓

Repository Implementation

↓

Data Source

↓

API / Database

↓

Repository

↓

Use Case

↓

Provider

↓

UI
```

---

# Forbidden Practices

Never call APIs inside Widgets.

Never call APIs inside Providers.

Never import Flutter inside Domain.

Never instantiate dependencies manually.

Never place business logic inside UI.

Never access Data Sources directly from Presentation.

Never bypass Repository.

Never create God classes.

Never create Utility classes containing unrelated methods.

Never mix multiple responsibilities inside one file.

---

# Golden Rule

If a piece of code answers the question:

"How should the business work?"

It belongs in Domain.

If it answers:

"Where does the data come from?"

It belongs in Data.

If it answers:

"How should the user see it?"

It belongs in Presentation.