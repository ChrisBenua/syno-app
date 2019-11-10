package com.syno_back.backend.service;

import com.syno_back.backend.datasource.DbUserCardRepository;
import com.syno_back.backend.dto.UpdateUserCard;
import com.syno_back.backend.model.DbUserCard;
import org.junit.jupiter.api.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;
import org.springframework.test.context.junit4.SpringRunner;

import static org.junit.jupiter.api.Assertions.*;

@RunWith(SpringRunner.class)
@DataJpaTest
class BatchUpdateCardServiceTest {

    @Autowired
    private ISingleUpdateService<DbUserCard, UpdateUserCard> updater;

    @Autowired
    private DbUserCardRepository repository;

    @Test
    void updateWithOwnerCheck() {
    }

    @Test
    void updateWith() {
    }
}