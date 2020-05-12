package com.syno_back.backend.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;

/**
 * DTO for updating <code>DbUserDictionary</code>
 */
@AllArgsConstructor
@NoArgsConstructor
@Getter
@Builder
public class UpdateUserDictionaryDto {
    /**
     * Unique id for <code>DbUserDicionary</code>
     */
    @JsonProperty("pin")
    private String pin;

    /**
     * Dictionary name
     */
    @JsonProperty("name")
    private String name;

    /**
     * Dictionary language
     */
    @JsonProperty("language")
    private String language;

    /**
     * Time when dictionary was created
     */
    @JsonProperty("time_created")
    private LocalDateTime timeCreated;

    /**
     * Time when dictionary was modified
     */
    @JsonProperty("time_modified")
    private LocalDateTime timeModified;

    /**
     * List of dictionary cards
     */
    @JsonProperty("user_cards")
    private List<UpdateUserCardDto> userCards;
}
