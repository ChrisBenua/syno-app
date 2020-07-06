package com.syno_back.backend.datasource;

import com.syno_back.backend.model.DbUser;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

/**
 * Repository interface for CRUD operations with <code>DbUser</code> in DB
 */
public interface UserRepository extends JpaRepository<DbUser, Long> {
    /**
     * Finds user by given email
     * @param email user's email
     * @return Optional with <code>DbUser</code> inside if there is such user
     */
    Optional<DbUser> findByEmail(@Param("email") String email);

    List<DbUser> findByIsVerifiedFalse();
}
