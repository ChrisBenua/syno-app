package com.syno_back.backend.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.ToString;

import javax.validation.constraints.Size;
import java.io.Serializable;

/**
 * DTO for accepting new user credentials
 */
@AllArgsConstructor
@NoArgsConstructor
@Getter
@ToString
public class NewUser implements Serializable {
    /**
     * New user's email
     */
    @Size(max=100)
    @JsonProperty("email")
    private String email;

    /**
     * New user's password
     */
    @Size(max=100)
    @JsonProperty("password")
    @ToString.Exclude private String password;

    private static final long serialVersionUID = -1764970284520387975L;
}
