package com.syno_back.backend.dto;

import lombok.Data;
import lombok.ToString;

import javax.validation.constraints.Size;
import java.io.Serializable;

@Data
@ToString
public class VerificationRequestDto implements Serializable {
    @Size(max=100)
    private String email;

    @Size(max=6)
    private String code;
}
