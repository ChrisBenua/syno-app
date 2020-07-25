package com.syno_back.backend.controllers;

import com.syno_back.backend.datasource.RolesRepository;
import com.syno_back.backend.datasource.UserRepository;
import com.syno_back.backend.dto.MessageResponse;
import com.syno_back.backend.dto.NewUser;
import com.syno_back.backend.dto.UpdateRequestDto;
import com.syno_back.backend.dto.UserDictionary;
import com.syno_back.backend.model.DbUser;
import com.syno_back.backend.service.IAuthControllerService;
import com.syno_back.backend.service.IUserDictionaryControllerService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

import javax.annotation.PostConstruct;
import javax.validation.Valid;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

@CrossOrigin(origins = {"*"}, maxAge = 3600)
@RestController
@RequestMapping("/api/admin")
public class AdminController {
    private static final Logger logger = LoggerFactory.getLogger(AdminController.class);

    @Value("${app.admin.default-password}")
    private String adminPassword;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private IUserDictionaryControllerService userDictionaryControllerService;

    @Autowired
    private RolesRepository rolesRepository;

    @Autowired
    private IAuthControllerService authControllerService;

    private void createAdminUserIfNeeded() {
        var adminCandidate = userRepository.findByEmail("admin@admin.com");

        if (adminCandidate.isEmpty()) {
            var user = DbUser.builder()
                    .email("admin@admin.com")
                    .password(passwordEncoder.encode(adminPassword))
                    .roles(Arrays.asList(rolesRepository.findByName("ROLE_USER"), rolesRepository.findByName("ROLE_ADMIN")))
                    .isVerified(true)
                    .build();
            userRepository.save(user);
        }
    }

    @PostConstruct
    public void setup() {
        createAdminUserIfNeeded();
    }

    @GetMapping(value = "/user_all/{email}", produces = MediaType.APPLICATION_JSON_VALUE)
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<UserDictionary>> getUserDictionaries(@PathVariable String email) {
        logger.info("GET /api/admin/user_all/{}", email);
        return ResponseEntity.ok(userDictionaryControllerService.allForUser(email).collect(Collectors.toList()));
    }

    @PostMapping(value = "/update/{email}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<?> updateUserDicts(@PathVariable String email, @Valid @RequestBody UpdateRequestDto requestDto) {
        logger.info("POST: api/dicts/update for user {}", email);

        try {
            userDictionaryControllerService.performUpdates(email, requestDto);
            return ResponseEntity.ok(new MessageResponse("Updated successfully"));
        } catch (Exception ex) {
            return new ResponseEntity<>(new MessageResponse(String.format("Failed: %s", ex.getMessage())), HttpStatus.BAD_REQUEST);
        }
    }

    @PostMapping(value = "/create_user")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<?> createUser(@Valid @RequestBody NewUser newUser) {
        try {
            var user = authControllerService.createUser(newUser, List.of("ROLE_USER"), true, false);
            return ResponseEntity.ok(MessageResponse.of(String.format("User %s created successfully", newUser.getEmail())));
        } catch (Exception ex) {
            return new ResponseEntity<>(MessageResponse.of(ex.getMessage()), HttpStatus.BAD_REQUEST);
        }
    }
}
