package com.syno_back.backend.service;

import com.syno_back.backend.dto.NewUserCard;
import com.syno_back.backend.dto.NewUserTranslation;
import com.syno_back.backend.helper.ReflectionUtils;
import com.syno_back.backend.model.DbTranslation;
import com.syno_back.backend.model.DbUserCard;
import lombok.NonNull;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.util.Pair;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.stream.Collectors;

@Component
public class UserCardDtoMapper implements IDtoMapper<NewUserCard, DbUserCard> {

    private IDtoMapper<NewUserTranslation, DbTranslation> translationDtoMapper;

    public UserCardDtoMapper(@Autowired IDtoMapper<NewUserTranslation, DbTranslation> mapper) {
        this.translationDtoMapper = mapper;
    }

    @Override
    public DbUserCard convert(@NonNull NewUserCard dto, Iterable<Pair<String, ?>> additionalFields) {
        var translations = dto.getTranslations().stream().map(trans -> translationDtoMapper.convert(trans, null));
        var cardBuilder = DbUserCard.builder().translatedWord(dto.getTranslatedWord()).language(dto.getLanguage());

        ReflectionUtils.setFields(cardBuilder, additionalFields);

        var card = cardBuilder.build();
        card.setTranslations(translations.collect(Collectors.toList()));

        return card;
    }
}
