package com.syno_back.backend.service;

import com.syno_back.backend.dto.NewUserTranslation;
import com.syno_back.backend.helper.ReflectionUtils;
import com.syno_back.backend.model.DbTranslation;
import lombok.NonNull;
import org.springframework.data.util.Pair;
import org.springframework.stereotype.Component;

@Component
public class TranslationDtoMapper implements IDtoMapper<NewUserTranslation, DbTranslation> {
    @Override
    public DbTranslation convert(@NonNull NewUserTranslation dto, Iterable<Pair<String, ?>> additionalFields) {
        var builder = DbTranslation.builder().comment(dto.getComment()).translation(dto.getTranslation())
                .transcription(dto.getTranscription()).usageSample(dto.getUsageSample());

        ReflectionUtils.setFields(builder, additionalFields);

        return builder.build();
    }
}
