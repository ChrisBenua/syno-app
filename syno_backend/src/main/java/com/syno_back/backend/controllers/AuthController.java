package com.syno_back.backend.controllers;

import com.syno_back.backend.datasource.RolesRepository;
import com.syno_back.backend.datasource.UserRepository;
import com.syno_back.backend.dto.LoginUser;
import com.syno_back.backend.dto.MessageResponse;
import com.syno_back.backend.dto.NewUser;
import com.syno_back.backend.dto.VerificationRequestDto;
import com.syno_back.backend.jwt.JwtResponse;
import com.syno_back.backend.jwt.auth.JwtProvider;
import com.syno_back.backend.service.IAuthControllerService;
import com.syno_back.backend.service.IEmailService;
import com.syno_back.backend.service.IVerificationCodeGenerator;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
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
import java.util.List;
import java.util.stream.Collectors;

/**
 * Controller for accepting login and registration requests
 */
@CrossOrigin(origins = {"*"}, maxAge = 3600)
@RestController
@RequestMapping("/api/auth")
public class AuthController {
    private static final Logger logger = LoggerFactory.getLogger(AuthController.class);
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

    @Autowired
    private IVerificationCodeGenerator verificationCodeGenerator;

    @Autowired
    private IEmailService emailService;

    @Value("${app.needs-email-verification}")
    private boolean isVerificationEnabled;

    @Autowired
    private IAuthControllerService authControllerService;

    /**
     * Accepts login request
     * @param loginUser DTO with user credentials
     * @return ResponseEntity&lt;JwtResponse&gt; on success and ResponseEntity&lt;MessageResponse&gt; on failure
     */
    @PostMapping("/signin")
    public ResponseEntity authenticateUser(@Valid @RequestBody LoginUser loginUser) {
        logger.info("POST: /api/auth/signin {}", loginUser.toString());
        var candidate = userRepository.findByEmail(loginUser.getEmail().orElseThrow());

        if (candidate.isPresent()) {
            var user = candidate.get();
            if (user.isVerified()) {
                var auth = new UsernamePasswordAuthenticationToken(loginUser.getEmail().get(), loginUser.getPassword().get());
                var authentication = authenticationManager.authenticate(auth);

                SecurityContextHolder.getContext().setAuthentication(authentication);
                var jwt = jwtProvider.generateJwtToken(user.getEmail());
                List<GrantedAuthority> authorities = user.getRoles().get().stream()
                        .map(role -> new SimpleGrantedAuthority(role.getName()))
                        .collect(Collectors.toList());

                logger.info("User {} sign in successfully", loginUser.getEmail());
                return ResponseEntity.ok(new JwtResponse(jwt, user.getEmail(), authorities));
            } else {
                logger.info("User {} sign in failed: account is not verified", loginUser.getEmail());

                return new ResponseEntity<>(new MessageResponse("Your account is not verified"), HttpStatus.BAD_REQUEST);
            }
        } else {
            logger.info("User {} not found", loginUser.getEmail());
            return new ResponseEntity<>(new MessageResponse("User not found "), HttpStatus.BAD_REQUEST);
        }
    }

    @GetMapping("/resend_conf_email/{email}")
    public ResponseEntity<?> resendConfirmationEmail(@PathVariable String email) {
        logger.info("GET: /api/auth/resend_conf_email/{}", email);

        var candidate = userRepository.findByEmail(email);

        if (candidate.isPresent()) {
            var user = candidate.get();
            if (!candidate.get().isVerified()) {
                String code = verificationCodeGenerator.generate(email);
                user.setVerificationCode(code);
                try {
                    emailService.sendVerificationEmail(email, code);
                } catch (Exception e) {
                    e.printStackTrace();
                    return new ResponseEntity<>(new MessageResponse("Error, check your email"), HttpStatus.BAD_REQUEST);
                }
                userRepository.save(user);
                logger.info("Resend confirmation email for User {} success!", email);
                return ResponseEntity.ok(new MessageResponse("Confirmation code was sent you by email"));
            } else {
                logger.info("Resend confirmation email for User {} failed! Account is already verified", email);
                return new ResponseEntity<>(new MessageResponse("Account is already verified"), HttpStatus.BAD_REQUEST);
            }
        } else {
            logger.info("User with email {} not found", email);
            return new ResponseEntity<>(new MessageResponse("User with such email doesnt exists"), HttpStatus.BAD_REQUEST);
        }
    }

    @PostMapping("/verify")
    public ResponseEntity verifyUser(@Valid @RequestBody VerificationRequestDto dto) {
        var candidate = userRepository.findByEmail(dto.getEmail());
        logger.info("POST: /api/auth/verify {}", dto.toString());
        if (candidate.isPresent()) {
            var user = candidate.get();
            if (user.getVerificationCode().equals(dto.getCode())) {
                user.setVerified(true);
                userRepository.save(user);
                logger.info("Account for user {} is successfully verified", dto.getEmail());
                return ResponseEntity.ok(new MessageResponse("Account is verified!"));
            } else {
                logger.info("Verification for user {} failed, wrong verification code", dto.getEmail());
                return new ResponseEntity(new MessageResponse("Wrong verification code"), HttpStatus.BAD_REQUEST);
            }
        } else {
            logger.info("User with email: {} not found", dto.getEmail());
            return new ResponseEntity(new MessageResponse("There is no user with such email"), HttpStatus.BAD_REQUEST);
        }
    }

    /**
     * Accepts register request
     * @param newUser new user's credentials
     * @return ResponseEntity&lt;MessageResponse&gt; with failure or success message
     */
    @PostMapping("/signup")
    public ResponseEntity<?> registerUser(@Valid @RequestBody NewUser newUser) {
        logger.info("POST: /api/auth/signup : {}", newUser.toString());
        try {
            var user = authControllerService.createUser(newUser, List.of("ROLE_USER"), !isVerificationEnabled, isVerificationEnabled);
            return ResponseEntity.ok(MessageResponse.of("User registered successfully!"));
        } catch (Exception ex) {
            return new ResponseEntity<>(MessageResponse.of(ex.getMessage()), HttpStatus.BAD_REQUEST);
        }
    }

}
