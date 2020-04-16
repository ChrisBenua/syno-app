package com.syno_back.backend.service;

import com.syno_back.backend.dto.UpdateUserCardDto;
import com.syno_back.backend.model.DbUserDictionary;

import java.util.List;

public interface ICardUpdateService {
    void performUpdates(DbUserDictionary dictionary, List<UpdateUserCardDto> cards);
}
