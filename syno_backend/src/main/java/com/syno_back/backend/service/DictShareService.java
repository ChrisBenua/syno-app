package com.syno_back.backend.service;

import com.syno_back.backend.datasource.DbDictShareRepository;
import com.syno_back.backend.model.DbDictShare;
import com.syno_back.backend.model.DbUserDictionary;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;


/**
 * Service for creating or getting share's UUID
 */
@Component
public class DictShareService implements IDictShareService {

    /**
     * Repository for CRUD operations with <code>DbDictShare</code>
     */
    private DbDictShareRepository shareRepository;

    /**
     * Service for creating <code>DbDictShare</code> from <code>DbUserDictionary</code>
     */
    private IDbDictShareFactory shareFactory;

    public DictShareService(@Autowired DbDictShareRepository shareRepository, @Autowired IDbDictShareFactory shareFactory) {
        this.shareRepository = shareRepository;
        this.shareFactory = shareFactory;
    }

    @Override
    public String getDictShareCode(DbUserDictionary dictionary) {
        var shareCandidate = shareRepository.findBySharedDictionary_Id(dictionary.getId());
        if (shareCandidate.isPresent()) {
            var share = shareCandidate.get();
            share.activate();

            share = shareRepository.save(share);

            return share.getShareUUID().toString();
        } else {
            var dictShare = shareFactory.createDictShare(dictionary);

            return shareRepository.save(dictShare).getShareUUID().toString();
        }
    }
}
