package com.syno_back.backend.service;

import com.syno_back.backend.model.DbUserDictionary;

import java.util.UUID;

/**
 * Service for sharing dictionaries
 */
public interface IDictShareService {
    /**
     * Gets <code>DbDictShare</code> UUID or creates one if there was none
     * @param dictionary dictionary that was shared
     * @return UUID of <code>DbDictShare</code> for this
     */
    String getDictShareCode(DbUserDictionary dictionary);
}
