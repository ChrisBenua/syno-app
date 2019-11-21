package com.syno_back.backend.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.*;

import java.io.Serializable;

@Getter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class NewDictShare implements Serializable {
    @NonNull
    @JsonProperty("share_dict_id")
    private Long shareDictId;
}
