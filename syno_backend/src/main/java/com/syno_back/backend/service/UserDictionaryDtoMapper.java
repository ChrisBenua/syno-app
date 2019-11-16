package com.syno_back.backend.service;

import com.syno_back.backend.dto.NewUserDictionary;
import com.syno_back.backend.model.DbUserDictionary;
import lombok.extern.log4j.Log4j2;
import org.springframework.data.util.Pair;
import org.springframework.stereotype.Component;

import java.lang.reflect.InvocationTargetException;

@Log4j2
@Component
public class UserDictionaryDtoMapper implements IDtoMapper<NewUserDictionary, DbUserDictionary> {
    @Override
    public DbUserDictionary convert(NewUserDictionary dto, Iterable<Pair<String, ?>> additionalFields) {
        var builder = DbUserDictionary.builder().name(dto.getName());

        try {
            if (additionalFields != null) {
                for (var fieldNameAndVal : additionalFields) {
                    builder.getClass().getMethod(fieldNameAndVal.getFirst(), fieldNameAndVal.getSecond().getClass()).invoke(builder, fieldNameAndVal.getSecond());
                }
            }
        } catch (NoSuchMethodException ex) {
            log.error("Didn't find builder method in converting " + dto.getClass().getName() + " to " + DbUserDictionary.class.getName() +
                    "\nError message: " + ex.getMessage());
            throw new RuntimeException(ex);
        } catch (IllegalAccessException | InvocationTargetException e) {
            e.printStackTrace();
            throw new RuntimeException(e);
        }

        return builder.build();
    }
}
