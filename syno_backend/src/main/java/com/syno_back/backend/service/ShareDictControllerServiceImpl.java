package com.syno_back.backend.service;

import com.syno_back.backend.datasource.DbDictShareRepository;
import com.syno_back.backend.datasource.DbUserDictionaryRepository;
import com.syno_back.backend.datasource.UserRepository;
import com.syno_back.backend.dto.NewDictShare;
import com.syno_back.backend.dto.UserDictionary;
import com.syno_back.backend.model.DbDictShare;
import com.syno_back.backend.model.DbUserDictionary;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.Optional;
import java.util.UUID;

@Component
public class ShareDictControllerServiceImpl implements IShareDictControllerService {
    private final static Logger logger = LoggerFactory.getLogger(ShareDictControllerServiceImpl.class);

    @Autowired
    private DbUserDictionaryRepository dictionaryRepository;

    @Autowired
    private IDictShareService dictShareService;

    @Autowired
    private DbDictShareRepository shareRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private IEntityCloner<DbUserDictionary> dictCloner;

    @Autowired
    private IDtoMapper<DbUserDictionary, UserDictionary> mapper;

    @Override
    public UserDictionary cloneAndGetShare(String email, String shareUuid) {
        Optional<DbDictShare> candidate = Optional.empty();

        try {
            candidate = shareRepository.findByShareUUID(UUID.fromString(shareUuid));
        } catch (IllegalArgumentException ex) {
            logger.info("Pin {} doesnt look like UUID", shareUuid);
            throw new RuntimeException("Wrong format for share's id");
        }

        if (candidate.isPresent()) {
            var share = candidate.get();

            if (!share.getOwner().getEmail().equals(email)) {
                var dict = candidate.get().getSharedDictionary();

                if (dictionaryRepository.findByOwner_EmailAndPin(email, dict.getPin()).isPresent()) {
                    throw new RuntimeException("You have already cloned this dictionary");
                }

                var clonedDict = dictCloner.clone(dict);
                var user = userRepository.findByEmail(email).orElseThrow();
                clonedDict.setOwner(user);
                clonedDict = dictionaryRepository.save(clonedDict);

                logger.info("Cloned dict: {} for user: {} successfully", shareUuid, email);

                return mapper.convert(clonedDict,null);
            } else {
                logger.info("User {} tries to clone its own dict", email);
                throw new RuntimeException(String.format("User with email %s tries to clone its own dict", email));
            }
        } else {
            logger.info("Share with uuid: {} not found", shareUuid);
            throw new RuntimeException(String.format("No share with uuid: %s", shareUuid));
        }
    }

    @Override
    public String addShare(String email, NewDictShare share) {
        Optional<DbUserDictionary> dictCandidate = this.dictionaryRepository.findByPin(share.getShareDictPin());
        if (dictCandidate.isPresent()) {
            var dict = dictCandidate.get();
            if (dict.getOwner().getEmail().equals(email)) {
                String uuidString = dictShareService.getDictShareCode(dict);

                logger.info("Shared successfully!");
                return uuidString;
            } else {
                logger.info("Shared failed, user {} doesnt own dict with pin {}", email, share.getShareDictPin());
                throw new RuntimeException(String.format("Dict with pin = %s doesnt belong to user with email = %s",
                        share.getShareDictPin(), email));
            }
        } else {
            logger.info("Dictionary with pin: {} doesnt exist", share.getShareDictPin());
            throw new RuntimeException(String.format("Dict with id = %s doesnt exist", share.getShareDictPin()));
        }
    }
}
