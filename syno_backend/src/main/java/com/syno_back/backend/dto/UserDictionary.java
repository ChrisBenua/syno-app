package com.syno_back.backend.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.syno_back.backend.model.DbUserDictionary;
import lombok.AllArgsConstructor;
import lombok.Builder;

import java.io.Serializable;
import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Builder
@AllArgsConstructor
public class UserDictionary implements Serializable {
    @JsonProperty("id")
    private Long id;

    @JsonProperty("name")
    private String name;

    @JsonProperty("time_created")
    private LocalDateTime timeCreated;

    @JsonProperty("time_modified")
    private LocalDateTime timeModified;

    @JsonProperty("user_cards")
    private List<UserCard> userCards;

    public UserDictionary(DbUserDictionary userDictionary) {
        this(userDictionary.getId(), userDictionary.getName(), userDictionary.getTimeCreated(), userDictionary.getTimeModified(), userDictionary.getUserCards().stream().map(UserCard::new).collect(Collectors.toList()));
    }

    private static final long serialVersionUID = -1664970284520387974L;
}
