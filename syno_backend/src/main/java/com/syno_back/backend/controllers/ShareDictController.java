package com.syno_back.backend.controllers;


import com.syno_back.backend.datasource.DbDictShareRepository;
import com.syno_back.backend.datasource.DbUserDictionaryRepository;
import com.syno_back.backend.datasource.UserRepository;
import com.syno_back.backend.dto.MessageResponse;
import com.syno_back.backend.dto.NewDictShare;
import com.syno_back.backend.model.DbUserDictionary;
import com.syno_back.backend.service.ICredentialProvider;
import com.syno_back.backend.service.IDictShareService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.userdetails.User;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import javax.validation.Valid;
import java.util.Optional;

@RequestMapping("/api/dict_share")
@RestController
public class ShareDictController {

    private DbUserDictionaryRepository dictionaryRepository;

    private ICredentialProvider<DbUserDictionary, Authentication> dictCredentialProvider;

    private IDictShareService dictShareService;

    public ShareDictController(@Autowired ICredentialProvider<DbUserDictionary, Authentication> provider,
                                @Autowired DbUserDictionaryRepository repository, @Autowired IDictShareService shareService) {
        this.dictCredentialProvider = provider;
        this.dictionaryRepository = repository;
        this.dictShareService = shareService;
    }

    @PostMapping("/add_share")
    @PreAuthorize("hasRole('USER')")
    public ResponseEntity addShare(Authentication auth, @Valid @RequestBody NewDictShare share) {
        Optional<DbUserDictionary> dictCandidate = this.dictionaryRepository.findById(share.getShareDictId());
        if (dictCandidate.isPresent()) {
            var dict = dictCandidate.get();
            if (dictCredentialProvider.check(dict, auth)) {
                String uuidString = dictShareService.getDictShareCode(dict);
                return new ResponseEntity<>(MessageResponse.of(uuidString), HttpStatus.OK);
            } else {
                String userEmail = ((User)auth.getPrincipal()).getUsername();
                return new ResponseEntity<>(MessageResponse.of(String.format("Dict with id = %d doesnt belong to user with email = %s",
                        share.getShareDictId(), userEmail)), HttpStatus.FORBIDDEN);
            }
        } else {
            return new ResponseEntity<>(MessageResponse.of(String.format("Dict with id = %d doesnt exist", share.getShareDictId())), HttpStatus.NOT_FOUND);
        }
    }
}
