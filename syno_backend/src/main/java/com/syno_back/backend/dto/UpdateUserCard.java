package com.syno_back.backend.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.syno_back.backend.model.DbUserCard;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.NoArgsConstructor;

import java.util.HashMap;
import java.util.List;

@Builder
@AllArgsConstructor
@NoArgsConstructor
public class UpdateUserCard {

    @JsonProperty("id")
    private Long id;

    @JsonProperty("translated_word")
    private String translatedWord;

    @JsonProperty("translations")
    private List<UpdateUserTranslation> translations;

    public Long getId() {
        return id;
    }

    public String getTranslatedWord() {
        return translatedWord;
    }

    public List<UpdateUserTranslation> getTranslations() {
        return translations;
    }

}
