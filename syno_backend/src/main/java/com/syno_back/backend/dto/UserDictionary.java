package com.syno_back.backend.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.syno_back.backend.model.DbUserDictionary;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;

import java.io.Serializable;
import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Builder
@AllArgsConstructor
@Getter
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

    private static final long serialVersionUID = -1664970284520387974L;
}
