package com.syno_back.backend.service;

import com.syno_back.backend.model.DbDictShare;
import com.syno_back.backend.model.DbUserDictionary;

/**
 * Service for creating <code>DbDictShare</code>
 */
public interface IDbDictShareFactory {
    /**
     * Creates new <code>DbDictShare</code> from given <code>DbUserDictionary</code>
     * @param dictionary dictionary to be shared
     * @return constructed <code>DbDictShare</code>
     */
    DbDictShare createDictShare(DbUserDictionary dictionary);
}
