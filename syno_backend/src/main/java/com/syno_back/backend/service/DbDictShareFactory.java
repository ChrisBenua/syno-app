package com.syno_back.backend.service;


import com.syno_back.backend.model.DbDictShare;
import com.syno_back.backend.model.DbUserDictionary;
import org.springframework.stereotype.Component;

@Component
public class DbDictShareFactory implements IDbDictShareFactory {
    @Override
    public DbDictShare createDictShare(DbUserDictionary dictionary) {
        return DbDictShare.builder().owner(dictionary.getOwner()).sharedDictionary(dictionary).build();
    }
}
