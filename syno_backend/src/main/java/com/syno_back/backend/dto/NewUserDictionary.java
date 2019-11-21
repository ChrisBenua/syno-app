package com.syno_back.backend.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.io.Serializable;

@AllArgsConstructor
@NoArgsConstructor
@Getter
public class NewUserDictionary implements Serializable {
    @JsonProperty("name")
    private String name;

    private static final long serialVersionUID = -1264970284522287974L;
}
