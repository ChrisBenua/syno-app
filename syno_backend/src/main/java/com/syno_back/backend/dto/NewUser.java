package com.syno_back.backend.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.io.Serializable;

/**
 * DTO for accepting new user credentials
 */
@AllArgsConstructor
@NoArgsConstructor
@Getter
public class NewUser implements Serializable {
    /**
     * New user's email
     */
    @JsonProperty("email")
    private String email;

    /**
     * New user's password
     */
    @JsonProperty("password")
    private String password;

    private static final long serialVersionUID = -1764970284520387975L;
}
