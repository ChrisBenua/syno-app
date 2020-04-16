package com.syno_back.backend.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.util.List;

@AllArgsConstructor
@NoArgsConstructor
@Getter
@Builder
public class UpdateRequestDto {
    @JsonProperty("existing_dict_pins")
    private List<String> existingDictPins;

    @JsonProperty("client_dicts")
    private List<UpdateUserDictionaryDto> clientDicts;
}
