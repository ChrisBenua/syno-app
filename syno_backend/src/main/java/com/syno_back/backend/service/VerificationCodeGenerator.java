package com.syno_back.backend.service;

import org.springframework.stereotype.Service;

import java.util.Random;

@Service
public class VerificationCodeGenerator implements IVerificationCodeGenerator {
    private static final Random random = new Random();

    @Override
    public String generate(String email) {
        String val = String.valueOf(random.nextInt(100000));
        return "0".repeat(6 - val.length()) + val;
    }
}
