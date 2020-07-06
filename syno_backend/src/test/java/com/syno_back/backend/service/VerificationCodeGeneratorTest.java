package com.syno_back.backend.service;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

class VerificationCodeGeneratorTest {

    @Test
    void generate() {
        var verification = new VerificationCodeGenerator();
        assertEquals(verification.generate("").length(), 6);
    }
}