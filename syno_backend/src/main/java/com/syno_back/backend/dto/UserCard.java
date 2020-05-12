package com.syno_back.backend.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.syno_back.backend.model.DbTranslation;
import com.syno_back.backend.model.DbUserCard;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;

import java.io.Serializable;
import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

/**
 * DTO for returning <code>DbUserCard</code> to client
 */
@Builder
@AllArgsConstructor
@Getter
public class UserCard implements Serializable {
    /**
     * Server instance id
     */
    @JsonProperty("id")
    private Long id;

    /**
     * Unique card id
     */
    @JsonProperty("pin")
    private String pin;

    /**
     * Actual translated word
     */
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
     * List of translation
     */
    @JsonProperty("translations")
    private List<Translation> translations;

    private static final long serialVersionUID = -1264970284520387974L;

}
