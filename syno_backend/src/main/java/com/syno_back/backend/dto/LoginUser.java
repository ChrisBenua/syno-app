package com.syno_back.backend.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.io.Serializable;
import java.util.Optional;

@AllArgsConstructor
@NoArgsConstructor
public class LoginUser implements Serializable {
    @JsonProperty("email")
    private String email;

    @JsonProperty("password")
    private String password;

    public Optional<String> getEmail() {
        return Optional.ofNullable(email);
    }

    public Optional<String> getPassword() {
        return Optional.ofNullable(password);
    }

    private static final long serialVersionUID = -1764970284520387975L;
}
