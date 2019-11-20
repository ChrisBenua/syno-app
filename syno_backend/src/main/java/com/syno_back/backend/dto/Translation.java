package com.syno_back.backend.dto;


import com.fasterxml.jackson.annotation.JsonProperty;
import com.syno_back.backend.model.DbTranslation;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;

import java.io.Serializable;
import java.time.LocalDateTime;

@Builder
@AllArgsConstructor
@Getter
public class Translation implements Serializable {

    @JsonProperty("id")
    private Long id;

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

    private static final long serialVersionUID = -1238970284520387974L;

}
