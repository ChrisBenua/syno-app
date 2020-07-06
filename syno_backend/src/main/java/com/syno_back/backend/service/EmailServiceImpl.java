package com.syno_back.backend.service;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import javax.annotation.PostConstruct;
import java.util.Properties;

import javax.mail.*;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeBodyPart;
import javax.mail.internet.MimeMessage;
import javax.mail.internet.MimeMultipart;


@Service
public class EmailServiceImpl implements IEmailService {
    @Value("${app.email.username}")
    private String techEmail;

    @Value("${app.email.password}")
    private String techEmailPassword;

    private final String host = "smtp.gmail.com";

    private final String port = "587";

    private Properties properties;

    public EmailServiceImpl() {
        properties = new Properties();
        properties.put("mail.smtp.auth", "true");
        properties.put("mail.smtp.starttls.enable", "true");
        properties.put("mail.smtp.host", host);
        properties.put("mail.smtp.port", port);
        properties.put("mail.smtp.ssl.trust", host);
    }

    @PostConstruct
    public void test() {
        System.out.println("tech team email " + techEmail);
        System.out.println("tech team password " + techEmailPassword);
    }

    public boolean isActive() {
        return techEmail != null && techEmailPassword != null;
    }

    @Override
    public void sendVerificationEmail(String email, String code) throws MessagingException {
        if (isActive()) {
            Session session = Session.getInstance(this.properties, new Authenticator() {
                @Override
                protected PasswordAuthentication getPasswordAuthentication() {
                    return new PasswordAuthentication(techEmail, techEmailPassword);
                }
            });
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(techEmail));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(email));
            message.setSubject("Account Verification");

            String msg = String.format(template, email, code);
            System.out.println(msg);

            MimeBodyPart mimeBodyPart = new MimeBodyPart();
            mimeBodyPart.setContent(msg, "text/html; charset=utf-8");

            Multipart multipart = new MimeMultipart();
            multipart.addBodyPart(mimeBodyPart);

            message.setContent(multipart);

            Transport.send(message);
        }
    }

    private static final String template = "<div><p>Hello, %s!</p>" +
            "<p>Confirm your account registration with this verification code: " +
            "<b>%s</b></p>" +
            "<p>Sincerely yours,<br>" +
            "Development Team</p></div>";
}
