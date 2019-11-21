package com.syno_back.backend.service;

import com.syno_back.backend.dto.NewUserTranslation;
import com.syno_back.backend.model.DbUserCard;

public interface ITranslationsAdderService {
    void addTranslationsToCard(Iterable<NewUserTranslation> newUserTranslation, DbUserCard sourceCard);
}
