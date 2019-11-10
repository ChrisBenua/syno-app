package com.syno_back.backend.dto;

import com.fasterxml.jackson.annotation.JsonProperty;

import java.io.Serializable;

public class MessageResponse implements Serializable {
    @JsonProperty("message")
    private String message;

    public MessageResponse(String message) {
        this.message = message;
    }

    public MessageResponse() {
    }

    public String getMessage() {
        return message;
    }

    public static MessageResponse of(String message) {
        return new MessageResponse(message);
    }
}
