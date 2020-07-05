package com.syno_back.backend.cron;

import com.syno_back.backend.datasource.UserRepository;
import com.syno_back.backend.model.DbUser;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;

import java.time.LocalDateTime;

import static com.syno_back.backend.cron.DeletingOldUnverifiedUsers.DAYS_TO_DELETE;
import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest
@ActiveProfiles("test")
class DeletingOldUnverifiedUsersTest {
    @Autowired
    UserRepository userRepository;

    @Test
    void perform() {
        var user1 = DbUser.builder().email("email").isVerified(false).build();
        user1 = userRepository.save(user1);
        user1.setTimeCreated(LocalDateTime.now().minusDays(DAYS_TO_DELETE + 10));
        userRepository.save(user1);

        var user2 = DbUser.builder().email("email2").isVerified(false).build();
        user2 = userRepository.save(user2);
        user2.setTimeCreated(LocalDateTime.now().minusDays(DAYS_TO_DELETE - 10));
        userRepository.save(user2);

        var user3 = DbUser.builder().email("email3").isVerified(true).build();
        user3 = userRepository.save(user3);
        user3.setTimeCreated(LocalDateTime.now().minusDays(DAYS_TO_DELETE + 10));
        userRepository.save(user3);

        userRepository.flush();

        new DeletingOldUnverifiedUsers(userRepository).perform();

        userRepository.flush();

        var lst = userRepository.findAll();
        assertFalse(lst.stream().anyMatch(el -> el.getEmail().equals("email")));
        assertTrue(lst.stream().anyMatch(el -> el.getEmail().equals("email2")));
        assertTrue(lst.stream().anyMatch(el -> el.getEmail().equals("email3")));
    }
}