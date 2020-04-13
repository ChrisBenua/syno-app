package com.syno_back.backend.service;

import com.syno_back.backend.dto.UpdateUserCard;
import com.syno_back.backend.dto.UpdateUserTranslation;
import com.syno_back.backend.model.DbTranslation;
import com.syno_back.backend.model.DbUserCard;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;


@Component
public class SingleUpdateCardService implements ISingleUpdateService<DbUserCard, UpdateUserCard> {

    @Autowired
    private BatchUpdateTranslationService updateTranslationService;

    @Override
    public void update(UpdateUserCard dto, DbUserCard userCard) {
        userCard.setTranslatedWord(dto.getTranslatedWord());

        if (dto.getTranslations() != null)
            updateTranslationService.updateWithOwnerCheck(dto.getTranslations(), userCard);
    }
}
