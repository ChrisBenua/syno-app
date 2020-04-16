package com.syno_back.backend.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;

@AllArgsConstructor
@NoArgsConstructor
@Getter
@Builder
public class UpdateUserDictionaryDto {
    @JsonProperty("pin")
    private String pin;

    @JsonProperty("name")
    private String name;

    @JsonProperty("language")
    private String language;

    @JsonProperty("time_created")
    private LocalDateTime timeCreated;

    @JsonProperty("time_modified")
    private LocalDateTime timeModified;

    @JsonProperty("user_cards")
    private List<UpdateUserCardDto> userCards;
}
