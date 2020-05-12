package com.syno_back.backend.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * DTO for updating <code>DbTranslation</code>
 */
@AllArgsConstructor
@NoArgsConstructor
@Getter
@Builder
public class UpdateUserTranslationDto {
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
     * Usage sample
     */
    @JsonProperty("usage_sample")
    private String usageSample;

    /**
     * Time when translation was created
     */
    @JsonProperty("time_created")
    private LocalDateTime timeCreated;

    /**
     * Time when translation was modified
     */
    @JsonProperty("time_modified")
    private LocalDateTime timeModified;
}
