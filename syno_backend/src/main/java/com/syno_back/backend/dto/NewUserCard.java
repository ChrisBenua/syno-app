package com.syno_back.backend.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.syno_back.backend.model.DbUserCard;
import com.syno_back.backend.model.DbUserDictionary;
import lombok.*;

import java.io.Serializable;
import java.util.List;
import java.util.stream.Collectors;

@Builder
@AllArgsConstructor
@NoArgsConstructor
@Getter
public class NewUserCard implements Serializable {

    @JsonProperty("translated_word")
    private String translatedWord;

    @JsonProperty("pin")
    private String pin;

    @JsonProperty("translations")
    private List<NewUserTranslation> translations;
}
