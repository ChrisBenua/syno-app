package com.syno_back.backend.service;

import com.syno_back.backend.model.DbUserCard;
import com.syno_back.backend.model.DbUserDictionary;
import org.springframework.stereotype.Component;

@Component
public class UserCardCredentialProvider implements  ICredentialProvider<DbUserCard, DbUserDictionary> {
    @Override
    public boolean check(DbUserCard subject, DbUserDictionary owner) {
        return subject.getUserDictionary().getId().equals(owner.getId());
    }
}
