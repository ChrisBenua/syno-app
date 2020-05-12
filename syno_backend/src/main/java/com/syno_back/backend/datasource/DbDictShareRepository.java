package com.syno_back.backend.datasource;

import com.syno_back.backend.model.DbDictShare;
import com.syno_back.backend.model.DbUser;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

/**
 * Repository interface for fetching <code>DbDictShare</code> from DB
 */
public interface DbDictShareRepository extends JpaRepository<DbDictShare, Long> {
    /**
     * Finds share by shared dictionary id
     * @param sharedDictId dictionary DB id
     * @return Optional with found <code>DbDictShare</code> inside
     */
    Optional<DbDictShare> findBySharedDictionary_Id(Long sharedDictId);

    /**
     * Finds share by its UUID
     * @param uuid <code>DbDictShare</code> unique id
     * @return Option with found <code>DbDictShare</code> inside if there is such
     */
    Optional<DbDictShare> findByShareUUID(UUID uuid);
}
