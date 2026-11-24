# Spring Boot WebFlux Kotlin Template

A GitHub template for reactive REST APIs with Spring Boot 4, Kotlin coroutines, and R2DBC. Clone
it to start a new service: the build, the tests, and the local database setup already work.

## Stack

| Component | Choice |
|---|---|
| Language | Kotlin 2.4.10 |
| Runtime | Java 25 (Amazon Corretto), virtual threads enabled |
| Framework | Spring Boot 4.2, WebFlux (reactive, non-blocking) |
| Database | PostgreSQL over R2DBC (`CoroutineCrudRepository`) |
| Security | Spring Security, HTTP Basic. Replace it with an OAuth2 Resource Server in production. |
| API docs | SpringDoc OpenAPI 3, Swagger UI at `:9090/swagger-ui/index.html` |
| Build | Gradle 9.9 with a version catalog (`gradle/libs.versions.toml`) |
| Linting | Kotlinter |
| Testing | JUnit 5, Kotest assertions, MockK, Testcontainers (PostgreSQL) |

> [!NOTE]
> Kotlin stays on 2.4.10 because ktlint 1.8.0, the version bundled with Kotlinter 5.7.0, fails
> on the Kotlin 2.4.20 and later compilers with *"Extensions storage is not registered"*. Upgrade
> Kotlin after a ktlint release that supports Kotlin 2.4.2x reaches Maven Central.

## Use the template

1. Click **Use this template** on GitHub.
2. Replace the root package `org.eljabali.sami.todo` with your own across all source files.
3. Rename the project in [`settings.gradle.kts`](settings.gradle.kts).
4. Update `spring.r2dbc.url` and the credentials in
   [`src/main/resources/application.yml`](src/main/resources/application.yml).
5. Update the schema SQL in [`src/main/resources/schema.sql`](src/main/resources/schema.sql). The
   application and the Testcontainers tests both apply it.

## Prerequisites

- Java 25 ([Amazon Corretto](https://aws.amazon.com/corretto/))
- Docker, for the local PostgreSQL and for Testcontainers

## Run the application

### With Docker Compose

To start the application and the database together, run:

```bash
./gradlew bootRun
```

The `spring-boot-docker-compose` module is on the development classpath, so the services in
`docker-compose.yml` start before the application and stop with it.

To keep the database running independently of the application, start it yourself:

```bash
docker compose up -d
```

The API listens on `http://localhost:8080/v1/todos`, and Swagger UI listens on
`http://localhost:9090/swagger-ui/index.html`. Authenticate with `user` / `password` or
`admin` / `password`; see `SecurityConfig`.

### With Testcontainers

The `TestApplication` in the test sources starts the application with a PostgreSQL container that
Testcontainers manages, so you need no local database. Run it from your IDE, or run:

```bash
./gradlew bootTestRun
```

## Tests

The following table lists the tests and the database each one uses.

| Test | Scope | Database |
|---|---|---|
| `AppPropertiesTest` | The `app.*` configuration properties | None |
| `TodoControllerTest` | The controller endpoints, `WebTestClient` against a `@WebFluxTest` slice | Mocked repository |
| `TodoRepositoryTest` | The R2DBC repository, with `@DataR2dbcTest` | PostgreSQL from Testcontainers |
| `IntegrationTest` | The whole application over real HTTP, with `WebClient` | PostgreSQL from Testcontainers |

`TestcontainersConfiguration` is a `@TestConfiguration` that declares a `PostgreSQLContainer` bean
annotated with `@ServiceConnection`. Spring Boot derives the `spring.r2dbc.*` settings from the
running container, so the tests need neither `@DynamicPropertySource` nor the
`@Testcontainers` and `@Container` annotations.

The tests need a running Docker daemon. Testcontainers starts a PostgreSQL container for them.

| Command | Purpose |
|---|---|
| `./gradlew test` | Run the unit, controller, repository, and integration tests |
| `./gradlew check` | Run the tests and the lint check |
| `./gradlew lintKotlin` | Check the Kotlin sources with Kotlinter |
| `./gradlew formatKotlin` | Format the Kotlin sources with Kotlinter |

## Package structure

```
org.eljabali.sami.todo
├── Application.kt                  entry point
├── domain/
│   ├── model/                      entities and enums
│   ├── repository/                 CoroutineCrudRepository interfaces
│   └── exception/                  domain exceptions
├── application/                    Spring config classes
├── interfaces/
│   ├── Uris.kt                     centralized URI constants
│   ├── TodoController.kt           REST controllers
│   └── RestWebExceptionHandler.kt  @RestControllerAdvice
└── shared/
    └── model/                      request/response DTOs
```

## Build

| Command | Purpose |
|---|---|
| `./gradlew build` | Compile, lint, and run all tests |
| `./gradlew bootJar` | Build the executable JAR in `build/libs/` |

## Docker

To build and run the production image:

1. Build the executable JAR: `./gradlew bootJar`
2. Build the image: `docker build -t todo-app .`
3. Run the image: `docker run -p 8080:8080 todo-app`

## CI

[`.github/workflows/build.yml`](.github/workflows/build.yml) compiles the project and runs the full
test suite. The tests use Testcontainers, and Docker is preinstalled on the GitHub-hosted runners,
so the workflow needs neither a database service nor a `docker compose up` step.
