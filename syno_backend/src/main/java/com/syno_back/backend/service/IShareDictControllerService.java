package com.syno_back.backend.service;

import com.syno_back.backend.dto.NewDictShare;
import com.syno_back.backend.dto.UserDictionary;

public interface IShareDictControllerService {
    UserDictionary cloneAndGetShare(String email, String shareUuid);

    String addShare(String email, NewDictShare share);
}
