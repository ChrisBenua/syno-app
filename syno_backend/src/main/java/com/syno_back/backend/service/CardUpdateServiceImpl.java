package com.syno_back.backend.service;

import com.syno_back.backend.datasource.DbUserCardRepository;
import com.syno_back.backend.dto.UpdateUserCardDto;
import com.syno_back.backend.model.DbUser;
import com.syno_back.backend.model.DbUserCard;
import com.syno_back.backend.model.DbUserDictionary;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

@Component
public class CardUpdateServiceImpl implements ICardUpdateService {
    private DbUserCardRepository userCardRepository;

    private IDtoMapper<UpdateUserCardDto, DbUserCard> mapper;

    private IUpdateTranslationsService translationsService;

    public CardUpdateServiceImpl(
            @Autowired DbUserCardRepository userCardRepository,
            @Autowired IDtoMapper<UpdateUserCardDto, DbUserCard> mapper,
            @Autowired IUpdateTranslationsService translationsService
    ) {
        this.userCardRepository = userCardRepository;
        this.mapper = mapper;
        this.translationsService = translationsService;
    }

    @Override
    public void performUpdates(DbUserDictionary dictionary, List<UpdateUserCardDto> cards) {
        var allUserCards = dictionary.getUserCards();
        var existingCardPins = cards.stream().map(UpdateUserCardDto::getPin).collect(Collectors.toSet());
        Set<String> updatedPins = new HashSet<>();
        List<DbUserCard> toRemove = new ArrayList<>();

        for (DbUserCard userCard : allUserCards) {
            if (existingCardPins.contains(userCard.getPin())) {
                //update
                updatedPins.add(userCard.getPin());
                var updateCardDto = cards.stream().filter(el -> el.getPin().equals(userCard.getPin())).findAny();

                if (updateCardDto.isPresent()) {
                    userCard.setTranslatedWord(updateCardDto.get().getTranslatedWord());
                    //update translations
                    this.translationsService.performUpdate(userCard, updateCardDto.get().getTranslations());
                }

            } else {
                //delete
                toRemove.add(userCard);
            }
        }

        for (var userCard : toRemove) {
            dictionary.removeUserCard(userCard);
            userCardRepository.delete(userCard);
        }

        for (var updateUserCard: cards) {
            if (!updatedPins.contains(updateUserCard.getPin())) {
                var dbCard = mapper.convert(updateUserCard, null);
                dictionary.addUserCard(dbCard);
            }
        }
    }
}
