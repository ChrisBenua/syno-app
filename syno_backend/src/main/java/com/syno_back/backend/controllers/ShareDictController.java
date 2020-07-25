package com.syno_back.backend.controllers;


import com.syno_back.backend.dto.MessageResponse;
import com.syno_back.backend.dto.NewDictShare;
import com.syno_back.backend.service.IShareDictControllerService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.userdetails.User;
import org.springframework.web.bind.annotation.*;

import javax.validation.Valid;

/**
 * Controller for handling dictionary shares
 */
@RequestMapping("/api/dict_share")
@RestController
public class ShareDictController {
    private static final Logger logger = LoggerFactory.getLogger(ShareDictController.class);

    @Autowired
    private IShareDictControllerService shareDictControllerService;

    /**
     * Processes creating new <code>DbDictShare</code>
     * @param auth Current user info
     * @param share DTO with sharing info
     * @return <code>ResponseEntity&lt;MessageResponse&gt;</code> with success or failure message
     */
    @PostMapping("/add_share")
    @PreAuthorize("hasRole('USER')")
    public ResponseEntity<?> addShare(Authentication auth, @Valid @RequestBody NewDictShare share) {
        logger.info("POST: /api/dict_share/add_share by user: {} {}", ((User)auth.getPrincipal()).getUsername(), share.toString());
        try {
            String uuidString = shareDictControllerService.addShare(((User)auth.getPrincipal()).getUsername(), share);
            return new ResponseEntity<>(MessageResponse.of(uuidString), HttpStatus.OK);
        } catch (Exception ex) {
            return new ResponseEntity<>(MessageResponse.of(ex.getMessage()), HttpStatus.BAD_REQUEST);
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

        try {
            var userDictionary = shareDictControllerService.cloneAndGetShare(email, shareUuid);
            return ResponseEntity.ok(userDictionary);
        } catch (Exception ex) {
            return new ResponseEntity<>(MessageResponse.of(ex.getMessage()), HttpStatus.BAD_REQUEST);
        }
    }
}