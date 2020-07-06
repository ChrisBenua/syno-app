package com.syno_back.backend.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.*;

import java.io.Serializable;

/**
 * DTO for accepting new dictionary shares
 */
@Getter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@ToString
public class NewDictShare implements Serializable {
    /**
     * Unique share's id
     */
    @NonNull
    @JsonProperty("share_dict_pin")
    private String shareDictPin;
}