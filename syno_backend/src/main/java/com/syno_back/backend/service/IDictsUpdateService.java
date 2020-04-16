package com.syno_back.backend.service;

import com.syno_back.backend.dto.UpdateRequestDto;
import com.syno_back.backend.model.DbUser;

public interface IDictsUpdateService {
    void performUpdates(DbUser user, UpdateRequestDto updateRequestDto);
}
