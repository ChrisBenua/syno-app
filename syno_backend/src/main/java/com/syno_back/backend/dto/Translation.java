package com.syno_back.backend.dto;


import com.fasterxml.jackson.annotation.JsonProperty;
import com.syno_back.backend.model.DbTranslation;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.ToString;

import javax.validation.constraints.Size;
import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * DTO for returning <code>DbTranslation</code> to client
 */
@Builder
@AllArgsConstructor
@Getter
@ToString
public class Translation implements Serializable {
    /**
     * Server's DB id
     */
    @Size(max=100)
    @JsonProperty("id")
    private Long id;

    /**
     * Unique <code>DbTranslation</code> id
     */
    @Size(max=100)
    @JsonProperty("pin")
    private String pin;

    /**
     * Actual translation
     */
    @Size(max=100)
    @JsonProperty("translation")
    private String translation;

    /**
     * User's comment
     */
    @Size(max=100)
    @JsonProperty("comment")
    private String comment;

    /**
     * Translation's transcription
     */
    @Size(max=100)
    @JsonProperty("transcription")
    private String transcription;

    /**
     * Usage sample for translation
     */
    @Size(max=100)
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
