package com.syno_back.backend.service;

import org.springframework.data.util.Pair;

public interface IDtoMapper<DtoType, TargetType> {
    TargetType convert(DtoType dto, Iterable<Pair<String, ?>> additionalFields);
}
