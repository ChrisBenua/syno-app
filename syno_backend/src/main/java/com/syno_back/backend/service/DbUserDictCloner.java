package com.syno_back.backend.service;

import com.syno_back.backend.model.DbUserCard;
import com.syno_back.backend.model.DbUserDictionary;
import org.springframework.stereotype.Component;

import java.util.stream.Collectors;

@Component
public class DbUserDictCloner implements IEntityCloner<DbUserDictionary> {

    private IEntityCloner<DbUserCard> cardCloner;

    public DbUserDictCloner(IEntityCloner<DbUserCard> cardCloner) {
        this.cardCloner = cardCloner;
    }

    @Override
    public DbUserDictionary clone(DbUserDictionary cloneable) {
        DbUserDictionary clonedDict = DbUserDictionary.builder().name(cloneable.getName()).build();

        var clonedCards = cloneable.getUserCards().stream().map(card -> cardCloner.clone(card)).collect(Collectors.toList());
        clonedDict.setUserCards(clonedCards);

        return clonedDict;
    }
}
