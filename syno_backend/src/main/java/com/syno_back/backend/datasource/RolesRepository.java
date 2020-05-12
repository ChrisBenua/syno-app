package com.syno_back.backend.datasource;

import com.syno_back.backend.model.DbRole;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.repository.query.Param;

/**
 * Repository interface for CRUD operations with <code>DbRole</code> in DB
 */
public interface RolesRepository extends JpaRepository<DbRole, Long> {
    /**
     * Finds <code>DbRole</code> by given name
     * @param name name of role
     * @return <code>DbRole</code> with given name
     */
    DbRole findByName(@Param("name") String name);
}
