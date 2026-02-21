package com.example.service;

import com.example.model.User;
import com.example.repository.UserRepository;
import com.example.exception.UserNotFoundException;
import io.micrometer.core.instrument.Counter;
import io.micrometer.core.instrument.MeterRegistry;
import org.springframework.stereotype.Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.List;

@Service
public class UserService {

    private static final Logger LOGGER = LoggerFactory.getLogger(UserService.class);

    private final UserRepository userRepository;
    private final MeterRegistry meterRegistry;

    @Autowired
    public UserService(UserRepository userRepository, MeterRegistry meterRegistry) {
        this.userRepository = userRepository;
        this.meterRegistry = meterRegistry;
    }

    public List<User> getAllUsers() {
        LOGGER.info("Listing all users");
        return userRepository.findAll();
    }
    
    public User getUserById(Long id) {
        return userRepository.findById(id).orElseGet(() -> {
            incrementCounter("users.not_found");
            LOGGER.warn("User not found with id={}", id);
            throw new UserNotFoundException("User not found with id " + id);
        });
    }
    
    public User createUser(User user) {
        User savedUser = userRepository.save(user);
        incrementCounter("users.created");
        LOGGER.info("User created id={} email={}", savedUser.getId(), savedUser.getEmail());
        return savedUser;
    }
    
    public User updateUser(Long id, User userDetails) {
        User user = getUserById(id);
        user.setName(userDetails.getName());
        user.setEmail(userDetails.getEmail());
        User updatedUser = userRepository.save(user);
        incrementCounter("users.updated");
        LOGGER.info("User updated id={} email={}", updatedUser.getId(), updatedUser.getEmail());
        return updatedUser;
    }
    
    public void deleteUser(Long id) {
        // Reuse getUserById to ensure the user exists and throw the
        // appropriate exception when not found.
        getUserById(id);
        userRepository.deleteById(id);
        incrementCounter("users.deleted");
        LOGGER.info("User deleted id={}", id);
    }

    private void incrementCounter(String counterName) {
        if (meterRegistry == null) {
            return;
        }
        Counter counter = meterRegistry.counter(counterName);
        if (counter != null) {
            counter.increment();
        }
    }
}
