package com.syno_back.backend.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@AllArgsConstructor
@NoArgsConstructor
@Getter
@Builder
public class UpdateUserTranslationDto {
    @JsonProperty("pin")
    private String pin;

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
}
