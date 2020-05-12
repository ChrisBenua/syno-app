package com.syno_back.backend.controllers;

import com.syno_back.backend.datasource.RolesRepository;
import com.syno_back.backend.datasource.UserRepository;
import com.syno_back.backend.dto.LoginUser;
import com.syno_back.backend.dto.MessageResponse;
import com.syno_back.backend.dto.NewUser;
import com.syno_back.backend.jwt.JwtResponse;
import com.syno_back.backend.jwt.auth.JwtProvider;
import com.syno_back.backend.model.DbUser;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

import javax.validation.Valid;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

/**
 * Controller for accepting login and registration requests
 */
@CrossOrigin(origins = {"*"}, maxAge = 3600)
@RestController
@RequestMapping("/api/auth")
public class AuthController {
    /**
     * Service for authenticating users
     */
    @Autowired
    private AuthenticationManager authenticationManager;

    /**
     * Repository for fetching DbUser from DB
     */
    @Autowired
    private UserRepository userRepository;

    /**
     * Repository for fetching DbRole from DB
     */
    @Autowired
    private RolesRepository rolesRepository;

    /**
     * Service for encoding users' passwords
     */
    @Autowired
    private PasswordEncoder passwordEncoder;

    /**
     * Service for generating JWT tokens
     */
    @Autowired
    private JwtProvider jwtProvider;

    /**
     * Accepts login request
     * @param loginUser DTO with user credentials
     * @return ResponseEntity&lt;JwtResponse&gt; on success and ResponseEntity&lt;MessageResponse&gt; on failure
     */
    @PostMapping("/signin")
    public ResponseEntity authenticateUser(@Valid @RequestBody LoginUser loginUser) {
        var candidate = userRepository.findByEmail(loginUser.getEmail().orElseThrow());

        if (candidate.isPresent()) {
            var user = candidate.get();
            var auth = new UsernamePasswordAuthenticationToken(loginUser.getEmail().get(), loginUser.getPassword().get());
            var authentication = authenticationManager.authenticate(auth);

            SecurityContextHolder.getContext().setAuthentication(authentication);
            var jwt = jwtProvider.generateJwtToken(user.getEmail());
            List<GrantedAuthority> authorities = user.getRoles().get().stream()
                    .map(role -> new SimpleGrantedAuthority(role.getName()))
                    .collect(Collectors.toList());

            return ResponseEntity.ok(new JwtResponse(jwt, user.getEmail(), authorities));
        } else {
            return new ResponseEntity<>(new MessageResponse("User not found "), HttpStatus.BAD_REQUEST);
        }
    }

    /**
     * Accepts register request
     * @param newUser new user's credentials
     * @return ResponseEntity&lt;MessageResponse&gt; with failure or success message
     */
    @PostMapping("/signup")
    public ResponseEntity registerUser(@Valid @RequestBody NewUser newUser) {
        var candidate = userRepository.findByEmail(newUser.getEmail());
        if (candidate.isEmpty()) {
            //additional checking

            var user = new DbUser(newUser.getEmail(), passwordEncoder.encode(newUser.getPassword()));
            user.setRoles(Arrays.asList(rolesRepository.findByName("ROLE_USER")));

            userRepository.save(user);

            return ResponseEntity.ok(new MessageResponse("User registered successfully!"));
        } else {
            return new ResponseEntity<>(new MessageResponse("User already exists!"), HttpStatus.BAD_REQUEST);
        }
    }

}
