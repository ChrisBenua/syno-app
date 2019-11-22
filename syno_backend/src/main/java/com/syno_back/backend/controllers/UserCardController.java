package com.syno_back.backend.controllers;

import com.syno_back.backend.datasource.DbUserCardRepository;
import com.syno_back.backend.datasource.DbUserDictionaryRepository;
import com.syno_back.backend.dto.*;
import com.syno_back.backend.model.DbTranslation;
import com.syno_back.backend.model.DbUserCard;
import com.syno_back.backend.model.DbUserDictionary;
import com.syno_back.backend.service.IBatchUpdateEntityService;
import com.syno_back.backend.service.ICredentialProvider;
import com.syno_back.backend.service.IDtoMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.util.Pair;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.userdetails.User;
import org.springframework.web.bind.annotation.*;

import javax.validation.Valid;
import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/user_cards/{user_dict_id}")
public class UserCardController {
    private DbUserCardRepository userCardRepository;

    private DbUserDictionaryRepository userDictionaryRepository;

    private IBatchUpdateEntityService<UpdateUserCard, DbUserDictionary> batchUserCardUpdater;

    private ICredentialProvider<DbUserDictionary, Authentication> userDictCredentialProvider;

    private IDtoMapper<DbUserCard, UserCard> cardMapper;

    private IDtoMapper<NewUserCard, DbUserCard> toDbCardMapper;


    public UserCardController(@Autowired DbUserCardRepository userCardRepository, @Autowired DbUserDictionaryRepository
            userDictionaryRepository, @Autowired IBatchUpdateEntityService<UpdateUserCard, DbUserDictionary> batchUpdater,
            ICredentialProvider<DbUserDictionary, Authentication> credentialProvider, @Autowired IDtoMapper<DbUserCard, UserCard> cardMapper,
                              @Autowired IDtoMapper<NewUserCard, DbUserCard> toDbCardMapper) {
        this.userCardRepository = userCardRepository;
        this.userDictionaryRepository = userDictionaryRepository;
        this.batchUserCardUpdater = batchUpdater;
        this.userDictCredentialProvider = credentialProvider;
        this.cardMapper = cardMapper;
        this.toDbCardMapper = toDbCardMapper;
    }

    @PostMapping("/add_card")
    @PreAuthorize("hasRole('USER')")
    public ResponseEntity addCardToDictionary(Authentication auth, @PathVariable("user_dict_id") long userDictId, @Valid @RequestBody NewUserCard newUserCard) {
        String userEmail = ((User)auth.getPrincipal()).getUsername();

        var dict = userDictionaryRepository.findById(userDictId);
        if (dict.isPresent()) {
            if (userDictCredentialProvider.check(dict.get(), auth)) {
                var card = toDbCardMapper.convert(newUserCard, null);
                card = userCardRepository.save(card);
                dict.get().addUserCard(card);

                userDictionaryRepository.save(dict.get());

                return new ResponseEntity<>(MessageResponse.of("User card created successfully"), HttpStatus.ACCEPTED);
            } else {
                return new ResponseEntity<>(MessageResponse.of(String.format("DbUserDictionary with id %d doesnt belong to user with email: %s",
                        userDictId, userEmail)), HttpStatus.FORBIDDEN);
            }
        } else {
            return new ResponseEntity<>(MessageResponse.of(String.format("No such DbUserDictionary with id %d", userDictId)), HttpStatus.NOT_FOUND);
        }
    }

    @PostMapping("/add_many_cards")
    @PreAuthorize("hasRole('USER')")
    public ResponseEntity addManyCardsToDictionary(Authentication auth, @PathVariable("user_dict_id") long userDictId, @Valid @RequestBody List<NewUserCard> newUserCards) {
        String userEmail = ((User)auth.getPrincipal()).getUsername();

        var dict = userDictionaryRepository.findById(userDictId);
        if (dict.isPresent()) {
            if (userDictCredentialProvider.check(dict.get(), auth)) {
                var cards = newUserCards.stream().map(newUserCard -> {
                    var card = toDbCardMapper.convert(newUserCard, null);
                    dict.get().addUserCard(card);
                    return card;
                }).collect(Collectors.toList());

                userDictionaryRepository.save(dict.get());

                return new ResponseEntity<>(MessageResponse.of("User card created successfully"), HttpStatus.ACCEPTED);
            } else {
                return new ResponseEntity<>(MessageResponse.of(String.format("DbUserDictionary with id %d doesnt belong to user with email: %s",
                        userDictId, userEmail)), HttpStatus.FORBIDDEN);
            }
        } else {
            return new ResponseEntity<>(MessageResponse.of(String.format("No such DbUserDictionary with id %d", userDictId)), HttpStatus.NOT_FOUND);
        }
    }

    @GetMapping("/get_cards")
    @PreAuthorize("hasRole('USER')")
    public ResponseEntity getCardsFromDictionary(Authentication auth, @PathVariable("user_dict_id") long userDictId) {
        String userEmail = ((User)auth.getPrincipal()).getUsername();
        var dict = userDictionaryRepository.findById(userDictId);
        if (dict.isPresent()) {
            if (userDictCredentialProvider.check(dict.get(), auth)) {
                var dto = dict.get().getUserCards().stream().map((card) -> cardMapper.convert(card, null));
                return ResponseEntity.ok(dto);
            } else {
                return new ResponseEntity<>(MessageResponse.of(String.format("DbUserDictionary with id %d doesnt belong to user with email: %s",
                        userDictId, userEmail)), HttpStatus.FORBIDDEN);
            }
        } else {
            return new ResponseEntity<>(MessageResponse.of(String.format("No such DbUserDictionary with id %d", userDictId)), HttpStatus.NOT_FOUND);
        }
    }

    @PostMapping("/update_cards_selective")
    @PreAuthorize("hasRole('USER')")
    public ResponseEntity updateCardsFromDictionarySelective(Authentication auth, @PathVariable("user_dict_id") long userDictId,
                                                             @Valid @RequestBody List<UpdateUserCard> updateUserCards) {
        String userEmail = ((User)auth.getPrincipal()).getUsername();
        var dict = userDictionaryRepository.findById(userDictId);
        if (dict.isPresent()) {
            if (userDictCredentialProvider.check(dict.get(), auth)) {
                this.batchUserCardUpdater.updateWithOwnerCheck(updateUserCards, dict.get());

                return ResponseEntity.ok(MessageResponse.of("Saved  entities successfully"));
            } else {
                return new ResponseEntity<>(MessageResponse.of(String.format("DbUserDictionary with id %d doesnt belong to user with email: %s",
                        userDictId, userEmail)), HttpStatus.FORBIDDEN);
            }
        } else {
            return new ResponseEntity<>(MessageResponse.of(String.format("No such DbUserDictionary with id %d", userDictId)), HttpStatus.NOT_FOUND);
        }
    }
}
