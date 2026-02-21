package com.example.model;

import io.swagger.v3.oas.annotations.media.Schema;

@Schema(name = "HealthResponse", description = "Resposta padrao do endpoint de health check")
public record HealthResponse(
    @Schema(description = "Status da aplicacao", example = "UP")
    String status
) {
}
