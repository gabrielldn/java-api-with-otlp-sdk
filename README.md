# Java API with OpenTelemetry SDK

![Java](https://img.shields.io/badge/Java-17-orange)
![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.1.0-brightgreen)
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
   - [OpenTelemetry Integration](#opentelemetry-integration)
- [Components in Detail](#components-in-detail)
   - [Spring Boot API](#spring-boot-api)
   - [OpenTelemetry SDK](#opentelemetry-sdk)
   - [H2 Database](#h2-database)
   - [Swagger Documentation](#swagger-documentation)
- [Configurations](#configurations)
   - [Application Properties](#application-properties)
   - [OpenTelemetry Configuration](#opentelemetry-configuration)
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
│   │   │           ├── config/            # Application configs
│   │   │           │   └── OpenTelemetryConfig.java
│   │   │           └── Application.java   # Main application class
│   │   └── resources/
│   │       ├── application.properties     # App configuration
│   │       └── otel-config.yaml           # OpenTelemetry config
│   └── test/                              # Unit and integration tests
├── pom.xml                                # Maven dependencies
├── Dockerfile                             # Container definition
└── README.md                              # Project documentation
```

## Prerequisites

To run this project, you need:

- JDK 17 or higher
- Maven 3.6 or higher
- OpenTelemetry Collector (optional, for exporting telemetry data)
- Docker (optional, for containerization)

## Installation

1. Clone the repository:
    ```bash
    git clone https://github.com/yourusername/java-api-with-otlp-sdk.git
    cd java-api-with-otlp-sdk
    ```

2. Build the project with Maven:
    ```bash
    mvn clean package
    ```

3. (Optional) Build Docker container:
    ```bash
    docker build -t java-api-with-otlp:latest .
    ```

## Usage

### Running the API

Run the application locally:

```bash
mvn spring-boot:run
```

Or using the JAR file:

```bash
java -jar target/java-api-with-otlp-sdk-1.0.0.jar
```

With Docker:

```bash
docker run -p 8080:8080 java-api-with-otlp:latest
```

### API Endpoints

Once the application is running, you can access:

- API Base URL: `http://localhost:8080`
- Swagger UI: `http://localhost:8080/swagger-ui.html`
- Health Check: `http://localhost:8080/health`

Main endpoints include:

- `GET /users` - List all users
- `GET /users/{id}` - Get user by ID
- `POST /users` - Create new user
- `PUT /users/{id}` - Update existing user
- `DELETE /users/{id}` - Delete user

### OpenTelemetry Integration

The application is configured to send telemetry data to an OpenTelemetry Collector. By default, it uses the following settings:

- OTLP Export Protocol: gRPC
- Collector Endpoint: `http://localhost:4317`
- Service Name: `java-api-service`

These settings can be modified in the `application.properties` file.

## Components in Detail

### Spring Boot API

The API is built using Spring Boot 3.1.0 with the following features:

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

The API is documented using SpringDoc OpenAPI:

- Interactive API documentation
- Try-out functionality for all endpoints
- Model schema definitions
- Authentication documentation

## Configurations

### Application Properties

Key application properties (`application.properties`):

```properties
# Server configuration
server.port=8080

# H2 Database
spring.datasource.url=jdbc:h2:mem:testdb
spring.datasource.driverClassName=org.h2.Driver
spring.datasource.username=sa
spring.datasource.password=
spring.h2.console.enabled=true

# JPA/Hibernate
spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=true

# OpenTelemetry
otel.service.name=java-api-service
otel.exporter.otlp.endpoint=http://localhost:4317
```

### OpenTelemetry Configuration

The OpenTelemetry SDK is configured in `OpenTelemetryConfig.java`:

- Automatic instrumentation of Spring Web, JDBC, and JPA
- Resource attributes including service name and version
- Span processors for batching and exporting telemetry data
- Integration with Spring's logging framework

## Troubleshooting

### Common Issues and Solutions

1. **Application fails to start**:
   - Verify Java version (`java -version`)
   - Check the application logs for specific error messages
   - Ensure required ports are available (8080 for API)

2. **Telemetry data not showing up**:
   - Verify the OpenTelemetry Collector is running
   - Check the collector endpoint configuration
   - Look for connection errors in the application logs

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
