package com.example.controller;

import com.example.config.ApiRoutes;
import com.example.model.HealthResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping(ApiRoutes.BASE_V1)
@Tag(name = "Monitoring", description = "Endpoints de monitoramento da aplicacao")
public class HealthController {

    @GetMapping("/health")
    @Operation(summary = "Health check", description = "Retorna o status de disponibilidade da API")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Aplicacao disponivel",
            content = @Content(mediaType = "application/json", schema = @Schema(implementation = HealthResponse.class)))
    })
    public HealthResponse health() {
        return new HealthResponse("UP");
    }
}
