package com.syno_back.backend.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.syno_back.backend.model.DbTranslation;
import com.syno_back.backend.model.DbUserCard;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.io.Serializable;

@Builder
@AllArgsConstructor
@NoArgsConstructor
@Getter
public class NewUserTranslation implements Serializable {

    @JsonProperty("translation")
    private String translation;

    @JsonProperty("comment")
    private String comment;

    @JsonProperty("transcription")
    private String transcription;

    @JsonProperty("usage_sample")
    private String usageSample;
}
