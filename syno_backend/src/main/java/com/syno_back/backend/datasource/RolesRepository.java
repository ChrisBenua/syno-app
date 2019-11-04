package com.syno_back.backend.datasource;

import com.syno_back.backend.model.DbRole;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.repository.query.Param;

public interface RolesRepository extends JpaRepository<DbRole, Long> {

    DbRole findByName(@Param("name") String name);
}
