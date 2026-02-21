# Java API with OpenTelemetry SDK

![Java](https://img.shields.io/badge/Java-25-orange)
![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.5.11-brightgreen)
![OpenTelemetry](https://img.shields.io/badge/OpenTelemetry-SDK-blue)
![License](https://img.shields.io/badge/License-MIT-lightgrey)

## Table of Contents
- [Introduction](#introduction)
- [Architecture](#architecture)
   - [Components](#components)
   - [Data Flow](#data-flow)
- [Project Structure](#project-structure)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Usage](#usage)
   - [Running the API](#running-the-api)
   - [API Endpoints](#api-endpoints)
- [Components in Detail](#components-in-detail)
   - [Spring Boot API](#spring-boot-api)
   - [OpenTelemetry SDK](#opentelemetry-sdk)
   - [H2 Database](#h2-database)
   - [Swagger Documentation](#swagger-documentation)
- [Configurations](#configurations)
   - [Application Properties](#application-properties)
- [Troubleshooting](#troubleshooting)
- [Contribution](#contribution)
- [License](#license)

## Introduction

**Java API with OpenTelemetry SDK** is a complete REST API built with Spring Boot that demonstrates a production-ready implementation of the OpenTelemetry SDK for observability. This project provides a robust foundation for developing microservices with built-in telemetry capabilities, allowing seamless integration with modern observability platforms.

The API includes full CRUD operations for user management, follows a layered architecture pattern (Controller-Service-Repository), and uses JPA/Hibernate for persistence with an in-memory H2 database. The OpenTelemetry integration provides automatic instrumentation for metrics, traces, and logs.

## Architecture

### Components

The application consists of the following main components:

- **Spring Boot API**: REST API with CRUD operations
- **OpenTelemetry SDK**: For collecting and exporting telemetry data
- **H2 Database**: In-memory database for persistence
- **Swagger UI**: API documentation and testing interface

### Data Flow

```
┌─────────────┐      ┌─────────────────┐      ┌──────────────────┐
│ HTTP Client │──────▶ Spring Boot API │──────▶ Business Services │
└─────────────┘      └────────┬────────┘      └─────────┬────────┘
                             │                          │
                             │                          │
                    ┌────────▼────────┐      ┌──────────▼────────┐
                    │  OpenTelemetry  │      │   H2 Database     │
                    │      SDK        │      │                   │
                    └────────┬────────┘      └───────────────────┘
                             │
                             │
                    ┌────────▼────────┐
                    │ Telemetry Data  │
                    │ (OTLP Format)   │
                    └────────┬────────┘
                             │
                             ▼
                  ┌──────────────────────┐
                  │ Observability Backend │
                  │ (Collector, Jaeger,   │
                  │  Prometheus, etc.)    │
                  └──────────────────────┘
```

## Project Structure

```
java-api-with-otlp-sdk/
├── Makefile                               # Setup/run commands with GNU Make
├── src/
│   ├── main/
│   │   ├── java/
│   │   │   └── com/
│   │   │       └── example/
│   │   │           ├── controller/        # REST API controllers
│   │   │           │   └── HealthController.java
│   │   │           ├── service/           # Business logic services
│   │   │           ├── repository/        # Data access layer
│   │   │           ├── model/             # Domain entities
│   │   │           └── RestApiApplication.java  # Main application class
│   │   └── resources/
│   │       ├── application.properties     # App configuration
│   └── test/                              # Unit and integration tests
├── pom.xml                                # Maven dependencies
└── README.md                              # Project documentation
```

## Prerequisites

### Recommended (automatic setup)

If you do not want to configure everything manually, the minimum requirement is:

- GNU Make (`make`)

Se voce nao quiser configurar tudo manualmente, o minimo e ter o `make` instalado.

With that, run:

```bash
make setup
```

`make setup` installs missing dependencies (Java 25+ and Maven) using the package manager when supported (`apt`, `dnf`, `yum`, `pacman`, `zypper`, `apk`, `brew`).

### Manual setup (without Make)

- JDK 25 or higher
- Maven 3.6 or higher
- OpenTelemetry Collector (optional, for exporting telemetry data)

## Installation

1. Clone the repository:
    ```bash
    git clone https://github.com/gabrielldn/java-api-with-otlp-sdk.git
    cd java-api-with-otlp-sdk
    ```

2. Prepare the local environment:
    ```bash
    make setup
    ```

3. Build the project:
    ```bash
    make build
    ```

## Usage

### Running the API

Run the application locally:

```bash
make run
```

`make run` performs a clean start: it stops any process already bound to the configured port and starts the app again with fresh compiled classes.

Stop the application (in another terminal):

```bash
make down
```

Run on a custom port:

```bash
make run APP_PORT=8081
make down APP_PORT=8081
```

Or using the JAR file:

```bash
make jar
```

Run tests:

```bash
make test
```

### API Endpoints

Once the application is running, you can access:

- API Base URL: `http://localhost:8080/api/v1`
- Swagger UI: `http://localhost:8080/api/v1/swagger-ui`
- ReDoc: `http://localhost:8080/api/v1/redoc`
- OpenAPI JSON: `http://localhost:8080/api/v1/api-docs`
- Health Check: `http://localhost:8080/api/v1/health`

Main endpoints include:

- `GET /api/v1/users` - List all users
- `GET /api/v1/users/{id}` - Get user by ID
- `POST /api/v1/users` - Create new user
- `PUT /api/v1/users/{id}` - Update existing user
- `DELETE /api/v1/users/{id}` - Delete user



## Components in Detail

### Spring Boot API

The API is built using Spring Boot 3.5.11 with the following features:

- RESTful endpoints with proper HTTP status codes
- Controller-Service-Repository architecture
- Custom exception handling with appropriate error responses
- Request validation
- Pagination and sorting capabilities

### OpenTelemetry SDK

The application uses OpenTelemetry Java SDK for:

- **Automatic Instrumentation**: Traces HTTP requests, database queries, and internal method calls
- **Manual Instrumentation**: Custom spans for business logic
- **Metrics Collection**: JVM metrics, API endpoint metrics, and custom business metrics
- **Context Propagation**: Maintains trace context across asynchronous boundaries
- **Attribute Enrichment**: Adds metadata to spans for better analysis

### H2 Database

An in-memory H2 database is used for data persistence:

- Auto-configured by Spring Boot
- Console available at `http://localhost:8080/h2-console`
- Default credentials: username="sa", password="" (empty)
- JDBC URL: `jdbc:h2:mem:testdb`

### Swagger Documentation

The API is documented using SpringDoc OpenAPI and can be explored in:

- Swagger UI: `http://localhost:8080/api/v1/swagger-ui`
- ReDoc: `http://localhost:8080/api/v1/redoc`
- OpenAPI JSON: `http://localhost:8080/api/v1/api-docs`

Documentation includes:

- Interactive API documentation
- Try-out functionality for all endpoints
- Model schema definitions
- Authentication documentation

## Configurations

### Application Properties

Key application properties (`application.properties`):

```properties
# H2 Database
spring.datasource.url=jdbc:h2:mem:testdb
spring.datasource.driver-class-name=org.h2.Driver
spring.h2.console.enabled=true

# JPA/Hibernate
spring.jpa.hibernate.ddl-auto=update

# API documentation
springdoc.api-docs.path=/api/v1/api-docs
springdoc.swagger-ui.path=/api/v1/swagger-ui
```


## Troubleshooting

### Common Issues and Solutions

1. **Application fails to start**:
   - Verify Java version (`java -version`)
   - Check the application logs for specific error messages
   - Ensure required ports are available (8080 for API)

2. **Swagger calling `/api/v1/api/v1/...`**:
   - Stop the app with `make down`
   - Start again with `make run` (clean start)
   - Access docs via `http://localhost:8080/api/v1/swagger-ui`

3. **Database connection issues**:
   - Check H2 console for database state
   - Verify entity mappings and relationships
   - Review JPA configuration properties

## Contribution

Contributions are welcome! To contribute:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/new-feature`)
3. Commit your changes (`git commit -m 'Add new feature'`)
4. Push to the branch (`git push origin feature/new-feature`)
5. Open a Pull Request

Please ensure your code follows the existing code style and includes appropriate tests.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

---
Developed with ❤️ to demonstrate Spring Boot and OpenTelemetry integration.
