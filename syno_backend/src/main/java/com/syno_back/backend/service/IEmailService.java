package com.syno_back.backend.service;

import javax.mail.MessagingException;

public interface IEmailService {
    void sendVerificationEmail(String email, String code) throws Exception;
}
