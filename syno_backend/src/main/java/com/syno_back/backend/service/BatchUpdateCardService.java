package com.syno_back.backend.service;

import com.syno_back.backend.datasource.DbUserCardRepository;
import com.syno_back.backend.dto.UpdateUserCard;
import com.syno_back.backend.dto.UpdateUserTranslation;
import com.syno_back.backend.exception.DbOwnerViolated;
import com.syno_back.backend.model.DbTranslation;
import com.syno_back.backend.model.DbUserCard;
import com.syno_back.backend.model.DbUserDictionary;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.HashMap;
import java.util.function.Predicate;

@Component
public class BatchUpdateCardService implements IBatchUpdateEntityService<UpdateUserCard, DbUserDictionary> {

    @Autowired
    private ISingleUpdateService<DbUserCard, UpdateUserCard> updater;

    @Autowired
    private DbUserCardRepository repository;

    private void commonUpdatePart(Iterable<UpdateUserCard> dtoObjects, Predicate<DbUserCard> predicate) {
        HashMap<Long, UpdateUserCard> idToCards = new HashMap<>();
        for (var translation: dtoObjects) {
            idToCards.put(translation.getId(), translation);
        }

        var cards = repository.findAllById(idToCards.keySet());
        cards.forEach(card -> {
            if (predicate.test(card)) {
                updater.update(idToCards.get(card.getId()), card);
            } else {
                throw new DbOwnerViolated(String.format("With card.id = %d", card.getId()));
            }
        });

        repository.saveAll(cards);
    }

    @Override
    public void updateWithOwnerCheck(Iterable<UpdateUserCard> dtoObject, DbUserDictionary owner) {
        commonUpdatePart(dtoObject, card -> card.getUserDictionary().equals(owner));
    }

    @Override
    public void updateWith(Iterable<UpdateUserCard> dtoObject) {
        commonUpdatePart(dtoObject, (__) -> true);
    }
}
