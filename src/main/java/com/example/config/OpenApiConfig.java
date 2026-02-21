package com.example.config;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Contact;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.servers.Server;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.List;

@Configuration
public class OpenApiConfig {

    @Bean
    public OpenAPI apiDocumentation() {
        return new OpenAPI()
            .servers(List.of(new Server().url("/").description("Local root server")))
            .info(new Info()
                .title("Java API with OpenTelemetry SDK")
                .version("v1")
                .description("API REST para gerenciamento de usuarios com suporte a observabilidade.")
                .contact(new Contact().name("Maintainers")));
    }
}
