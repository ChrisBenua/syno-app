package com.syno_back.backend.service;

import com.syno_back.backend.datasource.DbTranslationRepository;
import com.syno_back.backend.dto.UpdateUserTranslationDto;
import com.syno_back.backend.model.DbTranslation;
import com.syno_back.backend.model.DbUserCard;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

/**
 * Service for updating <code>DbTranslation</code>
 */
@Component
public class TranslationsUpdateServiceImpl implements IUpdateTranslationsService {

    /**
     * Repository for CRUD operations with <code>DbTranslation</code>
     */
    private DbTranslationRepository translationRepository;

    /**
     * Service for mapping <code>UpdateUserTranslationDto</code> to <code>DbTranslation</code>
     */
    private IDtoMapper<UpdateUserTranslationDto, DbTranslation> mapper;

    public TranslationsUpdateServiceImpl(
            @Autowired DbTranslationRepository translationRepository,
            @Autowired IDtoMapper<UpdateUserTranslationDto, DbTranslation> mapper
    ) {
        this.translationRepository = translationRepository;
        this.mapper = mapper;
    }

    @Override
    public void performUpdate(DbUserCard card, List<UpdateUserTranslationDto> updateTranslations) {
        var allTranslation = card.getTranslations();
        var existingPins = updateTranslations.stream().map(UpdateUserTranslationDto::getPin).collect(Collectors.toSet());

        Set<String> updatedPins = new HashSet<>();
        List<DbTranslation> toRemove = new ArrayList<>();
        for (var dbTranslation: allTranslation) {
            if (existingPins.contains(dbTranslation.getPin())) {
                //update
                updatedPins.add(dbTranslation.getPin());

                var updateTransDto = updateTranslations.stream().filter(el -> el.getPin().equals(dbTranslation.getPin())).findAny();

                if (updateTransDto.isPresent()) {
                    dbTranslation.setComment(updateTransDto.get().getComment());
                    dbTranslation.setTranscription(updateTransDto.get().getTranscription());
                    dbTranslation.setTranslation(updateTransDto.get().getTranslation());
                    dbTranslation.setUsageSample(updateTransDto.get().getUsageSample());
                }

            } else {
                //delete
                toRemove.add(dbTranslation);
            }
        }

        for (var dbTranslation : toRemove) {
            card.removeTranslation(dbTranslation);
            this.translationRepository.delete(dbTranslation);
        }

        for (var updateTranslation: updateTranslations) {
            if (!updatedPins.contains(updateTranslation.getPin())) {
                var dbTranslation = this.mapper.convert(updateTranslation, null);
                card.addTranslation(dbTranslation);
            }
        }
    }
}
