package com.syno_back.backend.datasource;

import com.syno_back.backend.model.DbUser;
import com.syno_back.backend.model.DbUserDictionary;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Collection;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface DbUserDictionaryRepository extends JpaRepository<DbUserDictionary, Long> {
    Optional<DbUserDictionary> findByPin(String pin);

    List<DbUserDictionary> findByPinIn(Collection<String> pins);

    Optional<DbUserDictionary> findByOwner_EmailAndPin(String email, String pin);

    List<DbUserDictionary> findByOwner_Email(String email);

    boolean existsByNameAndOwner_Email(String name, String email);

    boolean existsByNameAndOwner_Id(String name, Long id);

}
