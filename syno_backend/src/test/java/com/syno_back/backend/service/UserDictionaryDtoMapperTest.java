package com.syno_back.backend.service;

import com.syno_back.backend.dto.NewUserDictionary;
import com.syno_back.backend.model.DbUser;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.data.util.Pair;

import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

class UserDictionaryDtoMapperTest {

    private UserDictionaryDtoMapper mapper;

    @BeforeEach
    void setUp() {
        mapper = new UserDictionaryDtoMapper();
    }

    @Test
    void convert() {
        var dto = new NewUserDictionary("name", "ru-en");
        var owner = DbUser.builder().email("email").password("pass").id(1L).build();

        var dbDict = mapper.convert(dto,  List.of(Pair.of("owner", owner)));

        assertEquals(dbDict.getName(), dto.getName());
        assertEquals(dbDict.getOwner(), owner);
    }

    @Test
    void noSuchMethodInBuilder() {
        var dto = new NewUserDictionary("name", "ru-en");
        var owner = DbUser.builder().email("email").password("pass").id(1L).build();
        assertThrows(RuntimeException.class, () -> mapper.convert(dto,  List.of(Pair.of("OwNer", owner))));
    }
}