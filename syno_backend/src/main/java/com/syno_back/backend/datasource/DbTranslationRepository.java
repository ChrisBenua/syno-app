package com.syno_back.backend.datasource;

import com.syno_back.backend.model.DbTranslation;
import com.syno_back.backend.model.DbUserCard;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface DbTranslationRepository extends JpaRepository<DbTranslation, Long> {
    List<DbTranslation> findBySourceCard(DbUserCard card);

    List<DbTranslation> findBySourceCard_Id(Long id);
}
