package com.syno_back.backend.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.ToString;

import javax.validation.constraints.Size;
import java.io.Serializable;
import java.util.Optional;

/**
 * DTO for storing user's login credentials
 */
@AllArgsConstructor
@NoArgsConstructor
@ToString
public class LoginUser implements Serializable {
    /**
     * User's email
     */
    @Size(max=100)
    @JsonProperty("email")
    private String email;

    /**
     * User's password
     */
    @Size(max=100)
    @JsonProperty("password")
    private String password;

    /**
     * Gets user email
     * @return user's email
     */
    public Optional<String> getEmail() {
        return Optional.ofNullable(email);
    }

    /**
     * Gets user password
     * @return user's password
     */
    public Optional<String> getPassword() {
        return Optional.ofNullable(password);
    }

    private static final long serialVersionUID = -1764970284520387975L;
}
