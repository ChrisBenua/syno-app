package com.syno_back.backend.service;

import com.syno_back.backend.dto.Translation;
import com.syno_back.backend.dto.UserCard;
import com.syno_back.backend.model.DbTranslation;
import com.syno_back.backend.model.DbUserCard;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.util.Pair;
import org.springframework.stereotype.Component;

import java.util.stream.Collectors;

/**
 * Service for mapping <code>DbUserCard</code> to DTO <code>UserCard</code>
 */
@Component
public class CardsToDtoMapper implements IDtoMapper<DbUserCard, UserCard>  {

    /**
     * Service for mapping <code>DbTranslation</code> to <code>Translation</code> dto
     */
    private IDtoMapper<DbTranslation, Translation> translationMapper;

    /**
     * Creates new <code>CardsToDtoMapper</code>
     * @param translationMapper Service for mapping <code>DbTranslation</code> to <code>Translation</code> dto
     */
    public CardsToDtoMapper(@Autowired IDtoMapper<DbTranslation, Translation> translationMapper) {
        this.translationMapper = translationMapper;
    }

    /**
     * Maps <code>DbUserCard</code> to <code>UserCard</code>
     * @param dto <code>DbUserCard</code> instance
     * @param additionalFields actually null
     * @return <code>UserCard</code> instance
     */
    @Override
    public UserCard convert(DbUserCard dto, Iterable<Pair<String, ?>> additionalFields) {
        var builder = UserCard.builder().id(dto.getId()).translatedWord(dto.getTranslatedWord())
                .translations(dto.getTranslations().stream().map((card) -> translationMapper.convert(card, null)).collect(Collectors.toList()))
                .timeCreated(dto.getTimeCreated()).timeModified(dto.getTimeModified()).pin(dto.getPin());
        return builder.build();
    }
}
