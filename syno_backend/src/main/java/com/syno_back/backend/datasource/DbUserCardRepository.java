package com.syno_back.backend.datasource;

import com.syno_back.backend.model.DbUser;
import com.syno_back.backend.model.DbUserCard;
import com.syno_back.backend.model.DbUserDictionary;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Collection;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

/**
 * Repository interface for CRUD operation with <code>DbUserCard</code> in DB
 */
public interface DbUserCardRepository extends JpaRepository<DbUserCard, Long> {
}
