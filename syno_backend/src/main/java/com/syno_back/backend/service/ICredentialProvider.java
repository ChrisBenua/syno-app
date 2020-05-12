package com.syno_back.backend.service;

/**
 * Service for checking that owner can modify subject
 * @param <SubjectType> type of subject instance
 * @param <OwnerType> type of owner instance
 */
public interface ICredentialProvider<SubjectType, OwnerType> {
    /**
     * Checks that owner can modify subject
     * @param subject subject to check access from owner
     * @param owner instance that tries to modify subject
     * @return true if owner card modify subject false otherwise
     */
    boolean check(SubjectType subject, OwnerType owner);
}
