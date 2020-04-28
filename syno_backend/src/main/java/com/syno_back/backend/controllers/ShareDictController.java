package com.syno_back.backend.controllers;


import com.syno_back.backend.datasource.DbDictShareRepository;
import com.syno_back.backend.datasource.DbUserDictionaryRepository;
import com.syno_back.backend.datasource.UserRepository;
import com.syno_back.backend.dto.MessageResponse;
import com.syno_back.backend.dto.NewDictShare;
import com.syno_back.backend.dto.UserDictionary;
import com.syno_back.backend.model.DbUserDictionary;
import com.syno_back.backend.service.ICredentialProvider;
import com.syno_back.backend.service.IDictShareService;
import com.syno_back.backend.service.IDtoMapper;
import com.syno_back.backend.service.IEntityCloner;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.userdetails.User;
import org.springframework.web.bind.annotation.*;

import javax.validation.Valid;
import java.util.Optional;
import java.util.UUID;

@RequestMapping("/api/dict_share")
@RestController
public class ShareDictController {

    private DbUserDictionaryRepository dictionaryRepository;

    private DbDictShareRepository shareRepository;

    private ICredentialProvider<DbUserDictionary, Authentication> dictCredentialProvider;

    private IDictShareService dictShareService;

    private IEntityCloner<DbUserDictionary> dictCloner;

    private UserRepository userRepository;

    private IDtoMapper<DbUserDictionary, UserDictionary> mapper;

    public ShareDictController(@Autowired ICredentialProvider<DbUserDictionary, Authentication> provider,
                               @Autowired DbDictShareRepository shareRepository,
                               @Autowired DbUserDictionaryRepository repository, @Autowired IDictShareService shareService,
                               @Autowired IEntityCloner<DbUserDictionary> dictCloner,
                               @Autowired UserRepository userRepository, @Autowired IDtoMapper<DbUserDictionary, UserDictionary> mapper) {
        this.dictCredentialProvider = provider;
        this.shareRepository = shareRepository;
        this.dictionaryRepository = repository;
        this.dictShareService = shareService;
        this.dictCloner = dictCloner;
        this.userRepository = userRepository;
        this.mapper = mapper;
    }

    @PostMapping("/add_share")
    @PreAuthorize("hasRole('USER')")
    public ResponseEntity addShare(Authentication auth, @Valid @RequestBody NewDictShare share) {
        Optional<DbUserDictionary> dictCandidate = this.dictionaryRepository.findByPin(share.getShareDictPin());
        if (dictCandidate.isPresent()) {
            var dict = dictCandidate.get();
            if (dictCredentialProvider.check(dict, auth)) {
                String uuidString = dictShareService.getDictShareCode(dict);
                return new ResponseEntity<>(MessageResponse.of(uuidString), HttpStatus.OK);
            } else {
                String userEmail = ((User)auth.getPrincipal()).getUsername();
                return new ResponseEntity<>(MessageResponse.of(String.format("Dict with pin = %s doesnt belong to user with email = %s",
                        share.getShareDictPin(), userEmail)), HttpStatus.FORBIDDEN);
            }
        } else {
            return new ResponseEntity<>(MessageResponse.of(String.format("Dict with id = %s doesnt exist", share.getShareDictPin())), HttpStatus.NOT_FOUND);
        }
    }

    @GetMapping("/get_share/{share_id}")
    @PreAuthorize("hasRole('USER')")
    public ResponseEntity cloneSharedShare(Authentication auth, @PathVariable(name = "share_id") String shareUuid) {
        String email = ((User)auth.getPrincipal()).getUsername();
        var candidate = shareRepository.findByShareUUID(UUID.fromString(shareUuid));

        if (candidate.isPresent()) {
            var share = candidate.get();

            if (!share.getOwner().getEmail().equals(email)) {
                var dict = candidate.get().getSharedDictionary();

                if (dictionaryRepository.findByOwner_EmailAndPin(email, dict.getPin()).isPresent()) {
                    return new ResponseEntity<>(MessageResponse.of("You have already cloned this dictionary"), HttpStatus.BAD_REQUEST);
                }

                var clonedDict = dictCloner.clone(dict);

                var user = userRepository.findByEmail(email).orElseThrow();

                clonedDict.setOwner(user);

                clonedDict = dictionaryRepository.save(clonedDict);

                return new ResponseEntity<>(mapper.convert(clonedDict,null), HttpStatus.OK);
            } else {
                return new ResponseEntity<>(MessageResponse.of(String.format("User with email %s tries to clone its own dict", email)), HttpStatus.BAD_REQUEST);
            }

        } else {
            return new ResponseEntity<>(MessageResponse.of(String.format("No share with uuid: %s", shareUuid)), HttpStatus.NOT_FOUND);
        }
    }
}