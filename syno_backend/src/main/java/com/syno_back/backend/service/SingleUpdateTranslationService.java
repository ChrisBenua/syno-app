package com.syno_back.backend.service;

import com.syno_back.backend.dto.UpdateUserTranslation;
import com.syno_back.backend.model.DbTranslation;
import org.springframework.stereotype.Component;

@Component
public class SingleUpdateTranslationService implements ISingleUpdateService<DbTranslation, UpdateUserTranslation> {
    @Override
    public void update(UpdateUserTranslation dto, DbTranslation translation) {
        translation.setTranslation(dto.getTranslation());
        translation.setUsageSample(dto.getUsageSample());
        translation.setTranscription(dto.getTranscription());
        translation.setComment(dto.getComment());
    }
}
