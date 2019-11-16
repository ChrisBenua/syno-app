package com.syno_back.backend.service;

import com.syno_back.backend.dto.NewUserTranslation;
import com.syno_back.backend.model.DbUserCard;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

class TranslationsAdderServiceTest {

    private TranslationsAdderService adderService;

    @BeforeEach
    void setUp() {
        adderService = new TranslationsAdderService();
    }

    @Test
    void addTranslationsToCard() {
        DbUserCard card = DbUserCard.builder().translatedWord("w").language("r").id(1L).build();
        List<NewUserTranslation> translations = List.of(NewUserTranslation.builder().build(), NewUserTranslation.builder().build());

        adderService.addTranslationsToCard(translations, card);

        assertEquals(card.getTranslations().size(), 2);
        for (var trans : card.getTranslations()) {
            assertEquals(trans.getSourceCard(), card);
        }
    }
}