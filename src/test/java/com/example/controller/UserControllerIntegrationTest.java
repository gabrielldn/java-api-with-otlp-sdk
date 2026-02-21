package com.example.controller;

import com.example.config.ApiRoutes;
import com.example.model.User;
import com.example.service.UserService;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import java.util.Arrays;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.BDDMockito.given;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(UserController.class)
class UserControllerIntegrationTest {

    private static final String USERS_BASE = ApiRoutes.BASE_V1 + "/users";

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private UserService userService;

    @Autowired
    private ObjectMapper objectMapper;

    private User user;

    @BeforeEach
    void setup() {
        user = new User();
        user.setId(1L);
        user.setName("Test");
        user.setEmail("test@example.com");
    }

    @Test
    void getAllUsers() throws Exception {
        given(userService.getAllUsers()).willReturn(Arrays.asList(user));

        mockMvc.perform(get(USERS_BASE))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].id").value(1L));
    }

    @Test
    void getUserById() throws Exception {
        given(userService.getUserById(1L)).willReturn(user);

        mockMvc.perform(get(USERS_BASE + "/1"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(1L));
    }

    @Test
    void createUser() throws Exception {
        given(userService.createUser(any(User.class))).willReturn(user);

        mockMvc.perform(post(USERS_BASE)
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(user)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(1L));
    }

    @Test
    void updateUser() throws Exception {
        given(userService.updateUser(eq(1L), any(User.class))).willReturn(user);

        mockMvc.perform(put(USERS_BASE + "/1")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(user)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(1L));
    }

    @Test
    void deleteUser() throws Exception {
        mockMvc.perform(delete(USERS_BASE + "/1"))
                .andExpect(status().isOk());
    }
}
