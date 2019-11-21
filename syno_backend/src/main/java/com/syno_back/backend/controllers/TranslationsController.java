package com.syno_back.backend.controllers;

import com.syno_back.backend.datasource.DbTranslationRepository;
import com.syno_back.backend.datasource.DbUserCardRepository;
import com.syno_back.backend.dto.MessageResponse;
import com.syno_back.backend.dto.NewUserTranslation;
import com.syno_back.backend.dto.Translation;
import com.syno_back.backend.model.DbTranslation;
import com.syno_back.backend.model.DbUserDictionary;
import com.syno_back.backend.service.ICredentialProvider;
import com.syno_back.backend.service.IDtoMapper;
import com.syno_back.backend.service.ITranslationsAdderService;
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
@RequestMapping("/api/translations")
public class TranslationsController {
    @Autowired
    private DbUserCardRepository cardRepository;

    @Autowired
    private ICredentialProvider<DbUserDictionary, Authentication> dictCredentialProvider;

    @Autowired
    private ITranslationsAdderService translationsAdderService;

    @Autowired
    private DbTranslationRepository translationRepository;

    @Autowired
    private IDtoMapper<DbTranslation, Translation> mapper;


    @GetMapping("/get_translations")
    @PreAuthorize("hasRole('USER')")
    public ResponseEntity getTranslations(@RequestParam(name = "trans_ids", required = true) List<Long> ids) {
        var trans = translationRepository.findAllById(ids);
        return new ResponseEntity<>(trans.stream().map(tran -> mapper.convert(tran, null)), HttpStatus.OK);
    }

    @GetMapping("/get_translation")
    @PreAuthorize("hasRole('USER')")
    public ResponseEntity getTranslation(@RequestParam(name = "trans_id", required = true) Long id) {
        var trans = translationRepository.findById(id);
        if (trans.isPresent()) {
            return ResponseEntity.of(trans.map(tr -> mapper.convert(tr, null)));
        } else {
            return new ResponseEntity<>(MessageResponse.of(String.format("No such translation with id %d", id)), HttpStatus.NOT_FOUND);
        }
    }

    @PostMapping("/{card_id}/add_translations")
    @PreAuthorize("hasRole('USER')")
    public ResponseEntity createTranslation(Authentication auth, @PathVariable("card_id") Long cardId, @Valid @RequestBody List<NewUserTranslation> translation) {
        String userEmail = ((User)auth.getPrincipal()).getUsername();
        var cardCandidate = cardRepository.findById(cardId);
        if (cardCandidate.isPresent()) {
            var card = cardCandidate.get();
            if (dictCredentialProvider.check(card.getUserDictionary(), auth)) {
                translationsAdderService.addTranslationsToCard(translation, card);
                cardRepository.save(card);
                return new ResponseEntity<>(MessageResponse.of(String.format("%d translations created successfully", translation.size())), HttpStatus.ACCEPTED);
            } else {
                return new ResponseEntity<>(MessageResponse.of(String.format("The card %d doesnt belong to user %s", cardId, userEmail)), HttpStatus.FORBIDDEN);
            }
        }
        return new ResponseEntity<>(MessageResponse.of(String.format("The card %d doesnt exist", cardId)), HttpStatus.NOT_FOUND);
    }
}
