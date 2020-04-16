package com.syno_back.backend.service;

import com.syno_back.backend.dto.UpdateUserTranslationDto;
import com.syno_back.backend.model.DbTranslation;
import lombok.NonNull;
import org.springframework.data.util.Pair;
import org.springframework.stereotype.Component;

@Component
public class UpdateTranslationToDbTranslationMapper implements IDtoMapper<UpdateUserTranslationDto, DbTranslation> {
    @Override
    public DbTranslation convert(@NonNull UpdateUserTranslationDto dto, Iterable<Pair<String, ?>> additionalFields) {
        return DbTranslation.builder().pin(dto.getPin())
                .comment(dto.getComment())
                .usageSample(dto.getUsageSample())
                .transcription(dto.getTranscription())
                .translation(dto.getTranslation())
                .timeCreated(dto.getTimeCreated()).build();

    }
}
