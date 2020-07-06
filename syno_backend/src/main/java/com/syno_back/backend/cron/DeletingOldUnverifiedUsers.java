package com.syno_back.backend.cron;

import com.syno_back.backend.datasource.UserRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;
import java.util.stream.Collectors;

@Component
public class DeletingOldUnverifiedUsers {
    private final Logger logger = LoggerFactory.getLogger(DeletingOldUnverifiedUsers.class);

    private UserRepository userRepository;

    public static final int DAYS_TO_DELETE = 30;


    public DeletingOldUnverifiedUsers(
            @Autowired UserRepository userRepository
    ) {
        this.userRepository = userRepository;
    }

    @Scheduled(cron = "0 0 12 * * *")
    public void perform() {
        logger.info("Launching {} cron task", DeletingOldUnverifiedUsers.class.getName());

        var users = this.userRepository.findByIsVerifiedFalse().stream().filter(el -> {
            return el.getTimeCreated().plusDays(DAYS_TO_DELETE).isBefore(LocalDateTime.now());
        }).collect(Collectors.toList());
        StringBuilder builder = new StringBuilder("Deleting users: ");
        for (var el : users) {
            builder.append("\"").append(el.getEmail()).append("\"").append("; ");
        }
        logger.info(builder.toString());
        this.userRepository.deleteAll(users);
    }
}
