package com.syno_back.backend.service;


import com.syno_back.backend.model.DbTranslation;
import com.syno_back.backend.model.DbUserCard;
import org.springframework.stereotype.Component;

import java.util.stream.Collectors;

/**
 * Service for cloning <code>DbUserCard</code>
 */
@Component
public class DbUserCardCloner implements IEntityCloner<DbUserCard> {

    /**
     * Service for cloning <code>DbTranslation</code>
     */
    private IEntityCloner<DbTranslation> translationCloner;

    public DbUserCardCloner(IEntityCloner<DbTranslation> translationCloner) {
        this.translationCloner = translationCloner;
    }

    @Override
    public DbUserCard clone(DbUserCard cloneable) {
        var clonedCard = DbUserCard.builder()
                .translatedWord(cloneable.getTranslatedWord())
                .build();
        var clonedTranslations = cloneable.getTranslations().stream().map(trans -> translationCloner.clone(trans)).collect(Collectors.toList());
        clonedCard.setTranslations(clonedTranslations);

        return clonedCard;
    }
}
