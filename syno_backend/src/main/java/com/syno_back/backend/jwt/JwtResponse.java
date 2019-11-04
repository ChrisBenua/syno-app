package com.syno_back.backend.jwt;

import org.springframework.security.core.GrantedAuthority;

import java.util.Collection;

public class JwtResponse {
    private String accessToken;
    private String email;
    private Collection<GrantedAuthority> authorities;
    public final String type = "Bearer";

    public JwtResponse(String accessToken, String email, Collection<GrantedAuthority> authorities) {
        this.accessToken = accessToken;
        this.email = email;
        this.authorities = authorities;
    }

    public String getAccessToken() {
        return accessToken;
    }

    public String getEmail() {
        return email;
    }

    public Collection<GrantedAuthority> getAuthorities() {
        return authorities;
    }
}
