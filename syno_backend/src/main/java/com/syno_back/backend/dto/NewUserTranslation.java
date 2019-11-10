package com.syno_back.backend.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.syno_back.backend.model.DbTranslation;
import com.syno_back.backend.model.DbUserCard;
import lombok.Builder;

import java.io.Serializable;

@Builder
public class NewUserTranslation implements Serializable {

    @JsonProperty("translation")
    private String translation;

    @JsonProperty("comment")
    private String comment;

    @JsonProperty("transcription")
    private String transcription;

    @JsonProperty("usage_sample")
    private String usageSample;

    public NewUserTranslation(String translation, String comment, String transcription, String usageSample) {
        this.translation = translation;
        this.comment = comment;
        this.transcription = transcription;
        this.usageSample = usageSample;
    }

    public NewUserTranslation() {}

    public String getTranslation() {
        return translation;
    }

    public String getComment() {
        return comment;
    }

    public String getTranscription() {
        return transcription;
    }

    public String getUsageSample() {
        return usageSample;
    }

    public DbTranslation toDbTranslation(DbUserCard sourceCard) {
        var translation = new DbTranslation();
        translation.setSourceCard(sourceCard);
        translation.setComment(comment);
        translation.setTranscription(transcription);
        translation.setUsageSample(usageSample);
        translation.setTranslation(this.translation);

        return translation;
    }
}
