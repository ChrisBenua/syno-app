package com.syno_back.backend.service;

import lombok.NonNull;
import org.springframework.data.util.Pair;
import org.springframework.lang.Nullable;

/**
 * Service interface for mapping <code>DtoType</code> instance to <code>TargetType</code>
 * @param <DtoType> type of source instance
 * @param <TargetType> type of target instance
 */
public interface IDtoMapper<DtoType, TargetType> {
    /**
     * Converts <code>dto</code> to <code>TargetType</code>
     * @param dto instance to be converted
     * @param additionalFields additional fields
     * @return new <code>TargetType</code> instance
     */
    TargetType convert(@NonNull DtoType dto, @Nullable Iterable<Pair<String, ?>> additionalFields);
}
