package com.syno_back.backend.controllers;

import com.syno_back.backend.datasource.RolesRepository;
import com.syno_back.backend.datasource.UserRepository;
import com.syno_back.backend.dto.LoginUser;
import com.syno_back.backend.dto.NewUser;
import com.syno_back.backend.jwt.JwtResponse;
import com.syno_back.backend.jwt.ResponseMessage;
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

@CrossOrigin(origins = {"*"}, maxAge = 3600)
@RestController
@RequestMapping("/api/auth")
public class AuthController {
    @Autowired
    private AuthenticationManager authenticationManager;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private RolesRepository rolesRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private JwtProvider jwtProvider;

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
            return new ResponseEntity<>(new ResponseMessage("User not found "), HttpStatus.BAD_REQUEST);
        }
    }

    @PostMapping("/signup")
    public ResponseEntity registerUser(@Valid @RequestBody NewUser newUser) {
        var candidate = userRepository.findByEmail(newUser.getEmail());
        if (candidate.isEmpty()) {
            //additional checking

            var user = new DbUser(newUser.getEmail(), passwordEncoder.encode(newUser.getPassword()));
            user.setRoles(Arrays.asList(rolesRepository.findByName("ROLE_USER")));

            userRepository.save(user);

            return ResponseEntity.ok(new ResponseMessage("User registered successfully!"));
        } else {
            return new ResponseEntity<>(new ResponseMessage("User already exists!"), HttpStatus.BAD_REQUEST);
        }
    }

}
