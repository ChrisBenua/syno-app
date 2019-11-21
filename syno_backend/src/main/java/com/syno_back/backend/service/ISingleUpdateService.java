package com.syno_back.backend.service;

public interface ISingleUpdateService<DbEntity, DtoType> {
    void update(DtoType dto, DbEntity dbEntity);
}
