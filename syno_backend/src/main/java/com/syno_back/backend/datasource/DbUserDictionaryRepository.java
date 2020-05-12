package com.syno_back.backend.datasource;

import com.syno_back.backend.model.DbUser;
import com.syno_back.backend.model.DbUserDictionary;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Collection;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

/**
 * Repository interface for CRUD operation with <code>DbUserDictionary</code>
 */
public interface DbUserDictionaryRepository extends JpaRepository<DbUserDictionary, Long> {
    /**
     * Finds <code>DbUserDictionary</code> by given pin
     * @param pin unique DbUserDictionary id
     * @return Optional with <code>DbUserDictionary</code> inside it if there is such
     */
    Optional<DbUserDictionary> findByPin(String pin);

    /**
     * Finds <code>DbUserDictionary</code> by owner's email and its pin
     * @param email owner's email
     * @param pin unique DbUserDictionary id
     * @return  Optional with <code>DbUserDictionary</code> inside it if there is such
     */
    Optional<DbUserDictionary> findByOwner_EmailAndPin(String email, String pin);

    /**
     * Finds all <code>DbUserDictionary</code> by owner's email
     * @param email owner's email
     * @return List of <code>DbUserDictionary</code> that user with given email owns
     */
    List<DbUserDictionary> findByOwner_Email(String email);
}
