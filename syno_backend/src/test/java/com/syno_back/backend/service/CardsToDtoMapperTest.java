package com.syno_back.backend.service;

import com.syno_back.backend.model.DbTranslation;
import com.syno_back.backend.model.DbUserCard;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.time.LocalDateTime;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

class CardsToDtoMapperTest {

    private CardsToDtoMapper mapper;

    @BeforeEach
    void setUp() {
        mapper = new CardsToDtoMapper(new TranslationToDtoMapper());
    }

    @Test
    void convert() {
        DbUserCard card = DbUserCard.builder().id(1L).language("lan").translatedWord("word")
                .translations(List.of(DbTranslation.builder().id(2L).usageSample("s").comment("c").transcription("t")
                        .translation("tr").timeCreated(LocalDateTime.now()).timeModified(LocalDateTime.now()).build()))
                .timeCreated(LocalDateTime.now()).timeModified(LocalDateTime.now()).build();
        var result = mapper.convert(card, null);

        assertEquals(result.getId(), card.getId());
        assertEquals(result.getLanguage(), card.getLanguage());
        assertEquals(result.getTimeCreated(), card.getTimeCreated());
        assertEquals(result.getTimeModified(), card.getTimeModified());
        assertEquals(result.getTranslatedWord(), card.getTranslatedWord());
        assertEquals(result.getTranslations().size(), 1);

        for (int i = 0; i < card.getTranslations().size(); ++i) {
            assertEquals(result.getTranslations().get(i).getId(), card.getTranslations().get(i).getId());
            assertEquals(result.getTranslations().get(i).getComment(), card.getTranslations().get(i).getComment());
            assertEquals(result.getTranslations().get(i).getTimeCreated(), card.getTranslations().get(i).getTimeCreated());
            assertEquals(result.getTranslations().get(i).getTimeModified(), card.getTranslations().get(i).getTimeModified());
            assertEquals(result.getTranslations().get(i).getComment(), card.getTranslations().get(i).getComment());
            assertEquals(result.getTranslations().get(i).getTranslation(), card.getTranslations().get(i).getTranslation());
            assertEquals(result.getTranslations().get(i).getUsageSample(), card.getTranslations().get(i).getUsageSample());
        }
    }
}