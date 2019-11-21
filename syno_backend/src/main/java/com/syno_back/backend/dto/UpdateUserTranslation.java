package com.syno_back.backend.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.syno_back.backend.model.DbTranslation;
import lombok.Builder;

public class UpdateUserTranslation extends NewUserTranslation {
    @JsonProperty("id")
    private Long id;

    public UpdateUserTranslation() {}

    public UpdateUserTranslation(String translation, String comment, String transcription, String usageSample, Long id) {
        super(translation, comment, transcription, usageSample);
        this.id = id;
    }

    public Long getId() {
        return id;
    }

    public void updateDbTranslation(DbTranslation translation) {
        translation.setTranslation(this.getTranslation());
        translation.setUsageSample(this.getUsageSample());
        translation.setTranscription(this.getTranscription());
        translation.setComment(this.getComment());

        //source card doesnt change at all
    }

    @Override
    public boolean equals(Object other) {
        if (other == null) {
            return false;
        }
        if (other instanceof UpdateUserTranslation) {
            return this.id.equals(((UpdateUserTranslation) other).getId());
        }
        return false;
    }

    @Override
    public int hashCode() {
        return 31;
    }
}
