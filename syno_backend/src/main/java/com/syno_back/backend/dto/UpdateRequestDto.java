package com.syno_back.backend.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.util.List;

/**
 * DTO for accepting update request from client
 */
@AllArgsConstructor
@NoArgsConstructor
@Getter
@Builder
public class UpdateRequestDto {
    /**
     * List of existing pins
     * Future pagination-friendly
     */
    @JsonProperty("existing_dict_pins")
    private List<String> existingDictPins;

    /**
     * List of updated dicts
     */
    @JsonProperty("client_dicts")
    private List<UpdateUserDictionaryDto> clientDicts;
}
