package com.syno_back.backend.service;

import com.syno_back.backend.model.DbTranslation;
import com.syno_back.backend.model.DbUserCard;
import com.syno_back.backend.model.DbUserDictionary;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

class DbUserCardClonerTest {

    private DbUserCardCloner cloner;

    @BeforeEach
    void setUp() {
        cloner = new DbUserCardCloner(new DbTranslationCloner());
    }

    @Test
    void testClone() {
        DbUserDictionary dict = DbUserDictionary.builder().name("n").id(1L).build();
        DbUserCard card = DbUserCard.builder().id(2L)
                .translatedWord("word")
                .userDictionary(dict).build();
        dict.addUserCard(card);
        DbTranslation trans = DbTranslation.builder().id(3L)
                .usageSample("sample")
                .transcription("transcr")
                .translation("trans")
                .comment("comment")
                .build();
        card.addTranslation(trans);

        DbUserCard result = cloner.clone(card);
        result.setId(5L);

        assertEquals(result.getTranslatedWord(), card.getTranslatedWord());
        assertNull(result.getUserDictionary());
        assertEquals(result.getTranslations().size(), card.getTranslations().size());

        for (int i = 0; i < result.getTranslations().size(); ++i) {
            var checkTranslation = result.getTranslations().get(i);
            var standardTranslation = card.getTranslations().get(i);

            assertEquals(checkTranslation.getComment(), standardTranslation.getComment());
            assertEquals(checkTranslation.getTranscription(), standardTranslation.getTranscription());
            assertNotEquals(checkTranslation.getSourceCard(), standardTranslation.getSourceCard());
            assertEquals(checkTranslation.getTranslation(), standardTranslation.getTranslation());
            assertEquals(checkTranslation.getUsageSample(), standardTranslation.getUsageSample());
        }
    }
}