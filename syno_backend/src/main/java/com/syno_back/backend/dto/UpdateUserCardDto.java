package com.syno_back.backend.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.*;

import javax.validation.constraints.Size;
import java.time.LocalDateTime;
import java.util.List;

/**
 * DTO for receiving update info for <code>DbUserCard</code>
 */
@AllArgsConstructor
@NoArgsConstructor
@Getter
@Builder
@ToString
public class UpdateUserCardDto {
    /**
     * Unique id for user card
     */
    @JsonProperty("pin")
    private String pin;

    /**
     * Actual translated word
     */
    @Size(max=100)
    @JsonProperty("translated_word")
    private String translatedWord;

    /**
     * Time when card was created
     */
    @JsonProperty("time_created")
    private LocalDateTime timeCreated;


    /**
     * Time when card was modified
     */
    @JsonProperty("time_modified")
    private LocalDateTime timeModified;

    /**
     * List of updated translation
     */
    @JsonProperty("translations")
    private List<UpdateUserTranslationDto> translations;
}
