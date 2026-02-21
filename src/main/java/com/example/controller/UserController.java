package com.example.controller;

import com.example.config.ApiRoutes;
import com.example.model.ApiErrorResponse;
import com.example.model.User;
import com.example.service.UserService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.media.ArraySchema;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping(ApiRoutes.BASE_V1 + "/users")
@Tag(name = "Users", description = "Operacoes CRUD de usuarios")
public class UserController {

    @Autowired
    private UserService userService;
    
    @GetMapping
    @Operation(summary = "Listar usuarios", description = "Retorna a lista completa de usuarios cadastrados")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Lista retornada com sucesso",
            content = @Content(mediaType = "application/json",
                array = @ArraySchema(schema = @Schema(implementation = User.class))))
    })
    public List<User> getAllUsers() {
        return userService.getAllUsers();
    }
    
    @GetMapping("/{id}")
    @Operation(summary = "Buscar usuario por ID", description = "Retorna os dados de um usuario especifico")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Usuario encontrado",
            content = @Content(mediaType = "application/json", schema = @Schema(implementation = User.class))),
        @ApiResponse(responseCode = "404", description = "Usuario nao encontrado",
            content = @Content(mediaType = "application/json", schema = @Schema(implementation = ApiErrorResponse.class)))
    })
    public User getUserById(
        @Parameter(description = "ID do usuario", example = "1")
        @PathVariable Long id
    ) {
        return userService.getUserById(id);
    }
    
    @PostMapping
    @Operation(summary = "Criar usuario", description = "Cria um novo usuario e retorna o registro persistido")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Usuario criado com sucesso",
            content = @Content(mediaType = "application/json", schema = @Schema(implementation = User.class)))
    })
    public User createUser(@RequestBody User user) {
        return userService.createUser(user);
    }
    
    @PutMapping("/{id}")
    @Operation(summary = "Atualizar usuario", description = "Atualiza os dados de um usuario existente")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Usuario atualizado com sucesso",
            content = @Content(mediaType = "application/json", schema = @Schema(implementation = User.class))),
        @ApiResponse(responseCode = "404", description = "Usuario nao encontrado",
            content = @Content(mediaType = "application/json", schema = @Schema(implementation = ApiErrorResponse.class)))
    })
    public User updateUser(
        @Parameter(description = "ID do usuario", example = "1")
        @PathVariable Long id,
        @RequestBody User user
    ) {
        return userService.updateUser(id, user);
    }
    
    @DeleteMapping("/{id}")
    @Operation(summary = "Remover usuario", description = "Remove um usuario existente pelo ID")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Usuario removido com sucesso"),
        @ApiResponse(responseCode = "404", description = "Usuario nao encontrado",
            content = @Content(mediaType = "application/json", schema = @Schema(implementation = ApiErrorResponse.class)))
    })
    public void deleteUser(
        @Parameter(description = "ID do usuario", example = "1")
        @PathVariable Long id
    ) {
        userService.deleteUser(id);
    }
}
