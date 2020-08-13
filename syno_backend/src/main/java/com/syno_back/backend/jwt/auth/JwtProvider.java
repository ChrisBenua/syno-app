package com.syno_back.backend.jwt.auth;

import io.jsonwebtoken.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.util.Date;

@Component
public class JwtProvider {
    private final Logger logger = LoggerFactory.getLogger(JwtProvider.class);

    /**
     * JWT secret value
     */
    @Value("${assm.app.jwtSecret}")
    private String jwtSecret;

    /**
     * JWT token expiration time
     */
    @Value("${assm.app.jwtExpiration}")
    private Integer jwtExpiration = 0;

    /**
     * Generates jwt token
     * @param email user's email
     * @return JWT token
     */
    public String generateJwtToken(String email) {
        return Jwts.builder()
                .setSubject(email)
                .setIssuedAt(new Date())
                .setExpiration(new Date(new Date().getTime() + jwtExpiration * 1000))
                .signWith(SignatureAlgorithm.HS512, jwtSecret)
                .compact();
    }

    /**
     * Validates JWT token
     * @param authToken JWT token
     * @return true if token is valid false otherwise
     */
    public boolean validateJwtToken(String authToken) {
        try {
            Jwts.parser().setSigningKey(jwtSecret).setAllowedClockSkewSeconds(jwtExpiration).parseClaimsJws(authToken);
            return true;
        } catch (SignatureException e) {
            logger.error(String.format("Invalid JwtSignature: error: %s", e.getMessage()));
        } catch (MalformedJwtException e) {
            logger.error(String.format("Invalid JwtToken: error: %s", e.getMessage()));
        } catch (ExpiredJwtException e) {
            logger.error(String.format("Expired JWT token: error: %s", e.getMessage()));
        } catch (UnsupportedJwtException e) {
            logger.error(String.format("Unsupported JWT token: error: %s", e.getMessage()));
        } catch (IllegalArgumentException e) {
            logger.error(String.format("JWT claims string is empty: error: %s", e.getMessage()));
        }

        return false;
    }

    /**
     * Gets email from JWT token
     * @param token JWT token
     * @return Subject's email
     */
    public String getEmailFromJwtToken(String token) {
        return Jwts.parser().setSigningKey(jwtSecret).parseClaimsJws(token).getBody().getSubject();
    }
}
