package com.syno_back.backend.helper;

import lombok.extern.log4j.Log4j2;
import org.springframework.data.util.Pair;

import java.lang.reflect.InvocationTargetException;

@Log4j2
public class ReflectionUtils {
    /**
     * Calls given methods with one given parameter
     * @param builder object which functions to call
     * @param additionalFields List of Pairs where first is function name and second is that function parameter
     */
    public static void setFields(Object builder, Iterable<Pair<String, ?>> additionalFields) {
        try {
            if (additionalFields != null) {
                for (var fieldNameAndVal : additionalFields) {
                    builder.getClass().getMethod(fieldNameAndVal.getFirst(), fieldNameAndVal.getSecond().getClass()).invoke(builder, fieldNameAndVal.getSecond());
                }
            }
        } catch (NoSuchMethodException ex) {
            log.error("Didn't find builder method in adding fields to " + builder.getClass().getName() +
                    "\nError message: " + ex.getMessage());
            throw new RuntimeException(ex);
        } catch (IllegalAccessException | InvocationTargetException e) {
            e.printStackTrace();
            throw new RuntimeException(e);
        }
    }
}
