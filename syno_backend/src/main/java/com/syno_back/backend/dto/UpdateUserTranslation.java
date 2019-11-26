package com.syno_back.backend.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.syno_back.backend.model.DbTranslation;
import lombok.Builder;
import lombok.NoArgsConstructor;

@NoArgsConstructor
public class UpdateUserTranslation extends NewUserTranslation {
    @JsonProperty("id")
    private Long id;

    public UpdateUserTranslation(String translation, String comment, String transcription, String usageSample, Long id) {
        super(translation, comment, transcription, usageSample);
        this.id = id;
    }

    public Long getId() {
        return id;
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
        return this.getId().hashCode();
    }
}
