package com.syno_back.backend.service;

public interface IVerificationCodeGenerator {
    String generate(String email);
}
