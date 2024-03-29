package com.syno_back.backend.service;

import com.syno_back.backend.dto.Translation;
import com.syno_back.backend.model.DbTranslation;
import org.springframework.data.util.Pair;
import org.springframework.stereotype.Component;

/**
 * Service for mapping <code>DbTranslation</code> to <code>Translation</code>
 */
@Component
public class TranslationToDtoMapper implements IDtoMapper<DbTranslation, Translation> {
    @Override
    public Translation convert(DbTranslation dto, Iterable<Pair<String, ?>> additionalFields) {
        var builder = Translation.builder().id(dto.getId()).comment(dto.getComment()).transcription(dto.getTranscription())
                .timeCreated(dto.getTimeCreated()).timeModified(dto.getTimeModified()).translation(dto.getTranslation())
                .usageSample(dto.getUsageSample()).pin(dto.getPin());
        return builder.build();
    }
}
