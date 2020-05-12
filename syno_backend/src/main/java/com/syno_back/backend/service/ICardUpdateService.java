package com.syno_back.backend.service;

import com.syno_back.backend.dto.UpdateUserCardDto;
import com.syno_back.backend.model.DbUserDictionary;

import java.util.List;

/**
 * Service for updating cards
 */
public interface ICardUpdateService {
    /**
     * Updates cards in given dictionary
     * @param dictionary dictionary which cards to updated
     * @param cards cards to update
     */
    void performUpdates(DbUserDictionary dictionary, List<UpdateUserCardDto> cards);
}
