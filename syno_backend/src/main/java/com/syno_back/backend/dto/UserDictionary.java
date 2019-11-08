package com.syno_back.backend.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.syno_back.backend.model.DbUserDictionary;

import java.io.Serializable;
import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

public class UserDictionary implements Serializable {
    @JsonProperty("name")
    private String name;

    @JsonProperty("time_created")
    private LocalDateTime timeCreated;

    @JsonProperty("time_modified")
    private LocalDateTime timeModified;

    @JsonProperty("user_cards")
    private List<UserCard> userCards;

    public UserDictionary(String name, LocalDateTime timeCreated, LocalDateTime timeModified, List<UserCard> userCards) {
        this.name = name;
        this.timeCreated = timeCreated;
        this.timeModified = timeModified;
        this.userCards = userCards;
    }

    public UserDictionary(DbUserDictionary userDictionary) {
        this(userDictionary.getName(), userDictionary.getTimeCreated(), userDictionary.getTimeModified(), userDictionary.getUserCards().stream().map(UserCard::new).collect(Collectors.toList()));
    }

    private static final long serialVersionUID = -1664970284520387974L;
}
