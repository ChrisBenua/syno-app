package com.syno_back.backend.service;

import com.syno_back.backend.dto.NewUserTranslation;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

class TranslationDtoMapperTest {

    private TranslationDtoMapper mapper;

    @BeforeEach
    void setUp() {
        mapper = new TranslationDtoMapper();
    }

    @Test
    void convert() {
        var newTrans = NewUserTranslation.builder().comment("comment").transcription("transcr").translation("trans").usageSample("sample").build();
        var result = mapper.convert(newTrans, null);

        assertEquals(result.getComment(), newTrans.getComment());
        assertEquals(result.getUsageSample(), newTrans.getUsageSample());
        assertEquals(result.getTranscription(), newTrans.getTranscription());
        assertEquals(result.getTranslation(), newTrans.getTranslation());
        assertNull(result.getSourceCard());
    }
}