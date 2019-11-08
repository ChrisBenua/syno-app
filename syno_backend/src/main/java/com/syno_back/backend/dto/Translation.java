package com.syno_back.backend.dto;


import com.fasterxml.jackson.annotation.JsonProperty;
import com.syno_back.backend.model.DbTranslation;

import java.io.Serializable;
import java.time.LocalDateTime;

public class Translation implements Serializable {
    @JsonProperty("translation")
    private String translation;

    @JsonProperty("comment")
    private String comment;

    @JsonProperty("transcription")
    private String transcription;

    @JsonProperty("usage_sample")
    private String usageSample;

    @JsonProperty("time_created")
    private LocalDateTime timeCreated;

    @JsonProperty("time_modified")
    private LocalDateTime timeModified;

    public Translation(String translation, String comment, String transcription, String usageSample, LocalDateTime timeCreated,
                       LocalDateTime timeModified) {
        this.translation = translation;
        this.transcription = transcription;
        this.comment = comment;
        this.usageSample = usageSample;
        this.timeModified = timeModified;
        this.timeCreated = timeCreated;
    }

    public Translation(DbTranslation translation) {
        this(translation.getTranslation(), translation.getComment(), translation.getTranscription(), translation.getUsageSample(),
                translation.getTimeCreated(), translation.getTimeModified());
    }

    private static final long serialVersionUID = -1238970284520387974L;

}
