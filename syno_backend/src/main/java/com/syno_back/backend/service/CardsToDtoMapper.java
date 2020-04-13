package com.syno_back.backend.service;

import com.syno_back.backend.dto.NewUserTranslation;
import com.syno_back.backend.dto.Translation;
import com.syno_back.backend.dto.UserCard;
import com.syno_back.backend.model.DbTranslation;
import com.syno_back.backend.model.DbUserCard;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.util.Pair;
import org.springframework.stereotype.Component;

import java.util.stream.Collectors;

@Component
public class CardsToDtoMapper implements IDtoMapper<DbUserCard, UserCard>  {

    private IDtoMapper<DbTranslation, Translation> translationMapper;

    public CardsToDtoMapper(@Autowired IDtoMapper<DbTranslation, Translation> translationMapper) {
        this.translationMapper = translationMapper;
    }

    @Override
    public UserCard convert(DbUserCard dto, Iterable<Pair<String, ?>> additionalFields) {
        var builder = UserCard.builder().id(dto.getId()).translatedWord(dto.getTranslatedWord())
                .translations(dto.getTranslations().stream().map((card) -> translationMapper.convert(card, null)).collect(Collectors.toList()))
                .timeCreated(dto.getTimeCreated()).timeModified(dto.getTimeModified());
        return builder.build();
    }
}
