package com.syno_back.backend.datasource;

import com.syno_back.backend.model.DbTranslation;
import com.syno_back.backend.model.DbUserCard;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Collection;
import java.util.List;
import java.util.Optional;

public interface DbTranslationRepository extends JpaRepository<DbTranslation, Long> {
    Optional<DbTranslation> findOneByPin(String pin);

    List<DbTranslation> findByPinIn(Collection<String> pin);

    List<DbTranslation> findBySourceCard(DbUserCard card);

    List<DbTranslation> findBySourceCard_Id(Long id);
}
