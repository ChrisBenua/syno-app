package com.syno_back.backend.service;

import com.syno_back.backend.datasource.DbTranslationRepository;
import com.syno_back.backend.dto.UpdateUserTranslation;
import com.syno_back.backend.exception.DbOwnerViolated;
import com.syno_back.backend.model.DbTranslation;
import com.syno_back.backend.model.DbUserCard;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.HashMap;
import java.util.function.Predicate;

@Component
public class BatchUpdateTranslationService implements IBatchUpdateEntityService<UpdateUserTranslation, DbUserCard> {

    @Autowired
    private ISingleUpdateService<DbTranslation, UpdateUserTranslation> updater;

    @Autowired
    private DbTranslationRepository repository;

    private void commonUpdatePart(Iterable<UpdateUserTranslation> dtoObjects, Predicate<DbTranslation> predicate) {
        HashMap<Long, UpdateUserTranslation> idToTranslation = new HashMap<>();
        for (var translation: dtoObjects) {
            idToTranslation.put(translation.getId(), translation);
        }

        var translations = repository.findAllById(idToTranslation.keySet());
        translations.forEach(trans -> {
            if (predicate.test(trans)) {
                updater.update(idToTranslation.get(trans.getId()), trans);
            } else {
                throw new DbOwnerViolated(String.format("With trans.id = %d", trans.getId()));
            }
        });

        repository.saveAll(translations);
    }

    @Override
    public void updateWithOwnerCheck(Iterable<UpdateUserTranslation> dtoObjects, DbUserCard owner) {
        commonUpdatePart(dtoObjects, card -> card.getSourceCard().equals(owner));
    }

    @Override
    public void updateWith(Iterable<UpdateUserTranslation> dtoObject) {
        commonUpdatePart(dtoObject, (__) -> true);
    }
}
