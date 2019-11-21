package com.syno_back.backend.service;

import lombok.NonNull;
import org.springframework.data.util.Pair;
import org.springframework.lang.Nullable;

public interface IDtoMapper<DtoType, TargetType> {
    TargetType convert(@NonNull DtoType dto, @Nullable Iterable<Pair<String, ?>> additionalFields);
}
