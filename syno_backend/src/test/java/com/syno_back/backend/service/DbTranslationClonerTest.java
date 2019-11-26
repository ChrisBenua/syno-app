package com.syno_back.backend.service;

import com.syno_back.backend.model.DbTranslation;
import com.syno_back.backend.model.DbUserCard;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

class DbTranslationClonerTest {

    private DbTranslationCloner cloner;

    @BeforeEach
    void setUp() {
        cloner = new DbTranslationCloner();
    }

    @Test
    void testClone() {
        DbUserCard card = DbUserCard.builder().id(3L).build();
        DbTranslation trans = DbTranslation.builder().comment("c")
                .translation("tr")
                .transcription("transcr")
                .usageSample("sample")
                .id(2L).sourceCard(card).build();
        card.addTranslation(trans);

        DbTranslation result = cloner.clone(trans);

        assertEquals(result.getUsageSample(), trans.getUsageSample());
        assertEquals(result.getTranslation(), trans.getTranslation());
        assertEquals(result.getTranscription(), trans.getTranscription());
        assertEquals(result.getComment(), trans.getComment());
        assertNull(result.getSourceCard());
        assertNull(result.getId());
    }
}