package com.syno_back.backend.service;

import com.syno_back.backend.model.DbDictShare;
import com.syno_back.backend.model.DbUserDictionary;

public interface IDbDictShareFactory {
    DbDictShare createDictShare(DbUserDictionary dictionary);
}
