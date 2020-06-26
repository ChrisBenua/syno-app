package com.syno_back.backend.dto;

import lombok.Data;

import java.io.Serializable;

@Data
public class VerificationRequestDto implements Serializable {
    private String email;

    private String code;
}
