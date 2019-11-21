package com.syno_back.backend.service;

import com.syno_back.backend.dto.UpdateUserTranslation;
import com.syno_back.backend.model.DbTranslation;
import org.junit.jupiter.api.Test;


import static org.junit.jupiter.api.Assertions.*;

class SingleUpdateTranslationServiceTest {
    SingleUpdateTranslationService updater = new SingleUpdateTranslationService();

    @Test
    void update() {
        DbTranslation translation = DbTranslation.builder().translation("apple")
                .transcription("apl")
                .comment("comment")
                .usageSample("sample")
                .id(1L).build();


        UpdateUserTranslation updateUserTranslation = new UpdateUserTranslation("newtrans", "newcomm",
        "newtranscr", "newsample", translation.getId());

        updater.update(updateUserTranslation, translation);

        assertEquals(updateUserTranslation.getComment(), translation.getComment());
        assertEquals(updateUserTranslation.getUsageSample(), translation.getUsageSample());
        assertEquals(updateUserTranslation.getTranslation(), translation.getTranslation());
        assertEquals(updateUserTranslation.getTranscription(), translation.getTranscription());
    }
}