package com.syno_back.backend.model;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;


public class DbDictShareTest {

    @Test
    public void testSettersForBuilder() {
        var dict = DbUserDictionary.builder().name("name").id(1L).build();
        var dictShare = DbDictShare.builder().id(2L).sharedDictionary(dict).build();

        assertEquals(dictShare.getId(), 2L);
        assertEquals(dictShare.getSharedDictionary(), dict);
        assertEquals(dictShare.getShareUUID(), UUID.nameUUIDFromBytes("1".getBytes()));
    }
}
