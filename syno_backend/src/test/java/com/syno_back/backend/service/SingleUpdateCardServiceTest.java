package com.syno_back.backend.service;

import com.syno_back.backend.dto.UpdateUserCard;
import com.syno_back.backend.model.DbUserCard;
import org.junit.jupiter.api.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.junit4.SpringRunner;

import static org.junit.jupiter.api.Assertions.*;

@RunWith(SpringRunner.class)
@SpringBootTest
@ActiveProfiles("test")
class SingleUpdateCardServiceTest {

    @Autowired
    private SingleUpdateCardService updater;

    @Test
    void update() {
        var userDbCard = DbUserCard.builder().translatedWord("word")
                .id(1L)
                .build();

        var updateUserCard = UpdateUserCard.builder()
                .id(userDbCard.getId())
                .translatedWord("new_word").build();
        updater.update(updateUserCard, userDbCard);

        assertEquals(userDbCard.getId(), updateUserCard.getId());
        assertEquals(userDbCard.getTranslatedWord(), updateUserCard.getTranslatedWord());
    }
}