package com.syno_back.backend.service;

import com.syno_back.backend.dto.NewUserTranslation;
import com.syno_back.backend.model.DbTranslation;
import com.syno_back.backend.model.DbUserCard;
import org.springframework.stereotype.Component;

@Component
public class TranslationsAdderService implements ITranslationsAdderService {

    @Override
    public void addTranslationsToCard(Iterable<NewUserTranslation> newUserTranslation, DbUserCard sourceCard) {
        for (var newTrans : newUserTranslation) {
            var newDbTranslation = DbTranslation.builder()
                    .translation(newTrans.getTranslation())
                    .comment(newTrans.getComment())
                    .usageSample(newTrans.getUsageSample())
                    .transcription(newTrans.getTranscription()).build();
            sourceCard.addTranslation(newDbTranslation);
            newDbTranslation.setSourceCard(sourceCard);
        }
    }
}
