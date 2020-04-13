package com.syno_back.backend.service;

import com.syno_back.backend.dto.NewUser;
import com.syno_back.backend.dto.NewUserCard;
import com.syno_back.backend.dto.NewUserTranslation;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

class UserCardDtoMapperTest {

    private UserCardDtoMapper mapper;

    @BeforeEach
    void setUp() {
        mapper = new UserCardDtoMapper(new TranslationDtoMapper());
    }

    @Test
    void convert() {
        NewUserCard card = NewUserCard.builder().translatedWord("word").translations(List.of(
                NewUserTranslation.builder().translation("trans1").build(),
                NewUserTranslation.builder().translation("trans2").build()
        )).build();

        var result = mapper.convert(card, null);

        assertEquals(result.getTranslatedWord(), "word");
        assertEquals(result.getTranslations().size(), 2);
        assertEquals(result.getTranslations().get(0).getTranslation(), "trans1");
        assertEquals(result.getTranslations().get(1).getTranslation(), "trans2");
        assertEquals(result.getTranslations().get(0).getSourceCard().getTranslatedWord(), result.getTranslatedWord());
        assertEquals(result.getTranslations().get(1).getSourceCard().getTranslatedWord(), result.getTranslatedWord());
    }
}