package com.syno_back.backend.controllers;

import com.syno_back.backend.dto.MessageResponse;
import com.syno_back.backend.dto.UpdateRequestDto;
import com.syno_back.backend.dto.UserDictionary;
import com.syno_back.backend.service.IUserDictionaryControllerService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.userdetails.User;
import org.springframework.web.bind.annotation.*;

import javax.validation.Valid;
import java.util.List;
import java.util.stream.Collectors;

/**
 * Controller for getting and updating <code>DbUserDictionaries</code>
 */
@RestController
@RequestMapping("/api/dicts")
public class UserDictionaryController {
    private static final Logger logger = LoggerFactory.getLogger(UserDictionaryController.class);

    @Autowired
    private IUserDictionaryControllerService controllerService;

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
        logger.info("GET: /api/dicts/my_all for user {}", ((User)auth.getPrincipal()).getUsername());

        return ResponseEntity.ok(controllerService.allForUser(((User)auth.getPrincipal()).getUsername()).collect(Collectors.toList()));
    }

    /**
     * Updates user's dictionaries with state on client
     * @param auth current user info
     * @param requestDto DTO with some client dictionaries(pagination ready)
     * @return <code>ResponseEntity</code> with message
     */
    @PostMapping(value = "/update")
    @PreAuthorize("hasRole('USER')")
    public ResponseEntity<?> updateUserDicts(Authentication auth, @Valid @RequestBody UpdateRequestDto requestDto) {
        logger.info("POST: api/dicts/update for user {}", ((User)auth.getPrincipal()).getUsername());

        String userEmail = ((User)auth.getPrincipal()).getUsername();

        try {
            controllerService.performUpdates(userEmail, requestDto);
            return ResponseEntity.ok(new MessageResponse("Updated successfully"));
        } catch (Exception ex) {
            return new ResponseEntity<>(new MessageResponse(String.format("Failed: %s", ex.getMessage())), HttpStatus.BAD_REQUEST);
        }

    }
}
