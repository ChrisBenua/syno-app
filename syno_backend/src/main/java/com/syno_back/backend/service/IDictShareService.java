package com.syno_back.backend.service;

import com.syno_back.backend.model.DbUserDictionary;

import java.util.UUID;

public interface IDictShareService {
    String getDictShareCode(DbUserDictionary dictionary);
}
