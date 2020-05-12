package com.syno_back.backend.controllers;

import com.syno_back.backend.datasource.DbUserDictionaryRepository;
import com.syno_back.backend.datasource.UserRepository;
import com.syno_back.backend.dto.MessageResponse;
import com.syno_back.backend.dto.UpdateRequestDto;
import com.syno_back.backend.dto.UserDictionary;
import com.syno_back.backend.model.DbUserDictionary;
import com.syno_back.backend.service.IDictsUpdateService;
import com.syno_back.backend.service.IDtoMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.util.Pair;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.userdetails.User;
import org.springframework.web.bind.annotation.*;


import javax.validation.Valid;
import java.security.Principal;
import java.util.List;
import java.util.stream.Collectors;

/**
 * Controller for getting and updating <code>DbUserDictionaries</code>
 */
@RestController
@RequestMapping("/api/dicts")
public class UserDictionaryController {

    /**
     * Repository for fetching  <code>DbUserDictionary</code>
     */
    @Autowired
    private DbUserDictionaryRepository userDictionaryRepository;

    /**
     * Repository for fetching <code>DbUser</code>
     */
    @Autowired
    private UserRepository userRepository;

    /**
     * Service for mapping <code>DbUserDictionary</code> to <code>UserDictionary</code>
     */
    @Autowired
    private IDtoMapper<DbUserDictionary, UserDictionary> fromDtoMapper;

    /**
     * Service for updating/creating/deleting <code>DbUserDictionary</code>
     */
    @Autowired
    private IDictsUpdateService dictsUpdateService;

    /**
     * Gets all user's dictionaries
     * Will add pagination later
     * @param auth Current user info
     * @return <code>ResponseEntity</code> with all user's <code>DbUserDictionaries</code> inside
     * @todo pagination
     */
    @GetMapping(value = "/my_all", produces = MediaType.APPLICATION_JSON_VALUE)
    @PreAuthorize("hasRole('USER')")
    public ResponseEntity<List<UserDictionary>> getUserDictionaries(Authentication auth) {
        var dtoResp = userDictionaryRepository.findByOwner_Email(((User)auth.getPrincipal()).getUsername()).stream().
                        map((dict) -> fromDtoMapper.convert(dict, null)).collect(Collectors.toList());
        return ResponseEntity.ok(dtoResp);
    }

    /**
     * Updates user's dictionaries with state on client
     * @param auth current user info
     * @param requestDto DTO with some client dictionaries(pagination ready)
     * @return <code>ResponseEntity</code> with message
     */
    @PostMapping(value = "/update")
    @PreAuthorize("hasRole('USER')")
    public ResponseEntity updateUserDicts(Authentication auth, @Valid @RequestBody UpdateRequestDto requestDto) {
        String userEmail = ((User)auth.getPrincipal()).getUsername();
        var owner = userRepository.findByEmail(userEmail);

        dictsUpdateService.performUpdates(owner.get(), requestDto);

        return ResponseEntity.ok(new MessageResponse("Updated successfully"));
    }
}
