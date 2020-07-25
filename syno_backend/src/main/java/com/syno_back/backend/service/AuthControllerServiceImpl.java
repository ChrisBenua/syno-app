package com.syno_back.backend.service;

import com.syno_back.backend.datasource.RolesRepository;
import com.syno_back.backend.datasource.UserRepository;
import com.syno_back.backend.dto.NewUser;
import com.syno_back.backend.model.DbUser;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.stream.Collectors;

@Component
public class AuthControllerServiceImpl implements IAuthControllerService {
    private static final Logger logger = LoggerFactory.getLogger(AuthControllerServiceImpl.class);

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private IEmailService emailService;

    @Autowired
    private IVerificationCodeGenerator verificationCodeGenerator;

    @Autowired
    private RolesRepository rolesRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Override
    public DbUser createUser(NewUser newUser, List<String> roles, boolean isVerified, boolean sendEmail) {
        var candidate = userRepository.findByEmail(newUser.getEmail());
        if (candidate.isEmpty()) {
            //additional checking
            var user = new DbUser(newUser.getEmail(), passwordEncoder.encode(newUser.getPassword()));
            var newUserRoles = roles.stream().map(role -> rolesRepository.findByName(role)).collect(Collectors.toList());
            user.setRoles(newUserRoles);

            if (sendEmail && !isVerified) {
                user.setVerified(false);
                String code = verificationCodeGenerator.generate(newUser.getEmail());
                user.setVerificationCode(code);
                try {
                    emailService.sendVerificationEmail(newUser.getEmail(), code);
                } catch (Exception e) {
                    e.printStackTrace();
                    throw new RuntimeException("Error, check your email");
                }
            } else {
                user.setVerified(isVerified);
            }
            userRepository.save(user);

            logger.info("User {} is registered now!", newUser.getEmail());

            return user;
        } else {
            logger.info("User with email: {} already exists", newUser.getEmail());
            throw new RuntimeException("User already exists!");
        }
    }
}
