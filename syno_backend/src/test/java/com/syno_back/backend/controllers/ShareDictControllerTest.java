package com.syno_back.backend.controllers;

import com.syno_back.backend.datasource.DbDictShareRepository;
import com.syno_back.backend.datasource.DbUserDictionaryRepository;
import com.syno_back.backend.datasource.UserRepository;
import com.syno_back.backend.model.*;
import org.junit.Before;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.result.MockMvcResultHandlers;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;
import org.springframework.web.context.WebApplicationContext;

import javax.transaction.Transactional;

import static org.junit.jupiter.api.Assertions.*;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.user;
import static org.springframework.security.test.web.servlet.setup.SecurityMockMvcConfigurers.springSecurity;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@RunWith(SpringRunner.class)
@AutoConfigureMockMvc()
@SpringBootTest
@ActiveProfiles("test")
class ShareDictControllerTest {
    private MockMvc mockMvc;

    @Autowired
    private WebApplicationContext context;

    @Autowired
    private DbUserDictionaryRepository dictionaryRepository;

    @Autowired
    private DbDictShareRepository shareRepository;

    @Autowired
    private UserRepository userRepository;

    private DbUser user;

    private DbUser cloningUser;

    private DbUserDictionary dictionary;

    private DbUserCard card;

    private DbTranslation trans;

    @BeforeEach
    void setUp() {
        mockMvc = MockMvcBuilders
                .webAppContextSetup(context)
                .apply(springSecurity())
                .build();
    }


    void commonPart() {
        user = userRepository.saveAndFlush(DbUser.builder().email("email").password("1").build());
        cloningUser = userRepository.saveAndFlush(DbUser.builder().email("fakeemail").password("1").build());
        dictionary = dictionaryRepository.saveAndFlush(DbUserDictionary.builder().name("name").owner(user).build());
        user.addUserDictionary(dictionary);

        card = DbUserCard.builder().translatedWord("word").build();
        dictionary.addUserCard(card);

        trans = DbTranslation.builder().id(5L).usageSample("sample").transcription("transcr").translation("tr")
                .comment("comment").build();
        card.addTranslation(trans);

        dictionary = dictionaryRepository.saveAndFlush(dictionary);
    }

    @Test
    @Transactional
    void addShare() throws Exception {
        commonPart();

        mockMvc.perform(post("/api/dict_share/add_share").with(user("email").roles("USER"))
                .contentType(MediaType.APPLICATION_JSON)
                .content(String.format("{\"share_dict_id\":%d}", dictionary.getId()))
                .characterEncoding("UTF-8"))
                .andDo(MockMvcResultHandlers.print())
                .andExpect(status().isOk());

        assertEquals(shareRepository.count(), 1);
        var share = shareRepository.findAll().get(0);
        assertEquals(share.getSharedDictionary(), dictionary);
        assertEquals(share.getOwner(), user);
        assertNotNull(share.getActivationTime());
    }

    @Test
    @Transactional
    void cloneSharedShare() throws Exception {
        commonPart();

        var dictShare = shareRepository.saveAndFlush(DbDictShare.builder().sharedDictionary(dictionary).owner(user).build());

        var shareUuid = dictShare.getShareUUID();

        mockMvc.perform(get("/api/dict_share/get_share/" + shareUuid).with(user(cloningUser.getEmail()).roles("USER")))
                .andExpect(status().isOk());

        var cloningUserDicts = dictionaryRepository.findByOwner_Email(cloningUser.getEmail());
        assertEquals(cloningUserDicts.size(), 1);
        var clonedDict = cloningUserDicts.get(0);
        assertEquals(clonedDict.getUserCards().size(), 1);

        var clonedCard = clonedDict.getUserCards().get(0);
        assertEquals(clonedCard.getTranslatedWord(), card.getTranslatedWord());
        assertEquals(clonedCard.getUserDictionary(), clonedDict);
        assertEquals(clonedCard.getTranslations().size(), 1);

        var clonedTrans = clonedCard.getTranslations().get(0);
        assertEquals(clonedTrans.getComment(), trans.getComment());
        assertEquals(clonedTrans.getTranscription(), trans.getTranscription());
        assertEquals(clonedTrans.getUsageSample(), trans.getUsageSample());
        assertEquals(clonedTrans.getTranslation(), trans.getTranslation());
        assertEquals(clonedTrans.getSourceCard(), clonedCard);
    }
}