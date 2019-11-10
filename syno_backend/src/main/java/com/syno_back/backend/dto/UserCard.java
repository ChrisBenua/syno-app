package com.syno_back.backend.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.syno_back.backend.model.DbTranslation;
import com.syno_back.backend.model.DbUserCard;

import java.io.Serializable;
import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

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

    public UserCard(Long id, String translatedWord, String language, LocalDateTime timeCreated, LocalDateTime timeModified, List<Translation> translations) {
        this.id = id;
        this.translatedWord = translatedWord;
        this.language = language;
        this.timeCreated = timeCreated;
        this.timeModified = timeModified;
        this.translations = translations;
    }

    public UserCard(DbUserCard userCard) {
        this(userCard.getId(), userCard.getTranslatedWord(), userCard.getLanguage(), userCard.getTimeCreated(), userCard.getTimeModified(), userCard.getTranslations().stream().map(Translation::new).collect(Collectors.toList()));
    }

    private static final long serialVersionUID = -1264970284520387974L;

}
