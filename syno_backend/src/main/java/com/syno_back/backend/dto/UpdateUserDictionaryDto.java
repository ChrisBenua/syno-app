package com.syno_back.backend.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.*;

import javax.validation.constraints.Size;
import java.time.LocalDateTime;
import java.util.List;

/**
 * DTO for updating <code>DbUserDictionary</code>
 */
@AllArgsConstructor
@NoArgsConstructor
@Getter
@Builder
@ToString
public class UpdateUserDictionaryDto {
    /**
     * Unique id for <code>DbUserDicionary</code>
     */
    @JsonProperty("pin")
    private String pin;

    /**
     * Dictionary name
     */
    @Size(max=100)
    @JsonProperty("name")
    private String name;

    /**
     * Dictionary language
     */
    @Size(max=100)
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
