package com.syno_back.backend.service;

import com.syno_back.backend.model.DbUserDictionary;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.userdetails.User;
import org.springframework.stereotype.Component;

/**
 * Service for checking that User owns <code>DbUserDictionary</code>
 */
@Component
public class UserDictionaryCredentialProvider implements ICredentialProvider<DbUserDictionary, Authentication> {
    @Override
    public boolean check(DbUserDictionary subject, Authentication auth) {
        String userEmail = ((User)auth.getPrincipal()).getUsername();
        return subject.getOwner().getEmail().equals(userEmail);
    }
}
