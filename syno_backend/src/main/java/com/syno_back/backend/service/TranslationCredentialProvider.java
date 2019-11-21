package com.syno_back.backend.service;

import com.syno_back.backend.model.DbTranslation;
import com.syno_back.backend.model.DbUserCard;
import org.springframework.stereotype.Component;

@Component
public class TranslationCredentialProvider implements ICredentialProvider<DbTranslation, DbUserCard> {
    @Override
    public boolean check(DbTranslation subject, DbUserCard owner) {
        return subject.getSourceCard().getId().equals(owner.getId());
    }
}
