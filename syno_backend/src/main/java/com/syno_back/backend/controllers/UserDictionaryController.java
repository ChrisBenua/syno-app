package com.syno_back.backend.controllers;

import com.syno_back.backend.datasource.DbUserDictionaryRepository;
import com.syno_back.backend.datasource.UserRepository;
import com.syno_back.backend.dto.NewUserDictionary;
import com.syno_back.backend.dto.UpdateRequestDto;
import com.syno_back.backend.dto.UserDictionary;
import com.syno_back.backend.jwt.ResponseMessage;
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

@RestController
@RequestMapping("/api/dicts")
public class UserDictionaryController {

    @Autowired
    private DbUserDictionaryRepository userDictionaryRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private IDtoMapper<NewUserDictionary, DbUserDictionary> mapper;

    @Autowired
    private IDtoMapper<DbUserDictionary, UserDictionary> fromDtoMapper;

    @Autowired
    private IDictsUpdateService dictsUpdateService;

    @GetMapping(value = "/my_all", produces = MediaType.APPLICATION_JSON_VALUE)
    @PreAuthorize("hasRole('USER')")
    public ResponseEntity getUserDictionaries(Authentication auth) {
        var dtoResp = userDictionaryRepository.findByOwner_Email(((User)auth.getPrincipal()).getUsername()).stream().
                        map((dict) -> fromDtoMapper.convert(dict, null)).collect(Collectors.toList());
        return ResponseEntity.ok(dtoResp);
    }

    @PostMapping(value = "/new_dict")
    @PreAuthorize("hasRole('USER')")
    public ResponseEntity createUserDictionary(Authentication auth, @Valid @RequestBody NewUserDictionary newUserDictionary) {
        String userEmail = ((User)auth.getPrincipal()).getUsername();
        var owner = userRepository.findByEmail(userEmail);
        if (owner.isEmpty() || userDictionaryRepository.existsByNameAndOwner_Id(newUserDictionary.getName(), owner.get().getId())) {
            return new ResponseEntity<>("Dictionaries can't have same name", HttpStatus.BAD_REQUEST);
        }
        var newDbUserDict = mapper.convert(newUserDictionary, null);
        newDbUserDict = userDictionaryRepository.save(newDbUserDict);
        owner.get().addUserDictionary(newDbUserDict);
        userRepository.save(owner.get());

        return ResponseEntity.accepted().body(String.format("Dictionary with name %s created successfully", newUserDictionary.getName()));
    }

    @PostMapping(value = "/update")
    @PreAuthorize("hasRole('USER')")
    public ResponseEntity updateUserDicts(Authentication auth, @Valid @RequestBody UpdateRequestDto requestDto) {
        String userEmail = ((User)auth.getPrincipal()).getUsername();
        var owner = userRepository.findByEmail(userEmail);

        dictsUpdateService.performUpdates(owner.get(), requestDto);

        return ResponseEntity.ok(new ResponseMessage("Updated successfully"));
    }
}
