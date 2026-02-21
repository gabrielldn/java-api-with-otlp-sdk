package com.example.controller;

import com.example.config.ApiRoutes;
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
@Tag(name = "Utility", description = "Endpoints utilitarios")
public class HelloController {

    @GetMapping("/hello")
    @Operation(summary = "Mensagem de saudacao", description = "Retorna uma mensagem simples para validar a API")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Mensagem retornada com sucesso",
            content = @Content(mediaType = "text/plain", schema = @Schema(implementation = String.class)))
    })
    public String hello() {
        return "Hello, World!";
    }
}
