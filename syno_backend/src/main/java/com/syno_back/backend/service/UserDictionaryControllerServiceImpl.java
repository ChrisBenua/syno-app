package com.syno_back.backend.service;

import com.syno_back.backend.datasource.DbUserDictionaryRepository;
import com.syno_back.backend.datasource.UserRepository;
import com.syno_back.backend.dto.UpdateRequestDto;
import com.syno_back.backend.dto.UserDictionary;
import com.syno_back.backend.model.DbUserDictionary;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.stream.Stream;

@Component
public class UserDictionaryControllerServiceImpl implements IUserDictionaryControllerService {

    @Autowired
    private DbUserDictionaryRepository repository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private DictsUpdateServiceImpl dictsUpdateService;

    @Autowired
    private IDtoMapper<DbUserDictionary, UserDictionary> fromDtoMapper;

    @Override
    public Stream<UserDictionary> allForUser(String email) {
        return repository.findByOwner_Email(email).stream().map(dict -> fromDtoMapper.convert(dict, null));
    }

    @Override
    public void performUpdates(String email, UpdateRequestDto updateRequest) {
        var owner = userRepository.findByEmail(email);

        if (owner.isPresent()) {
            dictsUpdateService.performUpdates(owner.get(), updateRequest);
        } else {
            throw new RuntimeException(String.format("no user with email %s", email));
        }
    }
}
