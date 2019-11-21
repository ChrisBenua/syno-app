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

@Builder
@AllArgsConstructor
@Getter
public class UserCard implements Serializable {
    @JsonProperty("id")
    private Long id;

    @JsonProperty("translated_word")
    private String translatedWord;

    @JsonProperty("language")
    private String language;

    @JsonProperty("time_created")
    private LocalDateTime timeCreated;

    @JsonProperty("time_modified")
    private LocalDateTime timeModified;

    @JsonProperty("translations")
    private List<Translation> translations;

    private static final long serialVersionUID = -1264970284520387974L;

}
