package com.syno_back.backend.service;

import com.syno_back.backend.model.DbTranslation;
import com.syno_back.backend.model.DbUser;
import com.syno_back.backend.model.DbUserCard;
import com.syno_back.backend.model.DbUserDictionary;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

class DbUserDictClonerTest {

    private DbUserDictCloner cloner;

    @BeforeEach
    void setUp() {
        cloner = new DbUserDictCloner(new DbUserCardCloner(new DbTranslationCloner()));
    }

    @Test
    void testClone() {
        DbUser user = DbUser.builder().id(1L).password("123").email("email").build();
        DbUserDictionary dict = DbUserDictionary.builder().id(2L).name("name").owner(user).build();
        DbUserCard card = DbUserCard.builder().translatedWord("word").id(3L).build();
        dict.addUserCard(card);
        user.addUserDictionary(dict);

        DbTranslation trans = DbTranslation.builder().comment("comment").translation("trans").transcription("transcr").usageSample("sample").id(4L).build();
        card.addTranslation(trans);

        var clonedDict = cloner.clone(dict);
        assertEquals(clonedDict.getName(), dict.getName());
        assertEquals(clonedDict.getUserCards().size(), dict.getUserCards().size());

        for (int cardIndex = 0; cardIndex < clonedDict.getUserCards().size(); ++cardIndex) {
            var clonedCard = clonedDict.getUserCards().get(cardIndex);
            var standardCard = dict.getUserCards().get(cardIndex);

            assertEquals(clonedCard.getTranslations().size(), standardCard.getTranslations().size());
            assertEquals(clonedCard.getTranslatedWord(), standardCard.getTranslatedWord());
            assertEquals(clonedCard.getUserDictionary(), clonedDict);


            for (int transIndex = 0; transIndex < clonedCard.getTranslations().size(); ++transIndex) {
                var clonedTrans = clonedCard.getTranslations().get(transIndex);
                var standardTrans = standardCard.getTranslations().get(transIndex);

                assertEquals(clonedTrans.getSourceCard().getTranslatedWord(), clonedCard.getTranslatedWord());
                assertEquals(clonedTrans.getUsageSample(), standardTrans.getUsageSample());
                assertEquals(clonedTrans.getComment(), standardTrans.getComment());
                assertEquals(clonedTrans.getTranslation(), standardTrans.getTranslation());
                assertEquals(clonedTrans.getTranscription(), standardTrans.getTranscription());
            }
        }
    }
}