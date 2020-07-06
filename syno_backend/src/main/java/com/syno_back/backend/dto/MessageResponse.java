package com.syno_back.backend.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.ToString;

import java.io.Serializable;

/**
 * Request response DTO with message inside
 */
@AllArgsConstructor
@NoArgsConstructor
@Getter
@ToString
public class MessageResponse implements Serializable {
    /**
     * Response message
     */
    @JsonProperty("message")
    private String message;

    /**
     * Generates <code>MessageResponse</code> with given message
     * @param message response message
     * @return new <code>MessageResponse</code> instance
     */
    public static MessageResponse of(String message) {
        return new MessageResponse(message);
    }
}
