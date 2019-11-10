package com.syno_back.backend.service;

public interface IBatchUpdateEntityService<DtoType, OwnerType> {
    void updateWithOwnerCheck(Iterable<DtoType> dtoObject, OwnerType owner);

    void updateWith(Iterable<DtoType> dtoObject);
}
