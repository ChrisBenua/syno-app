package com.syno_back.backend.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.io.Serializable;

@AllArgsConstructor
@NoArgsConstructor
@Getter
public class NewUser implements Serializable {
    @JsonProperty("email")
    private String email;

    @JsonProperty("password")
    private String password;

    private static final long serialVersionUID = -1764970284520387975L;
}
