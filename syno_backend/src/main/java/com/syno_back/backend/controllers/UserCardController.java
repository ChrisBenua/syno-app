package com.syno_back.backend.controllers;

import com.syno_back.backend.datasource.DbUserCardRepository;
import com.syno_back.backend.datasource.DbUserDictionaryRepository;
import com.syno_back.backend.dto.*;
import com.syno_back.backend.model.DbUserCard;
import com.syno_back.backend.model.DbUserDictionary;
import com.syno_back.backend.service.IBatchUpdateEntityService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.userdetails.User;
import org.springframework.web.bind.annotation.*;

import javax.validation.Valid;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/user_cards/{user_dict_id}")
public class UserCardController {
    private DbUserCardRepository userCardRepository;

    private DbUserDictionaryRepository userDictionaryRepository;

    private IBatchUpdateEntityService<UpdateUserCard, DbUserDictionary> batchUserCardUpdater;


    public UserCardController(@Autowired DbUserCardRepository userCardRepository, @Autowired DbUserDictionaryRepository
            userDictionaryRepository, @Autowired IBatchUpdateEntityService<UpdateUserCard, DbUserDictionary> batchUpdater) {
        this.userCardRepository = userCardRepository;
        this.userDictionaryRepository = userDictionaryRepository;
        this.batchUserCardUpdater = batchUpdater;
    }

    @PostMapping("/add_card")
    @PreAuthorize("hasRole('USER')")
    public ResponseEntity addCardToDictionary(Authentication auth, @PathVariable("user_dict_id") long userDictId, @Valid @RequestBody NewUserCard newUserCard) {
        String userEmail = ((User)auth.getPrincipal()).getUsername();

        var dict = userDictionaryRepository.findById(userDictId);
        if (dict.isPresent()) {
            if (dict.get().getOwner().getEmail().equals(userEmail)) {
                var card = newUserCard.toDbUserCard(dict.get());
                userCardRepository.save(card);

                return new ResponseEntity<>("User card created successfully", HttpStatus.ACCEPTED);
            } else {
                return new ResponseEntity<>(String.format("DbUserDictionary with id %d doesnt belong to user with email: %s",
                        userDictId, userEmail), HttpStatus.FORBIDDEN);
            }
        } else {
            return new ResponseEntity<>(String.format("No such DbUserDictionary with id %d", userDictId), HttpStatus.NOT_FOUND);
        }
    }

    @GetMapping("/get_cards")
    @PreAuthorize("hasRole('USER')")
    public ResponseEntity getCardsFromDictionary(Authentication auth, @PathVariable("user_dict_id") long userDictId) {
        String userEmail = ((User)auth.getPrincipal()).getUsername();
        var dict = userDictionaryRepository.findById(userDictId);
        if (dict.isPresent()) {
            if (dict.get().getOwner().getEmail().equals(userEmail)) {
                var dto = dict.get().getUserCards().stream().map(UserCard::new);
                return ResponseEntity.ok(dto);
            } else {
                return new ResponseEntity<>(String.format("DbUserDictionary with id %d doesnt belong to user with email: %s",
                        userDictId, userEmail), HttpStatus.FORBIDDEN);
            }
        } else {
            return new ResponseEntity<>(String.format("No such DbUserDictionary with id %d", userDictId), HttpStatus.NOT_FOUND);
        }
    }

    @PostMapping("/update_cards_selective")
    @PreAuthorize("hasRole('USER')")
    public ResponseEntity updateCardsFromDictionarySelective(Authentication auth, @PathVariable("user_dict_id") long userDictId,
                                                             @Valid @RequestBody List<UpdateUserCard> updateUserCards) {
        String userEmail = ((User)auth.getPrincipal()).getUsername();
        var dict = userDictionaryRepository.findById(userDictId);
        if (dict.isPresent()) {
            if (dict.get().getOwner().getEmail().equals(userEmail)) {
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
