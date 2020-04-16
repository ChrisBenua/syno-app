package com.syno_back.backend.service;

import com.syno_back.backend.dto.UpdateUserCardDto;
import com.syno_back.backend.dto.UpdateUserTranslationDto;
import com.syno_back.backend.model.DbTranslation;
import com.syno_back.backend.model.DbUserCard;
import lombok.NonNull;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.util.Pair;
import org.springframework.stereotype.Component;

import java.util.stream.Collectors;

@Component
public class UpdateCardToDbCardMapper implements IDtoMapper<UpdateUserCardDto, DbUserCard> {
    private IDtoMapper<UpdateUserTranslationDto, DbTranslation> translationMapper;

    public UpdateCardToDbCardMapper(@Autowired IDtoMapper<UpdateUserTranslationDto, DbTranslation> translationMapper) {
        this.translationMapper = translationMapper;
    }

    @Override
    public DbUserCard convert(@NonNull UpdateUserCardDto dto, Iterable<Pair<String, ?>> additionalFields) {
        var card = DbUserCard.builder()
                .pin(dto.getPin())
                .translatedWord(dto.getTranslatedWord())
                .timeCreated(dto.getTimeCreated())
                .build();
        card.setTranslations(dto.getTranslations().stream().map(el -> {
            return translationMapper.convert(el, null);
        }).collect(Collectors.toList()));
        return card;
    }
}
