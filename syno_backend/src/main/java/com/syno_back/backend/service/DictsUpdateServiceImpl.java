package com.syno_back.backend.service;

import com.syno_back.backend.datasource.DbDictShareRepository;
import com.syno_back.backend.datasource.DbUserDictionaryRepository;
import com.syno_back.backend.datasource.UserRepository;
import com.syno_back.backend.dto.UpdateRequestDto;
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

/**
 * Service for updating <code>DbUserDictionary</code>
 */
@Component
public class DictsUpdateServiceImpl implements IDictsUpdateService {
    /**
     * Repository for CRUD operations with <code>DbUserDictionary</code>
     */
    private DbUserDictionaryRepository dictionaryRepository;

    /**
     * Repository for CRUD operations with <code>DbUser</code>
     */
    private UserRepository userRepository;

    /**
     * Service for mapping <code>UpdateUserCardDto</code> to <code>DbUserCard</code>
     */
    private IDtoMapper<UpdateUserCardDto, DbUserCard> updateUserCardMapper;

    /**
     * Service for updating <code>DbUserCard</code>
     */
    private ICardUpdateService cardUpdateService;

    private DbDictShareRepository shareRepository;

    public DictsUpdateServiceImpl(
            @Autowired DbUserDictionaryRepository dictionaryRepository,
            @Autowired IDtoMapper<UpdateUserCardDto, DbUserCard> updateUserCardMapper,
            @Autowired ICardUpdateService cardUpdateService,
            @Autowired UserRepository userRepository,
            @Autowired DbDictShareRepository shareRepository
    ) {
        this.dictionaryRepository = dictionaryRepository;
        this.updateUserCardMapper = updateUserCardMapper;
        this.cardUpdateService = cardUpdateService;
        this.userRepository = userRepository;
        this.shareRepository = shareRepository;
    }

    @Override
    public void performUpdates(DbUser user, UpdateRequestDto updateRequestDto) {
        var allUserDicts = user.getUserDictionaries();
        Set<String> updatedPins = new HashSet<>();
        List<DbUserDictionary> toRemove = new ArrayList<>();

        for (var dict : allUserDicts) {
            if (!updateRequestDto.getExistingDictPins().contains(dict.getPin())) {
                toRemove.add(dict);
            } else {
                var updateDictDto = updateRequestDto.getClientDicts()
                        .stream()
                        .filter(el -> el.getPin().equals(dict.getPin())).findFirst();
                if (updateDictDto.isPresent()) {
                    updatedPins.add(updateDictDto.get().getPin());

                    dict.setName(updateDictDto.get().getName());
                    dict.setLanguage(updateDictDto.get().getLanguage());
                    //update Cards
                    cardUpdateService.performUpdates(dict, updateDictDto.get().getUserCards());
                }
            }
        }

        for (var dict : toRemove) {
            user.removeDictionary(dict);
            var share = shareRepository.findBySharedDictionary_Id(dict.getId());
            share.ifPresent(dbDictShare -> shareRepository.delete(dbDictShare));
            dictionaryRepository.delete(dict);
        }

        for (var updateDictDto: updateRequestDto.getClientDicts()) {
            if (!updatedPins.contains(updateDictDto.getPin())) {
                var newDbDict = DbUserDictionary.builder()
                        .pin(updateDictDto.getPin())
                        .language(updateDictDto.getLanguage())
                        .owner(user)
                        .name(updateDictDto.getName())
                        .timeCreated(updateDictDto.getTimeCreated())
                        .build();
                newDbDict.setUserCards(updateDictDto.getUserCards().stream().map(el -> {
                    return this.updateUserCardMapper.convert(el, null);
                }).collect(Collectors.toList()));
                user.addUserDictionary(newDbDict);
            }
        }
        userRepository.save(user);
    }
}
