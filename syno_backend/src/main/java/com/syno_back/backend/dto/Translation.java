package com.syno_back.backend.dto;


import com.fasterxml.jackson.annotation.JsonProperty;
import com.syno_back.backend.model.DbTranslation;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * DTO for returning <code>DbTranslation</code> to client
 */
@Builder
@AllArgsConstructor
@Getter
public class Translation implements Serializable {
    /**
     * Server's DB id
     */
    @JsonProperty("id")
    private Long id;

    /**
     * Unique <code>DbTranslation</code> id
     */
    @JsonProperty("pin")
    private String pin;

    /**
     * Actual translation
     */
    @JsonProperty("translation")
    private String translation;

    /**
     * User's comment
     */
    @JsonProperty("comment")
    private String comment;

    /**
     * Translation's transcription
     */
    @JsonProperty("transcription")
    private String transcription;

    /**
     * Usage sample for translation
     */
    @JsonProperty("usage_sample")
    private String usageSample;

    /**
     * Timestamp when translation was created
     */
    @JsonProperty("time_created")
    private LocalDateTime timeCreated;

    /**
     * Timestamp when translation was modified
     */
    @JsonProperty("time_modified")
    private LocalDateTime timeModified;

    private static final long serialVersionUID = -1238970284520387974L;

}
