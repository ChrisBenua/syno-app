package com.syno_back.backend.controllers;

import com.syno_back.backend.datasource.DbUserCardRepository;
import com.syno_back.backend.dto.MessageResponse;
import com.syno_back.backend.dto.NewUserTranslation;
import com.syno_back.backend.model.DbTranslation;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.userdetails.User;
import org.springframework.web.bind.annotation.*;

import javax.validation.Valid;
import java.net.Authenticator;
import java.util.ArrayList;
import java.util.List;

@RestController
@RequestMapping("/api/translations/{card_id}")
public class TranslationsController {
    @Autowired
    private DbUserCardRepository cardRepository;

    @PostMapping("add_translations")
    @PreAuthorize("hasRole('USER')")
    public ResponseEntity createTranslation(Authentication auth, @PathVariable("card_id") Long cardId, @Valid @RequestBody List<NewUserTranslation> translation) {
        String userEmail = ((User)auth.getPrincipal()).getUsername();
        var cardCandidate = cardRepository.findById(cardId);
        if (cardCandidate.isPresent()) {
            var card = cardCandidate.get();
            if (card.getUserDictionary().getOwner().getEmail().equals(userEmail)) {
                for (var newTrans : translation) {
                    var newDbTranslation = DbTranslation.builder()
                            .translation(newTrans.getTranslation())
                            .comment(newTrans.getComment())
                            .usageSample(newTrans.getUsageSample())
                            .transcription(newTrans.getTranscription()).build();
                    card.addTranslation(newDbTranslation);
                }
                cardRepository.save(card);
                return new ResponseEntity<>(MessageResponse.of(String.format("%d translations created successfully", translation.size())), HttpStatus.CREATED);
            } else {
                return new ResponseEntity<>(MessageResponse.of(String.format("The card %d doesnt belong to user %s", cardId, userEmail)), HttpStatus.FORBIDDEN);
            }
        }
        return new ResponseEntity<>(MessageResponse.of(String.format("The card %d doesnt exist", cardId)), HttpStatus.NOT_FOUND);
    }
}
