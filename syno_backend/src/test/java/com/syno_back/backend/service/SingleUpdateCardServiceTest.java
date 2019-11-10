package com.syno_back.backend.service;

import com.syno_back.backend.datasource.DbUserCardRepository;
import com.syno_back.backend.dto.UpdateUserCard;
import com.syno_back.backend.model.DbUserCard;
import org.junit.jupiter.api.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.context.TestConfiguration;
import org.springframework.context.annotation.Bean;
import org.springframework.test.context.junit4.SpringRunner;

import static org.junit.jupiter.api.Assertions.*;

@RunWith(SpringRunner.class)
@SpringBootTest
class SingleUpdateCardServiceTest {

    @Autowired
    private SingleUpdateCardService updater;

    @org.springframework.boot.test.context.TestConfiguration
    static class ContextConfiguration {
    }

    @Test
    void update() {
        var userDbCard = DbUserCard.builder().language("Ru-En").translatedWord("word")
                .id(1L)
                .build();

        var updateUserCard = UpdateUserCard.builder()
                .language("En-Ru")
                .id(userDbCard.getId())
                .translatedWord("new_word").build();
        updater.update(updateUserCard, userDbCard);

        assertEquals(userDbCard.getId(), updateUserCard.getId());
        assertEquals(userDbCard.getTranslatedWord(), updateUserCard.getTranslatedWord());
        assertEquals(userDbCard.getLanguage(), updateUserCard.getLanguage());
    }
}