package com.syno_back.backend.service;

import com.syno_back.backend.datasource.DbTranslationRepository;
import com.syno_back.backend.datasource.DbUserCardRepository;
import com.syno_back.backend.dto.UpdateUserTranslation;
import com.syno_back.backend.exception.DbOwnerViolated;
import com.syno_back.backend.model.DbTranslation;
import com.syno_back.backend.model.DbUserCard;
import lombok.val;
import org.assertj.core.groups.Tuple;
import org.hibernate.sql.Update;
import org.junit.jupiter.api.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;
import org.springframework.boot.test.context.TestConfiguration;
import org.springframework.context.annotation.Bean;
import org.springframework.test.context.junit4.SpringRunner;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

@RunWith(SpringRunner.class)
@DataJpaTest
class BatchUpdateTranslationServiceTest {

    private static final int perCard = 5;
    private static final int allTranslationsCount = perCard * 2;

    @TestConfiguration
    static class ContextConfiguration {
        @Bean
        public ISingleUpdateService<DbTranslation, UpdateUserTranslation> singleUpdateTranslationService() {
            return new SingleUpdateTranslationService();
        }

        @Bean
        public BatchUpdateTranslationService batchUpdateTranslationService() {
            return new BatchUpdateTranslationService();
        }
    }

    @Autowired
    private BatchUpdateTranslationService updater;

    @Autowired
    private DbTranslationRepository repository;

    @Autowired
    private DbUserCardRepository cardRepository;

    private Tuple fillOk() {
        var card1 = DbUserCard.builder()
                .language("Ru1")
                .translatedWord("word1").build();
        cardRepository.save(card1);

        var card2 = DbUserCard.builder()
                .language("Ru2")
                .translatedWord("word2").build();
        cardRepository.save(card2);
        cardRepository.flush();

        var cards = new DbUserCard[]{card1, card2};



        List<DbTranslation> translations = new ArrayList<>();
        for (int i = 0; i < allTranslationsCount; ++i) {
            var trans = DbTranslation.builder()
                    .comment("comm_" + i)
                    .transcription("trasncr_" + i)
                    .usageSample("sample_" + i)
                    .translation("translation_" + i).build();
            cards[i / perCard].addTranslation(trans);
            translations.add(repository.save(trans));
        }

        repository.flush();
        cardRepository.flush();

        HashMap<Long, UpdateUserTranslation> updateUserTranslations = new HashMap<>();
        List<UpdateUserTranslation> updateUserTranslationList = new ArrayList<>();
        for (int i = 0; i < perCard; ++i) {
            var trans = new UpdateUserTranslation("newtrans_" + i, "newcomm_" + i,
                    "newtranscr_" + i, "newsample_" + i, translations.get(i).getId());
            updateUserTranslations.put(translations.get(i).getId(), trans);
            updateUserTranslationList.add(trans);
        }
        return new Tuple(updateUserTranslationList, updateUserTranslations, card1, translations);
    }

    @Test
    void updateWithOwnerCheckOk() {
        var tuple = fillOk().toList();

        var updateUserTranslationList = (List<UpdateUserTranslation>)tuple.get(0);
        var updateUserTranslations = (HashMap<Long, UpdateUserTranslation>)tuple.get(1);
        var card1 = (DbUserCard)tuple.get(2);


        updater.updateWithOwnerCheck(updateUserTranslationList, card1);
        repository.flush();

        card1.getTranslations().forEach(trans -> {
            var updateTrans = updateUserTranslations.get(trans.getId());
            assertEquals(updateTrans.getComment(), trans.getComment());
            assertEquals(updateTrans.getTranscription(), trans.getTranscription());
            assertEquals(updateTrans.getTranslation(), trans.getTranslation());
            assertEquals(updateTrans.getUsageSample(), trans.getUsageSample());
        });
    }


    @Test
    void updateWithOwnerCheckOtherNotAffected() {
        var tuple = fillOk().toList();

        var updateUserTranslationList = (List<UpdateUserTranslation>)tuple.get(0);
        var updateUserTranslations = (HashMap<Long, UpdateUserTranslation>)tuple.get(1);
        var card1 = (DbUserCard)tuple.get(2);


        updater.updateWithOwnerCheck(updateUserTranslationList.subList(2, 5), card1);
        repository.flush();

        card1.getTranslations().subList(0, 2).forEach(trans -> {
            var updateTrans = updateUserTranslations.get(trans.getId());
            assertNotEquals(updateTrans.getComment(), trans.getComment());
            assertNotEquals(updateTrans.getTranscription(), trans.getTranscription());
            assertNotEquals(updateTrans.getTranslation(), trans.getTranslation());
            assertNotEquals(updateTrans.getUsageSample(), trans.getUsageSample());
        });
        card1.getTranslations().subList(2, 5).forEach(trans -> {
            var updateTrans = updateUserTranslations.get(trans.getId());
            assertEquals(updateTrans.getComment(), trans.getComment());
            assertEquals(updateTrans.getTranscription(), trans.getTranscription());
            assertEquals(updateTrans.getTranslation(), trans.getTranslation());
            assertEquals(updateTrans.getUsageSample(), trans.getUsageSample());
        });
    }

    @Test
    void updateWithOwnerCheckNotOk() {
        var tuple = fillOk().toList();

        var updateUserTranslationList = (List<UpdateUserTranslation>)tuple.get(0);
        var updateUserTranslations = (HashMap<Long, UpdateUserTranslation>)tuple.get(1);
        var card1 = (DbUserCard)tuple.get(2);
        var translations = (List<DbTranslation>)tuple.get(3);

        var trans = new UpdateUserTranslation("newtrans_", "newcomm_",
                "newtranscr_", "newsample_", translations.get(perCard).getId());
        updateUserTranslations.put(translations.get(perCard).getId(), trans);
        updateUserTranslationList.add(trans);

        assertThrows(DbOwnerViolated.class, () -> updater.updateWithOwnerCheck(updateUserTranslationList, card1));

    }

    @Test
    void updateWith() {
        var tuple = fillOk().toList();

        var updateUserTranslationList = (List<UpdateUserTranslation>)tuple.get(0);
        var updateUserTranslations = (HashMap<Long, UpdateUserTranslation>)tuple.get(1);
        var card1 = (DbUserCard)tuple.get(2);


        updater.updateWith(updateUserTranslationList);
        repository.flush();

        card1.getTranslations().forEach(trans -> {
            var updateTrans = updateUserTranslations.get(trans.getId());
            assertEquals(updateTrans.getComment(), trans.getComment());
            assertEquals(updateTrans.getTranscription(), trans.getTranscription());
            assertEquals(updateTrans.getTranslation(), trans.getTranslation());
            assertEquals(updateTrans.getUsageSample(), trans.getUsageSample());
        });
    }
}