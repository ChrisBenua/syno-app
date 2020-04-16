package com.syno_back.backend.datasource;

import com.syno_back.backend.model.DbUser;
import com.syno_back.backend.model.DbUserCard;
import com.syno_back.backend.model.DbUserDictionary;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Collection;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface DbUserCardRepository extends JpaRepository<DbUserCard, Long> {
    Optional<DbUserCard> findOneByPin(String pin);

    List<DbUserCard> findByPinIn(Collection<String> pin);

    List<DbUserCard> findByUserDictionary(DbUserDictionary userDictionary);

    List<DbUserCard> findByUserDictionary_Id(Long id);
}
