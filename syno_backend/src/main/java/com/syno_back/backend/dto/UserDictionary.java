package com.syno_back.backend.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.syno_back.backend.model.DbUserDictionary;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.ToString;

import javax.validation.constraints.Size;
import java.io.Serializable;
import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

/**
 * DTO for returning <code>DbUserDictionary</code> to client
 */
@Builder
@AllArgsConstructor
@Getter
@ToString
public class UserDictionary implements Serializable {
    /**
     * Server's DB id
     */
    @JsonProperty("id")
    private Long id;

    /**
     * Unique <code>DbUserDictionary</code> id
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
     * List of user card
     */
    @JsonProperty("user_cards")
    private List<UserCard> userCards;

    private static final long serialVersionUID = -1664970284520387974L;
}
