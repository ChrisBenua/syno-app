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


    @BeforeEach
    void setUp() {
        dictionaryCredentialProvider = new UserDictionaryCredentialProvider();
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
}
