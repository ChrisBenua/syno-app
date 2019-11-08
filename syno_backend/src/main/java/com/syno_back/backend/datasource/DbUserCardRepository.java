package com.syno_back.backend.datasource;

import com.syno_back.backend.model.DbUserCard;
import com.syno_back.backend.model.DbUserDictionary;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface DbUserCardRepository extends JpaRepository<DbUserCard, Long> {
    List<DbUserCard> findByUserDictionary(DbUserDictionary userDictionary);

    List<DbUserCard> findByUserDictionary_Id(Long id);
}
