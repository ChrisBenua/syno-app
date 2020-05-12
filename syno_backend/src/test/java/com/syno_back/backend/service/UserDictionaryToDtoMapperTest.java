package com.syno_back.backend.service;

import com.syno_back.backend.model.DbUser;
import com.syno_back.backend.model.DbUserCard;
import com.syno_back.backend.model.DbUserDictionary;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.time.LocalDateTime;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

class UserDictionaryToDtoMapperTest {

    private UserDictionaryToDtoMapper mapper;

    @BeforeEach
    void setUp() {
        this.mapper = new UserDictionaryToDtoMapper(new CardsToDtoMapper(new TranslationToDtoMapper()));
    }

    @Test
    void convert() {
        DbUserDictionary dict = DbUserDictionary.builder().id(1L).name("nm").timeCreated(LocalDateTime.now())
                .timeModified(LocalDateTime.now())
                .userCards(List.of(DbUserCard.builder().translatedWord("w").build()))
                .build();
        var result = mapper.convert(dict, null);

        assertEquals(result.getId(), dict.getId());
        assertEquals(result.getName(), dict.getName());
        assertEquals(result.getTimeCreated(), dict.getTimeCreated());
        assertEquals(result.getTimeModified(), dict.getTimeModified());
        assertEquals(result.getUserCards().size(), dict.getUserCards().size());
    }
}