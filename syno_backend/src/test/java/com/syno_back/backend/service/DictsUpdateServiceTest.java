package com.syno_back.backend.service;

import com.syno_back.backend.datasource.*;
import com.syno_back.backend.dto.UpdateRequestDto;
import com.syno_back.backend.dto.UpdateUserCardDto;
import com.syno_back.backend.dto.UpdateUserDictionaryDto;
import com.syno_back.backend.dto.UpdateUserTranslationDto;
import com.syno_back.backend.model.DbTranslation;
import com.syno_back.backend.model.DbUser;
import com.syno_back.backend.model.DbUserCard;
import com.syno_back.backend.model.DbUserDictionary;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;
import org.springframework.web.context.WebApplicationContext;

import javax.transaction.Transactional;
import java.util.List;
import java.util.stream.Collectors;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertIterableEquals;
import static org.springframework.security.test.web.servlet.setup.SecurityMockMvcConfigurers.springSecurity;

@RunWith(SpringRunner.class)
@SpringBootTest
//@AutoConfigureMockMvc()
@ActiveProfiles("test")
public class DictsUpdateServiceTest {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private RolesRepository rolesRepository;

    @Autowired
    private DbUserDictionaryRepository dictionaryRepository;

    @Autowired
    private DbUserCardRepository userCardRepository;

    @Autowired
    private DbTranslationRepository translationRepository;

    @Autowired
    private DictsUpdateServiceImpl dictsUpdateService;

    @Autowired
    private WebApplicationContext context;

    @Before
    public void setUp() {
        tearDown();
        var mockMVC = MockMvcBuilders
                .webAppContextSetup(context)
                .apply(springSecurity())
                .build();
    }

    @After
    public void tearDown() {
        translationRepository.deleteAll();
        userCardRepository.deleteAll();
        dictionaryRepository.deleteAll();
        userRepository.deleteAll();
    }

    private void prepare() {
        var user = userRepository.save(
                DbUser.builder().email("email").password("1").build()
        );
        var translation1 = DbTranslation.builder().pin("tr1").translation("trans1").build();
        var translation2 = DbTranslation.builder().pin("tr2").translation("trans2").build();

        var translation3 = DbTranslation.builder().pin("tr3").translation("trans3").build();

        var card1 = DbUserCard.builder().translatedWord("word").pin("card1pin").build();
        card1.addTranslation(translation1);
        card1.addTranslation(translation2);

        var card2 = DbUserCard.builder().translatedWord("word2").pin("card2pin").build();
        card2.addTranslation(translation3);

        var dict1 = DbUserDictionary.builder().language("ru-en").name("name1").pin("dict1pin").owner(user).build();
        dict1.addUserCard(card1);
        dict1.addUserCard(card2);

        var card3 = DbUserCard.builder().translatedWord("word3").pin("card3pin").build();
        var dict2 = DbUserDictionary.builder().language("ru-en").name("name2").pin("dict2pin").build();;
        dict2.addUserCard(card3);

        user.addUserDictionary(dict1);
        user.addUserDictionary(dict2);

        userRepository.save(user);
        assertEquals(translationRepository.findAll().size(), 3);
    }

    @Test
    @Transactional
    public void test() {
        prepare();

        var updateRequest = UpdateRequestDto.builder().existingDictPins(List.of("dict1pin", "dict3pin"))
                .clientDicts(List.of(
                        UpdateUserDictionaryDto.builder()
                                .pin("dict1pin")
                                .language("Ru-en")
                                .name("Name1")
                                .userCards(List.of(
                                        UpdateUserCardDto.builder()
                                                .pin("card1pin")
                                                .translatedWord("Word")
                                                .translations(List.of(UpdateUserTranslationDto.builder()
                                                        .pin("tr1")
                                                        .comment("comment")
                                                        .transcription("transcription")
                                                        .translation("Trans1")
                                                        .build(),
                                                        UpdateUserTranslationDto.builder()
                                                                .pin("tr4")
                                                                .comment("comment")
                                                                .translation("Trans4")
                                                                .transcription("transcription")
                                                                .usageSample("usageSample")
                                                                .build()
                                                        ))
                                                .build(),
                                        UpdateUserCardDto.builder()
                                                .pin("card4pin")
                                                .translatedWord("Word4")
                                                .translations(List.of(
                                                        UpdateUserTranslationDto.builder()
                                                                .pin("tr5")
                                                                .comment("comment")
                                                                .translation("Trans5")
                                                                .transcription("transcription")
                                                                .usageSample("usageSample")
                                                                .build()
                                                ))
                                                .build()
                                        ))
                                .build(),
                        UpdateUserDictionaryDto.builder()
                                .name("Name3")
                                .pin("dict3pin")
                                .language("Ru-en")
                                .userCards(List.of(
                                        UpdateUserCardDto.builder()
                                                .pin("card5pin")
                                                .translatedWord("Word5")
                                                .translations(List.of(
                                                        UpdateUserTranslationDto.builder()
                                                                .pin("tr6")
                                                                .comment("comment")
                                                                .transcription("transcription")
                                                                .usageSample("usageSample")
                                                                .translation("Trans6")
                                                                .build()
                                                ))
                                                .build()))
                                .build())).build();

        var user = userRepository.findAll().get(0);
        dictsUpdateService.performUpdates(user, updateRequest);

        assertEquals(dictionaryRepository.findByOwner_Email(user.getEmail()).size(), 2);
        var dict = dictionaryRepository.findByPin("dict1pin").get();

        assertEquals(dict.getUserCards().size(), 2);
        assertEquals(dict.getName(), "Name1");
        assertEquals(dict.getLanguage(), "Ru-en");

        assertIterableEquals(dict.getUserCards().stream().map(DbUserCard::getPin).collect(Collectors.toList()), List.of("card1pin", "card4pin"));
        var oldCard = dict.getUserCards().stream().filter(el -> el.getPin().equals("card1pin")).findAny().get();

        assertEquals(oldCard.getTranslatedWord(), "Word");
        assertIterableEquals(oldCard.getTranslations().stream().map(DbTranslation::getPin).collect(Collectors.toList()), List.of("tr1", "tr4"));
        var newCard = dict.getUserCards().stream().filter(el -> el.getPin().equals("card4pin")).findAny().get();
        assertEquals(newCard.getTranslatedWord(), "Word4");
        var trans = newCard.getTranslations().get(0);
        assertEquals(newCard.getTranslations().size(), 1);
        assertEquals(trans.getPin(), "tr5");
    }
}
