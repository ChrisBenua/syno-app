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
public class UpdateUserCardDto {
    @JsonProperty("pin")
    private String pin;

    @JsonProperty("translated_word")
    private String translatedWord;

    @JsonProperty("time_created")
    private LocalDateTime timeCreated;

    @JsonProperty("time_modified")
    private LocalDateTime timeModified;

    @JsonProperty("translations")
    private List<UpdateUserTranslationDto> translations;
}
