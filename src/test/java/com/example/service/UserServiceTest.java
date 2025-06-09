package com.example.service;

import com.example.exception.UserNotFoundException;
import com.example.model.User;
import com.example.repository.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;

import java.util.Arrays;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

class UserServiceTest {

    @Mock
    private UserRepository userRepository;

    @InjectMocks
    private UserService userService;

    @BeforeEach
    void setUp() {
        MockitoAnnotations.openMocks(this);
    }

    @Test
    void getAllUsersReturnsList() {
        User user = new User();
        user.setId(1L);
        when(userRepository.findAll()).thenReturn(Arrays.asList(user));

        List<User> users = userService.getAllUsers();
        assertEquals(1, users.size());
        verify(userRepository).findAll();
    }

    @Test
    void getUserByIdFound() {
        User user = new User();
        user.setId(1L);
        when(userRepository.findById(1L)).thenReturn(Optional.of(user));

        User result = userService.getUserById(1L);
        assertEquals(1L, result.getId());
    }

    @Test
    void getUserByIdNotFound() {
        when(userRepository.findById(1L)).thenReturn(Optional.empty());
        assertThrows(UserNotFoundException.class, () -> userService.getUserById(1L));
    }

    @Test
    void createUserDelegatesToRepository() {
        User user = new User();
        when(userRepository.save(any(User.class))).thenReturn(user);

        User created = userService.createUser(user);
        assertNotNull(created);
        verify(userRepository).save(user);
    }

    @Test
    void updateUserChangesAndSaves() {
        User existing = new User();
        existing.setId(1L);
        existing.setName("Old");
        existing.setEmail("old@example.com");

        User update = new User();
        update.setName("New");
        update.setEmail("new@example.com");

        when(userRepository.findById(1L)).thenReturn(Optional.of(existing));
        when(userRepository.save(any(User.class))).thenReturn(existing);

        User result = userService.updateUser(1L, update);
        assertEquals("New", result.getName());
        assertEquals("new@example.com", result.getEmail());
    }

    @Test
    void deleteUserExisting() {
        when(userRepository.existsById(1L)).thenReturn(true);
        userService.deleteUser(1L);
        verify(userRepository).deleteById(1L);
    }

    @Test
    void deleteUserNotFound() {
        when(userRepository.existsById(1L)).thenReturn(false);
        assertThrows(UserNotFoundException.class, () -> userService.deleteUser(1L));
    }
}
