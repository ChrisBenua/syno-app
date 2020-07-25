package com.syno_back.backend.service;

import com.syno_back.backend.dto.NewUser;
import com.syno_back.backend.model.DbUser;

import java.util.List;

public interface IAuthControllerService {
    DbUser createUser(NewUser newUser, List<String> roles, boolean isVerified, boolean sendEmail);
}
