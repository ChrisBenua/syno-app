package com.syno_back.backend.datasource;

import com.syno_back.backend.model.DbDictShare;
import com.syno_back.backend.model.DbUser;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface DbDictShareRepository extends JpaRepository<DbDictShare, Long> {
    Optional<DbDictShare> findBySharedDictionary_Id(Long sharedDictId);

    List<DbDictShare> findAllByOwner(DbUser owner);
}
