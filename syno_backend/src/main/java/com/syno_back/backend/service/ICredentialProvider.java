package com.syno_back.backend.service;

public interface ICredentialProvider<SubjectType, OwnerType> {
    boolean check(SubjectType subject, OwnerType owner);
}
