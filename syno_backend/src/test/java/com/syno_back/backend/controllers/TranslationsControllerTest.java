package com.syno_back.backend.controllers;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.syno_back.backend.datasource.DbTranslationRepository;
import com.syno_back.backend.datasource.DbUserCardRepository;
import com.syno_back.backend.datasource.DbUserDictionaryRepository;
import com.syno_back.backend.datasource.UserRepository;
import com.syno_back.backend.dto.NewUserTranslation;
import com.syno_back.backend.dto.Translation;
import com.syno_back.backend.jwt.auth.JwtAuthEntryPoint;
import com.syno_back.backend.jwt.auth.JwtProvider;
import com.syno_back.backend.model.*;
import com.syno_back.backend.service.*;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.runner.RunWith;
import org.mockito.Mockito;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.context.TestConfiguration;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.context.annotation.Bean;
import org.springframework.http.MediaType;
import org.springframework.security.core.Authentication;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;
import org.springframework.web.context.WebApplicationContext;

import javax.transaction.Transactional;

import static org.hamcrest.Matchers.is;

import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;


import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.user;
import static org.springframework.security.test.web.servlet.setup.SecurityMockMvcConfigurers.springSecurity;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@RunWith(SpringRunner.class)
@WebMvcTest(TranslationsController.class)
class TranslationsControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private DbTranslationRepository translationRepository;

    @MockBean
    private DbUserCardRepository cardRepository;

    @MockBean
    private UserRepository repository;

    @TestConfiguration
    public static class Configuration {
        @Bean
        IDtoMapper<DbTranslation, Translation> getMapper() {
            return new TranslationToDtoMapper();
        }

        @Bean
        ICredentialProvider<DbUserDictionary, Authentication> dictCredentialProvider() {
            return new UserDictionaryCredentialProvider();
        }

        @Bean
        ITranslationsAdderService adderService() {
            return new TranslationsAdderService();
        }

        @Bean
        UserDetailServiceImpl userDetailsService() {
            return new UserDetailServiceImpl();
        }

        @Bean
        JwtAuthEntryPoint authHandler() {
            return new JwtAuthEntryPoint();
        }

        @Bean
        JwtProvider tokenProvider() {
            return new JwtProvider();
        }
    }

    void defaultUserRepoMock() {
        Mockito.when(repository.findByEmail("email")).thenReturn(
                Optional.of(DbUser.builder().email("email").password("1").id(1L).roles(List.of(DbRole.builder().name("ROLE_USER").id(2L).build())).build())
        );
    }

    @Test
    void getTranslation() throws Exception {
        defaultUserRepoMock();

        Mockito.when(translationRepository.findById(3L)).thenReturn(Optional.of(DbTranslation.builder().id(4L).comment("c").translation("tr").build()));

        mockMvc.perform(get("/api/translations/get_translation?trans_id=3").with(user("email").roles("USER")))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id", is(4)))
                .andExpect(jsonPath("$.comment", is("c")))
                .andExpect(jsonPath("$.translation", is("tr")));
    }

    @Test
    void getTranslationNotFound() throws Exception {
        defaultUserRepoMock();

        Mockito.when(translationRepository.findById(3L)).thenReturn(Optional.empty());

        mockMvc.perform(get("/api/translations/get_translation?trans_id=3").with(user("email").roles("USER")))
                .andExpect(status().isNotFound());
    }

    @Test
    void getTranslations() throws Exception {
        defaultUserRepoMock();

        Mockito.when(translationRepository.findAllById(List.of(3L, 4L, 5L))).thenReturn(List.of(
                DbTranslation.builder().id(3L).comment("cc").translation("trr").build(),
                DbTranslation.builder().id(4L).comment("c").translation("tr").build(),
                DbTranslation.builder().id(5L).comment("ccc").translation("trrr").build())
        );

        mockMvc.perform(get("/api/translations/get_translations?trans_ids=3&trans_ids=4&trans_ids=5").with(user("email").roles("USER")))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].id", is(3)))
                .andExpect(jsonPath("$[0].comment", is("cc")))
                .andExpect(jsonPath("$[0].translation", is("trr")))
                .andExpect(jsonPath("$[1].id", is(4)))
                .andExpect(jsonPath("$[1].comment", is("c")))
                .andExpect(jsonPath("$[1].translation", is("tr")))
                .andExpect(jsonPath("$[2].id", is(5)))
                .andExpect(jsonPath("$[2].comment", is("ccc")))
                .andExpect(jsonPath("$[2].translation", is("trrr")))
        ;
    }
}


@RunWith(SpringRunner.class)
@AutoConfigureMockMvc()
@SpringBootTest
@ActiveProfiles("test")
class TranslationsControllerTest1 {
    private MockMvc mockMvc;

    @Autowired
    private WebApplicationContext context;

    @Autowired
    private DbTranslationRepository translationRepository;

    @Autowired
    private DbUserCardRepository cardRepository;

    @Autowired
    private DbUserDictionaryRepository dictionaryRepository;

    @Autowired
    private UserRepository repository;

    private List<NewUserTranslation> translation;

    @BeforeEach
    public void setup() {
        mockMvc = MockMvcBuilders
                .webAppContextSetup(context)
                .apply(springSecurity())
                .build();

        translation = List.of(
                NewUserTranslation.builder().usageSample("sample").comment("comment").transcription("transcr").translation("trans").build(),
                NewUserTranslation.builder().usageSample("sample1").comment("comment1").transcription("transcr1").translation("trans1").build()
        );
    }

    @Test
    void testAddTranslationCardNotFound() throws Exception {
        repository.save(DbUser.builder().email("email").password("pass").build());


        mockMvc.perform(post("/api/translations/1/add_translations")
                .with(user("email").roles("USER"))
                .contentType(MediaType.APPLICATION_JSON)
                .characterEncoding("UTF-8")
                .content(new ObjectMapper().writeValueAsString(translation)))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.message", org.hamcrest.Matchers.is("The card 1 doesnt exist")));
    }

    @Test
    void testAddTranslationCardToDiffUserDict() throws Exception {
        var owner = repository.save(DbUser.builder().email("email").password("pass").build());
        var fakeOwner = repository.save(DbUser.builder().email("email1").password("pass1").build());

        repository.flush();

        var dict = dictionaryRepository.save(DbUserDictionary.builder().name("name").owner(owner).build());
        var fakeDict = dictionaryRepository.save(DbUserDictionary.builder().name("name1").owner(fakeOwner).build());
        var card = cardRepository.save(DbUserCard.builder().translatedWord("tr").build());
        fakeDict.addUserCard(card);

        cardRepository.save(card);
        cardRepository.flush();
        dictionaryRepository.flush();


        mockMvc.perform(post(String.format("/api/translations/%d/add_translations", card.getId()))
                .with(user("email").roles("USER"))
                .contentType(MediaType.APPLICATION_JSON)
                .characterEncoding("UTF-8")
                .content(new ObjectMapper().writeValueAsString(translation)))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.message", org.hamcrest.Matchers.is(String.format("The card %d doesnt belong to user %s", card.getId(), "email"))));
    }

    @Test
    @Transactional
    void addTranslationSuccessful() throws Exception {
        var owner = repository.save(DbUser.builder().email("email").password("pass").build());

        repository.flush();

        var dict = dictionaryRepository.save(DbUserDictionary.builder().name("name").owner(owner).build());
        var card = cardRepository.save(DbUserCard.builder().translatedWord("tr").build());
        dict.addUserCard(card);

        cardRepository.save(card);
        cardRepository.flush();

        dictionaryRepository.flush();

        mockMvc.perform(post(String.format("/api/translations/%d/add_translations", card.getId()))
                .with(user("email").roles("USER"))
                .contentType(MediaType.APPLICATION_JSON)
                .characterEncoding("UTF-8")
                .content(new ObjectMapper().writeValueAsString(translation)))
                .andExpect(status().isAccepted())
                .andExpect(jsonPath("$.message", is("2 translations created successfully")));

        cardRepository.flush();

        var createdTranslations = cardRepository.findById(card.getId()).get().getTranslations();
        assertEquals(createdTranslations.size(), 2);
        assertEquals(createdTranslations.get(0).getSourceCard(), card);
        assertEquals(createdTranslations.get(1).getSourceCard(), card);
        assertEquals(createdTranslations.get(0).getTranslation(), "trans");
        assertEquals(createdTranslations.get(1).getTranslation(), "trans1");

        assertEquals(createdTranslations.get(0).getUsageSample(), "sample");
        assertEquals(createdTranslations.get(1).getUsageSample(), "sample1");

        assertEquals(createdTranslations.get(0).getComment(), "comment");
        assertEquals(createdTranslations.get(1).getComment(), "comment1");

        assertEquals(createdTranslations.get(0).getTranscription(), "transcr");
        assertEquals(createdTranslations.get(1).getTranscription(), "transcr1");
    }
}


