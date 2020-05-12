package com.syno_back.backend.datasource;

import com.syno_back.backend.model.DbTranslation;
import com.syno_back.backend.model.DbUserCard;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Collection;
import java.util.List;
import java.util.Optional;

/**
 * Repository interface for CRUD operations with <code>DbTranslation</code> in DB
 */
public interface DbTranslationRepository extends JpaRepository<DbTranslation, Long> {
}
