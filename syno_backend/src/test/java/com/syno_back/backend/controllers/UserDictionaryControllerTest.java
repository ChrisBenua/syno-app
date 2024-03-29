package com.syno_back.backend.controllers;

import com.syno_back.backend.datasource.DbUserDictionaryRepository;
import com.syno_back.backend.datasource.UserRepository;
import com.syno_back.backend.model.DbUser;
import com.syno_back.backend.model.DbUserCard;
import com.syno_back.backend.model.DbUserDictionary;
import lombok.val;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.runner.RunWith;
import org.mockito.Mockito;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
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

import java.util.ArrayList;
import java.util.Optional;

import static org.hamcrest.Matchers.is;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.user;
import static org.springframework.security.test.web.servlet.setup.SecurityMockMvcConfigurers.springSecurity;

@RunWith(SpringRunner.class)
@WebAppConfiguration()
@ContextConfiguration
@SpringBootTest
@ActiveProfiles("test")
class UserDictionaryControllerTest {

    @Autowired
    private WebApplicationContext context;

    private MockMvc mockMvc;

    @MockBean
    private UserRepository userRepository;

    @BeforeEach
    public void setup() {
        mockMvc = MockMvcBuilders
                .webAppContextSetup(context)
                .apply(springSecurity())
                .build();
    }

    @MockBean
    private DbUserDictionaryRepository userDictionaryRepository;


    @Test
    public void contextLoads() throws Exception {
        assertNotNull(mockMvc);
    }

    @Test
    void getUserDictionaries() throws Exception {
        val email = "email";
        Mockito.when(userRepository.findByEmail(email)).thenReturn(Optional.of(DbUser.builder()
                .id(1L).email(email).password("123").build()));
        ArrayList<DbUserDictionary> mockReturnValue = new ArrayList<>();
        ArrayList<DbUserCard> mockCards = new ArrayList<DbUserCard>();
        mockCards.add(DbUserCard.builder().pin("card").id(2L).translatedWord("word").translations(new ArrayList<>()).build());
        mockReturnValue.add(DbUserDictionary.builder().pin("dict").name("name").id(1L).userCards(mockCards).build());
        Mockito.when(userDictionaryRepository.findByOwner_Email(email)).thenReturn(mockReturnValue);

        mockMvc.perform(MockMvcRequestBuilders.get("/api/dicts/my_all").with(user("email").roles("USER"))).andDo(MockMvcResultHandlers.print())
                .andExpect(MockMvcResultMatchers.status().isOk())
                .andExpect(MockMvcResultMatchers.jsonPath("$[0].name", is("name")))
                .andExpect(MockMvcResultMatchers.jsonPath("$[0].id", is(1)))
                .andExpect(MockMvcResultMatchers.jsonPath("$[0].pin", is("dict")))
                .andExpect(MockMvcResultMatchers.jsonPath("$[0].user_cards[0].translated_word", is("word")))
                .andExpect(MockMvcResultMatchers.jsonPath("$[0].user_cards[0].id", is(2)))
                .andExpect(MockMvcResultMatchers.jsonPath("$[0].user_cards[0].pin", is("card")))
        ;

    }
}
