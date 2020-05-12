package com.syno_back.backend.service;

import com.syno_back.backend.model.DbTranslation;
import org.springframework.stereotype.Component;

/**
 * Service for cloning <code>DbTranslation</code>
 */
@Component
public class DbTranslationCloner implements IEntityCloner<DbTranslation> {

    @Override
    public DbTranslation clone(DbTranslation cloneable) {
        return DbTranslation.builder().comment(cloneable.getComment())
                .usageSample(cloneable.getUsageSample())
                .translation(cloneable.getTranslation())
                .transcription(cloneable.getTranscription()).build();
    }
}
