package com.syno_back.backend.datasource;

import com.syno_back.backend.model.DbUser;
import com.syno_back.backend.model.DbUserDictionary;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface DbUserDictionaryRepository extends JpaRepository<DbUserDictionary, Long> {
    List<DbUserDictionary> findByOwner(DbUser owner);

    List<DbUserDictionary> findByOwner_Id(Long id);

    List<DbUserDictionary> findByOwner_Email(String email);

    boolean existsByNameAndOwner_Email(String name, String email);

    boolean existsByNameAndOwner_Id(String name, Long id);

}
