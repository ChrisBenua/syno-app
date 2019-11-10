package com.syno_back.backend.controllers;

import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.test.web.servlet.MockMvc;

import static org.junit.jupiter.api.Assertions.*;

@RunWith(SpringRunner.class)
@WebMvcTest(UserCardController.class)
@DataJpaTest
class UserCardControllerTest {

    @Autowired
    private MockMvc mvc;

    @BeforeEach
    public void beforeEach() {

    }

    @AfterEach
    public void afterEach() {

    }

    @Test
    void addCardToDictionary() {
    }

    @Test
    void getCardsFromDictionary() {
    }

    @Test
    void updateCardsFromDictionarySelective() {
    }
}