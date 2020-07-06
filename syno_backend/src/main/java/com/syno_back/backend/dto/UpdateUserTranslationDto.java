package com.syno_back.backend.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.*;

import javax.validation.constraints.Size;
import java.time.LocalDateTime;

/**
 * DTO for updating <code>DbTranslation</code>
 */
@AllArgsConstructor
@NoArgsConstructor
@Getter
@Builder
@ToString
public class UpdateUserTranslationDto {
    /**
     * Unique <code>DbTranslation</code> id
     */
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
     * Usage sample
     */
    @Size(max=100)
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
