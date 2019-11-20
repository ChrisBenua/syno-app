package com.syno_back.backend.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.NoArgsConstructor;

import java.io.Serializable;

@AllArgsConstructor
@NoArgsConstructor
public class MessageResponse implements Serializable {
    @JsonProperty("message")
    private String message;

    public String getMessage() {
        return message;
    }

    public static MessageResponse of(String message) {
        return new MessageResponse(message);
    }
}
