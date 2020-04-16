package com.syno_back.backend.service;

import com.syno_back.backend.dto.UpdateUserTranslationDto;
import com.syno_back.backend.model.DbUserCard;

import java.util.List;

public interface IUpdateTranslationsService {
    void performUpdate(DbUserCard card, List<UpdateUserTranslationDto> updateTranslations);
}
