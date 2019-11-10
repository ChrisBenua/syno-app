package com.syno_back.backend.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.syno_back.backend.model.DbUserCard;
import com.syno_back.backend.model.DbUserDictionary;

import java.io.Serializable;
import java.util.List;
import java.util.stream.Collectors;

public class NewUserCard implements Serializable {

    @JsonProperty("translatedWord")
    private String translatedWord;

    @JsonProperty("language")
    private String language;

    @JsonProperty("translations")
    private List<NewUserTranslation> translations;

    public NewUserCard(String translatedWord, String language, List<NewUserTranslation> translations) {
        this.translatedWord = translatedWord;
        this.language = language;
        this.translations = translations;
    }

    public NewUserCard() {}

    public String getTranslatedWord() {
        return translatedWord;
    }

    public String getLanguage() {
        return language;
    }

    public List<NewUserTranslation> getTranslations() {
        return translations;
    }

    public DbUserCard toDbUserCard(DbUserDictionary dictionary) {
        var card = new DbUserCard(translatedWord, language);
        var translations = this.translations.stream().map(trans -> trans.toDbTranslation(card));
        card.setTranslations(translations.collect(Collectors.toList()));
        card.setUserDictionary(dictionary);
        card.setLanguage(language);
        card.setTranslatedWord(translatedWord);

        return card;
    }
}
