package com.syno_back.backend.datasource;

import com.syno_back.backend.model.DbUser;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.repository.query.Param;

import java.util.Optional;

public interface UserRepository extends JpaRepository<DbUser, Long> {

    boolean existsByEmail(@Param("email") String email);

    Optional<DbUser> findByEmail(@Param("email") String email);
}
