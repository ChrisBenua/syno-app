package com.syno_back.backend.controllers;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.syno_back.backend.datasource.DbUserCardRepository;
import com.syno_back.backend.datasource.DbUserDictionaryRepository;
import com.syno_back.backend.datasource.UserRepository;
import com.syno_back.backend.dto.*;
import com.syno_back.backend.model.DbTranslation;
import com.syno_back.backend.model.DbUser;
import com.syno_back.backend.model.DbUserCard;
import com.syno_back.backend.model.DbUserDictionary;
import lombok.val;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.runner.RunWith;
import org.mockito.Mockito;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.test.context.web.WebAppConfiguration;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders;
import org.springframework.test.web.servlet.result.MockMvcResultHandlers;
import org.springframework.test.web.servlet.result.MockMvcResultMatchers;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;
import org.springframework.web.context.WebApplicationContext;

import javax.transaction.Transactional;

import static org.hamcrest.Matchers.is;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.user;
import static org.springframework.security.test.web.servlet.setup.SecurityMockMvcConfigurers.springSecurity;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@RunWith(SpringRunner.class)
@WebAppConfiguration()
@ContextConfiguration
@SpringBootTest
@ActiveProfiles("test")
class UserCardControllerTest {

    @Autowired
    private WebApplicationContext context;

    private MockMvc mockMvc;

    @MockBean
    private UserRepository userRepository;

    @MockBean
    private DbUserDictionaryRepository userDictionaryRepository;

    @BeforeEach
    public void setup() {
        mockMvc = MockMvcBuilders
                .webAppContextSetup(context)
                .apply(springSecurity())
                .build();
    }


    @Test
    void getCardsFromDictionary() throws Exception {
        var dbUser = DbUser.builder()
                .id(1L).email("email").password("123").build();
        Mockito.when(userRepository.findByEmail("email")).thenReturn(Optional.of(dbUser));

        List<DbUserCard> cards = new ArrayList<>();
        cards.add(DbUserCard.builder().language("ru-en").id(2L).translatedWord("word").build());
        DbUserDictionary dictionary = DbUserDictionary.builder().id(1L).name("name").owner(dbUser).userCards(cards).build();

        Mockito.when(userDictionaryRepository.findById(1L)).thenReturn(Optional.of(dictionary));

        mockMvc.perform(get("/api/user_cards/1/get_cards").with(user("email").roles("USER")))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].language", is("ru-en")))
                .andExpect(jsonPath("$[0].translated_word", is("word")))
                .andExpect(jsonPath("$[0].id", is(2)));
    }
}


@RunWith(SpringRunner.class)
@AutoConfigureMockMvc()
@SpringBootTest
@ActiveProfiles("test")
class UserCardControllerTest1 {

    @Autowired
    private WebApplicationContext context;

    private MockMvc mockMvc;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private DbUserCardRepository cardRepository;

    @BeforeEach
    public void setup() {
        mockMvc = MockMvcBuilders
                .webAppContextSetup(context)
                .apply(springSecurity())
                .build();
    }

    @Autowired
    private DbUserDictionaryRepository userDictionaryRepository;


    @Test
    public void contextLoads() throws Exception {
        assertNotNull(mockMvc);
    }

    @Test
    @Transactional
    void addCard() throws Exception {
        val email = "email";
        userRepository.save(DbUser.builder().email(email).password("123").build());
        userRepository.flush();

        var dbUserDict = DbUserDictionary.builder().name("name").owner(userRepository.findAll().get(0)).build();

        userDictionaryRepository.save(dbUserDict);
        userDictionaryRepository.flush();

        List<NewUserTranslation> translations = new ArrayList<>();
        translations.add(NewUserTranslation.builder().usageSample("sample").comment("comment").transcription("transcr").translation("trans").build());
        var newUserCard = NewUserCard.builder().language("ru-en").translatedWord("word").translations(translations).build();


        mockMvc.perform(MockMvcRequestBuilders.post(String.format("/api/user_cards/%d/add_card", dbUserDict.getId())).with(user("email").roles("USER"))
                .contentType(MediaType.APPLICATION_JSON)
                .characterEncoding("UTF-8")
                .content(new ObjectMapper().writeValueAsString(newUserCard)))
                .andDo(MockMvcResultHandlers.print())
                .andExpect(MockMvcResultMatchers.status().isAccepted());

        cardRepository.flush();
        dbUserDict = userDictionaryRepository.findById(dbUserDict.getId()).get();
        assertEquals(dbUserDict.getUserCards().size(), 1);
        assertEquals(dbUserDict.getUserCards().get(0).getLanguage(), "ru-en");
        assertEquals(dbUserDict.getUserCards().get(0).getTranslatedWord(), "word");
        assertEquals(dbUserDict.getUserCards().get(0).getTranslations().size(), 1);
        assertEquals(dbUserDict.getUserCards().get(0).getTranslations().get(0).getUsageSample(), "sample");
        assertEquals(dbUserDict.getUserCards().get(0).getTranslations().get(0).getTranslation(), "trans");
        assertEquals(dbUserDict.getUserCards().get(0).getTranslations().get(0).getTranscription(), "transcr");
        assertEquals(dbUserDict.getUserCards().get(0).getTranslations().get(0).getComment(), "comment");
    }

    @Test
    @Transactional
    void updateCardsFromDictionarySelective() throws Exception {
        val email = "email";
        userRepository.save(DbUser.builder().email(email).password("123").build());
        userRepository.flush();

        var dbUserDict = DbUserDictionary.builder().name("name").owner(userRepository.findAll().get(0)).build();

        userDictionaryRepository.save(dbUserDict);
        userDictionaryRepository.flush();
        List<DbUserCard> cards = new ArrayList<>();
        for (int i = 0; i < 10; ++i) {
            var dbUserCard = DbUserCard.builder().translatedWord("word_"+i).language("en-ru").userDictionary(dbUserDict).build();
            for (int j = 0; j < 5; ++j) {
                int num = i * 10 + j;
                var trans = DbTranslation.builder().usageSample("sample_" + num).comment("comment_" + num)
                        .transcription("transcr_" + num).translation("trans_" + num).sourceCard(dbUserCard).build();
                dbUserCard.addTranslation(trans);
            }
            dbUserDict.addUserCard(dbUserCard);
            cards.add(dbUserCard);
        }

        userDictionaryRepository.save(dbUserDict); userDictionaryRepository.flush();

        List<UpdateUserCard> updateUserCards = new ArrayList<>();
        for (int i = 0; i < 5; ++i) {
            List<UpdateUserTranslation> translations = new ArrayList<>();
            for (int j = 0; j < 2; ++j) {
                int num = i * 10 + j;
                translations.add(new UpdateUserTranslation("new_trans_" + num, "new_comment_" + num,
                        "new_transcr_" + num, "new_sample_" + num, cards.get(i).getTranslations().get(j).getId()));
            }
            UpdateUserCard card = new UpdateUserCard(cards.get(i).getId(), "new_word_" + i, "ru-en", translations);
            updateUserCards.add(card);
        }

        mockMvc.perform(MockMvcRequestBuilders.post(String.format("/api/user_cards/%d/update_cards_selective", dbUserDict.getId())).with(user("email").roles("USER"))
                .contentType(MediaType.APPLICATION_JSON)
                .characterEncoding("UTF-8")
                .content(new ObjectMapper().writeValueAsString(updateUserCards)))
                .andDo(MockMvcResultHandlers.print())
                .andExpect(MockMvcResultMatchers.status().isOk());

        userDictionaryRepository.flush();
        cardRepository.flush();


    }
}