package com.syno_back.backend.service;

import com.syno_back.backend.datasource.DbDictShareRepository;
import com.syno_back.backend.model.DbDictShare;
import com.syno_back.backend.model.DbUser;
import com.syno_back.backend.model.DbUserDictionary;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.Mock;
import org.mockito.Mockito;
import org.mockito.MockitoAnnotations;

import java.util.Optional;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;

class DictShareServiceTest {

    private DictShareService shareService;

    @Mock
    private DbDictShareRepository repository;

    @BeforeEach
    void setUp() {
        MockitoAnnotations.initMocks(this);
        var mockDictShare = DbDictShare.builder().id(1L).sharedDictionary(DbUserDictionary.builder().id(3L).build()).build();
        Mockito.when(repository.save(mockDictShare)).thenReturn(mockDictShare);
        shareService = new DictShareService(repository, dictionary ->
                DbDictShare.builder().owner(dictionary.getOwner()).sharedDictionary(dictionary).id(1L).build());
    }

    @Test
    void getDictShareCodeCreateNew() {
        Mockito.when(repository.findById(1L)).thenReturn(Optional.empty());
        var dict = DbUserDictionary.builder().name("name").owner(DbUser.builder().id(3L).build()).id(1L).build();
        String uuidStr = shareService.getDictShareCode(dict);
        Mockito.verify(repository, Mockito.times(1)).save(DbDictShare.builder().id(1L).sharedDictionary(dict).build());

        assertEquals(uuidStr, UUID.nameUUIDFromBytes("3".getBytes()).toString());
    }


    @Test
    void getDictShareCodeReturnOld() {
        var dict = DbUserDictionary.builder().name("name").owner(DbUser.builder().id(3L).build()).id(12L).build();
        var existingShare = DbDictShare.builder().id(1L).sharedDictionary(dict).build();
        Mockito.when(repository.findBySharedDictionary_Id(12L)).thenReturn(Optional.of(existingShare));
        String uuidStr = shareService.getDictShareCode(dict);
        Mockito.verify(repository, Mockito.times(0)).save(DbDictShare.builder().id(1L).sharedDictionary(dict).build());

        assertEquals(uuidStr, UUID.nameUUIDFromBytes("12".getBytes()).toString());
    }
}