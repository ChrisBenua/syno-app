package com.syno_back.backend.service;

import com.syno_back.backend.dto.UpdateUserTranslationDto;
import com.syno_back.backend.model.DbUserCard;

import java.util.List;

/**
 * Service for updating <code>DbTranslation</code>
 */
public interface IUpdateTranslationsService {
    /**
     * Updates translations of <code>DbUserCard</code>
     * @param card card which translations should be updated
     * @param updateTranslations list of translations to be updated
     */
    void performUpdate(DbUserCard card, List<UpdateUserTranslationDto> updateTranslations);
}
