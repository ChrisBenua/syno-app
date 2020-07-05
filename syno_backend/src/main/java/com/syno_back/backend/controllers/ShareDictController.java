package com.syno_back.backend.controllers;


import com.syno_back.backend.datasource.DbDictShareRepository;
import com.syno_back.backend.datasource.DbUserDictionaryRepository;
import com.syno_back.backend.datasource.UserRepository;
import com.syno_back.backend.dto.MessageResponse;
import com.syno_back.backend.dto.NewDictShare;
import com.syno_back.backend.dto.UserDictionary;
import com.syno_back.backend.model.DbDictShare;
import com.syno_back.backend.model.DbUserDictionary;
import com.syno_back.backend.service.ICredentialProvider;
import com.syno_back.backend.service.IDictShareService;
import com.syno_back.backend.service.IDtoMapper;
import com.syno_back.backend.service.IEntityCloner;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.userdetails.User;
import org.springframework.web.bind.annotation.*;

import javax.validation.Valid;
import java.security.Principal;
import java.util.Optional;
import java.util.UUID;

/**
 * Controller for handling dictionary shares
 */
@RequestMapping("/api/dict_share")
@RestController
public class ShareDictController {
    private static final Logger logger = LoggerFactory.getLogger(ShareDictController.class);
    /**
     * Repository for fetching <code>DbUserDictionary</code> from DB
     */
    private DbUserDictionaryRepository dictionaryRepository;

    /**
     * Repository for fetching and updating <code>DbDictShare</code>
     */
    private DbDictShareRepository shareRepository;

    /**
     * Service for checking that only owner can create share with given <code>DbUserDictionary</code>
     */
    private ICredentialProvider<DbUserDictionary, Authentication> dictCredentialProvider;

    /**
     * Service for generating <code>DbDictShare</code>
     */
    private IDictShareService dictShareService;

    /**
     * Service for cloning <code>DbUserDictionary</code>
     */
    private IEntityCloner<DbUserDictionary> dictCloner;

    /**
     * Repository for fetching <code>DbUser</code> from DB
     */
    private UserRepository userRepository;

    /**
     * Service for mapping <code>DbUserDictionary</code> DB instance to dto <code>UserDictionary</code>
     */
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

    /**
     * Processes creating new <code>DbDictShare</code>
     * @param auth Current user info
     * @param share DTO with sharing info
     * @return <code>ResponseEntity&lt;MessageResponse&gt;</code> with success or failure message
     */
    @PostMapping("/add_share")
    @PreAuthorize("hasRole('USER')")
    public ResponseEntity addShare(Authentication auth, @Valid @RequestBody NewDictShare share) {
        logger.info("POST: /api/dict_share/add_share by user: {} {}", ((User)auth.getPrincipal()).getUsername(), share.toString());
        Optional<DbUserDictionary> dictCandidate = this.dictionaryRepository.findByPin(share.getShareDictPin());
        if (dictCandidate.isPresent()) {
            var dict = dictCandidate.get();
            if (dictCredentialProvider.check(dict, auth)) {
                String uuidString = dictShareService.getDictShareCode(dict);

                logger.info("Shared successfully!");
                return new ResponseEntity<>(MessageResponse.of(uuidString), HttpStatus.OK);
            } else {
                String userEmail = ((User)auth.getPrincipal()).getUsername();
                logger.info("Shared failed, user {} doesnt own dict with pin {}", userEmail, share.getShareDictPin());
                return new ResponseEntity<>(MessageResponse.of(String.format("Dict with pin = %s doesnt belong to user with email = %s",
                        share.getShareDictPin(), userEmail)), HttpStatus.FORBIDDEN);
            }
        } else {
            logger.info("Dictionary with pin: {} doesnt exist", share.getShareDictPin());
            return new ResponseEntity<>(MessageResponse.of(String.format("Dict with id = %s doesnt exist", share.getShareDictPin())), HttpStatus.NOT_FOUND);
        }
    }

    /**
     * Processes getting <code>DbDictShare</code>
     * @param auth Current user info
     * @param shareUuid UUID of wanted <code>DbDictShare</code>
     * @return <code>ResponseEntity&lt;UserDictionary&gt;</code> with shared dictionary on success and <code>ResponseEntity&lt;MessageResponse&gt;</code>
     */
    @GetMapping("/get_share/{share_id}")
    @PreAuthorize("hasRole('USER')")
    public ResponseEntity cloneSharedShare(Authentication auth, @PathVariable(name = "share_id") String shareUuid) {
        String email = ((User)auth.getPrincipal()).getUsername();
        logger.info("GET: /api/dict_share/get_share/{} for user {}", shareUuid, email);

        Optional<DbDictShare> candidate = Optional.empty();

        try {
            candidate = shareRepository.findByShareUUID(UUID.fromString(shareUuid));
        } catch (IllegalArgumentException ex) {
            logger.info("Pin {} doesnt look like UUID", shareUuid);
            return new ResponseEntity<>(MessageResponse.of("Wrong format for share's id"), HttpStatus.BAD_REQUEST);
        }

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

                logger.info("Cloned dict: {} for user: {} successfully", shareUuid, email);

                return new ResponseEntity<>(mapper.convert(clonedDict,null), HttpStatus.OK);
            } else {
                logger.info("User {} tries to clone its own dict", email);
                return new ResponseEntity<>(MessageResponse.of(String.format("User with email %s tries to clone its own dict", email)), HttpStatus.BAD_REQUEST);
            }
        } else {
            logger.info("Share with uuid: {} not found", shareUuid);
            return new ResponseEntity<>(MessageResponse.of(String.format("No share with uuid: %s", shareUuid)), HttpStatus.NOT_FOUND);
        }
    }
}