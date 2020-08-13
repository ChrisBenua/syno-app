package com.syno_back.backend;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.security.core.context.SecurityContextHolder;

/**
 * Main runner class for entire application
 */
@SpringBootApplication
public class BackendApplication {

    public static void main(String[] args) {
        SecurityContextHolder.clearContext();
        SpringApplication.run(BackendApplication.class, args);
    }

}
