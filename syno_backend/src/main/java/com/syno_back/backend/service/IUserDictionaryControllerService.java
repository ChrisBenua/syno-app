package com.syno_back.backend.service;

import com.syno_back.backend.dto.UpdateRequestDto;
import com.syno_back.backend.dto.UserDictionary;

import java.util.stream.Stream;

public interface IUserDictionaryControllerService {
    Stream<UserDictionary> allForUser(String email);

    void performUpdates(String email, UpdateRequestDto updateRequest);
}
