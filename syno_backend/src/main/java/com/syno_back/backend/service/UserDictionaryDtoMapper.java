package com.syno_back.backend.service;

import com.syno_back.backend.dto.NewUserDictionary;
import com.syno_back.backend.helper.ReflectionUtils;
import com.syno_back.backend.model.DbUserDictionary;
import lombok.extern.log4j.Log4j2;
import org.springframework.data.util.Pair;
import org.springframework.stereotype.Component;

@Log4j2
@Component
public class UserDictionaryDtoMapper implements IDtoMapper<NewUserDictionary, DbUserDictionary> {
    @Override
    public DbUserDictionary convert(NewUserDictionary dto, Iterable<Pair<String, ?>> additionalFields) {
        var builder = DbUserDictionary.builder().name(dto.getName());

        ReflectionUtils.setFields(builder, additionalFields);

        return builder.build();
    }
}
