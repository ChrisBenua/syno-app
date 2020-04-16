package com.syno_back.backend.service;

import com.syno_back.backend.model.DbTranslation;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.time.LocalDateTime;

import static org.junit.jupiter.api.Assertions.*;

class TranslationToDtoMapperTest {
    
    private TranslationToDtoMapper mapper;
    
    
    @BeforeEach
    void setUp() {
        this.mapper = new TranslationToDtoMapper();
    }
    
    @Test
    void convert() {
        DbTranslation translation = DbTranslation.builder().pin("pin").transcription("t").comment("c").translation("tr").id(1L)
                .usageSample("s").timeModified(LocalDateTime.now()).timeCreated(LocalDateTime.now()).build();
        var result = mapper.convert(translation, null);

        assertEquals(result.getId(), translation.getId());
        assertEquals(result.getPin(), "pin");
        assertEquals(result.getComment(), translation.getComment());
        assertEquals(result.getTimeCreated(), translation.getTimeCreated());
        assertEquals(result.getTimeModified(), translation.getTimeModified());
        assertEquals(result.getComment(), translation.getComment());
        assertEquals(result.getTranslation(), translation.getTranslation());
        assertEquals(result.getUsageSample(), translation.getUsageSample());
    }
}