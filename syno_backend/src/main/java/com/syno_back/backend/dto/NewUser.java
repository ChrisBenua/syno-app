package com.syno_back.backend.dto;

import com.fasterxml.jackson.annotation.JsonProperty;

import java.io.Serializable;

public class NewUser implements Serializable {
    @JsonProperty("email")
    private String email;

    @JsonProperty("password")
    private String password;

    public NewUser() {}

    public NewUser(String email, String password) {
        this.email = email;
        this.password = password;
    }

    public String getEmail() {
        return email;
    }

    public String getPassword() {
        return password;
    }

    private static final long serialVersionUID = -1764970284520387975L;
}
