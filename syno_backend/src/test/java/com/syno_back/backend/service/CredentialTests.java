package com.syno_back.backend.service;

import com.syno_back.backend.model.DbTranslation;
import com.syno_back.backend.model.DbUser;
import com.syno_back.backend.model.DbUserCard;
import com.syno_back.backend.model.DbUserDictionary;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.userdetails.User;

import java.util.ArrayList;

import static org.junit.jupiter.api.Assertions.*;


public class CredentialTests {

    private UserDictionaryCredentialProvider dictionaryCredentialProvider;

    private UserCardCredentialProvider cardCredentialProvider;

    private TranslationCredentialProvider translationCredentialProvider;

    @BeforeEach
    void setUp() {
        dictionaryCredentialProvider = new UserDictionaryCredentialProvider();
        cardCredentialProvider = new UserCardCredentialProvider();
        translationCredentialProvider = new TranslationCredentialProvider();
    }

    @Test
    void testDictionaryCredentialProvider() {
        Authentication auth = new UsernamePasswordAuthenticationToken(new User("email", "123", new ArrayList<GrantedAuthority>()), null);
        DbUser user = DbUser.builder().email("email").password("123").id(1L).build();
        DbUserDictionary dict = DbUserDictionary.builder().name("name").owner(user).id(2L).build();


        assertTrue(dictionaryCredentialProvider.check(dict, auth));
        Authentication falseAuth = new UsernamePasswordAuthenticationToken(new User("falseemail", "123", new ArrayList<GrantedAuthority>()), null);
        assertFalse(dictionaryCredentialProvider.check(dict, falseAuth));
    }

    @Test
    void testCardCredentialProvider() {
        DbUser user = DbUser.builder().email("email").password("123").id(1L).build();
        DbUserDictionary dict = DbUserDictionary.builder().name("name").owner(user).id(2L).build();
        DbUserDictionary fakeDict = DbUserDictionary.builder().name("name").owner(user).id(4L).build();
        DbUserCard card = DbUserCard.builder().language("lan").translatedWord("word").id(3L).userDictionary(dict).build();

        assertTrue(cardCredentialProvider.check(card, dict));
        assertFalse(cardCredentialProvider.check(card, fakeDict));
    }

    @Test
    void testTranslationCredentialProvider() {
        DbUserCard card = DbUserCard.builder().language("lan").translatedWord("word").id(3L).build();
        DbUserCard fakeCard = DbUserCard.builder().language("lan").translatedWord("word").id(4L).build();

        DbTranslation translation = DbTranslation.builder().usageSample("sample").comment("comment").transcription("trans").sourceCard(card).build();

        assertTrue(translationCredentialProvider.check(translation, card));
        assertFalse(translationCredentialProvider.check(translation, fakeCard));
    }
}
