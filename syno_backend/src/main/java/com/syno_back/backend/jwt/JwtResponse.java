package com.syno_back.backend.jwt;

import lombok.Getter;
import org.springframework.security.core.GrantedAuthority;

import java.util.Collection;

/**
 * DTO for returning auth details
 */
@Getter
public class JwtResponse {
    /**
     * JWT token
     */
    private String accessToken;
    /**
     * User's email
     */
    private String email;
    /**
     * User's roles
     */
    private Collection<GrantedAuthority> authorities;
    public final String type = "Bearer";

    /**
     * Creates new <code>JwtResponse</code>
     * @param accessToken JWT token
     * @param email User's email
     * @param authorities User's roles
     */
    public JwtResponse(String accessToken, String email, Collection<GrantedAuthority> authorities) {
        this.accessToken = accessToken;
        this.email = email;
        this.authorities = authorities;
    }
}
