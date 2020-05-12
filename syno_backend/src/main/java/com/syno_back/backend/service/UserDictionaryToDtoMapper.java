package com.syno_back.backend.service;

import com.syno_back.backend.dto.UserCard;
import com.syno_back.backend.dto.UserDictionary;
import com.syno_back.backend.model.DbUserCard;
import com.syno_back.backend.model.DbUserDictionary;
import lombok.NonNull;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.util.Pair;
import org.springframework.stereotype.Component;

import java.util.stream.Collectors;

/**
 * Service for mapping <code>DbUserDictionary</code> to <code>UserDictionary</code>
 */
@Component
public class UserDictionaryToDtoMapper implements IDtoMapper<DbUserDictionary, UserDictionary> {

    /**
     * Service for mapping <code>DbUserCard</code> to <code>UserCard</code>
     */
    private IDtoMapper<DbUserCard, UserCard> cardMapper;

    public UserDictionaryToDtoMapper(@Autowired IDtoMapper<DbUserCard, UserCard> cardMapper) {
        this.cardMapper = cardMapper;
    }

    @Override
    public UserDictionary convert(@NonNull DbUserDictionary dto, Iterable<Pair<String, ?>> additionalFields) {
        return UserDictionary.builder().id(dto.getId()).pin(dto.getPin()).name(dto.getName()).timeCreated(dto.getTimeCreated())
                .timeModified(dto.getTimeModified()).language(dto.getLanguage()).userCards(dto.getUserCards().stream().map((card) -> cardMapper.convert(card, null)).collect(Collectors.toList()))
                .build();
    }
}
