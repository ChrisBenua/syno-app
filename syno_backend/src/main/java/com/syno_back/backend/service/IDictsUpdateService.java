package com.syno_back.backend.service;

import com.syno_back.backend.dto.UpdateRequestDto;
import com.syno_back.backend.model.DbUser;

/**
 * Service for updating <code>DbUserDictionary</code>
 */
public interface IDictsUpdateService {
    /**
     * Updates all user's card with <code>UpdateRequestDto</code>
     * @param user user which dictionaries should be updated
     * @param updateRequestDto dto that contains update info
     */
    void performUpdates(DbUser user, UpdateRequestDto updateRequestDto);
}
