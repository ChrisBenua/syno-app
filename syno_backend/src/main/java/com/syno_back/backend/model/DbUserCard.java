package com.syno_back.backend.model;


import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import javax.persistence.*;
import java.time.LocalDateTime;
import java.util.List;

@Entity
@Table(name="user_cards")
public class DbUserCard {
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private Long id;

    @Column(name="translated_word")
    private String translatedWord;

    @Column(name="language")
    private String language;

    @CreationTimestamp
    @Column(name="time_created")
    private LocalDateTime timeCreated;

    @UpdateTimestamp
    @Column(name="time_modified")
    private LocalDateTime timeModified;

    @OneToMany(mappedBy = "sourceCard",
               cascade = CascadeType.ALL,
               orphanRemoval = true)
    private List<DbTranslation> translations;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "source_dictionary_id")
    private DbUserDictionary userDictionary;

    public DbUserCard() {}

    public DbUserCard(String name, String language) {
        this.translatedWord = name;
        this.language = language;
    }

    public void addTranslation(DbTranslation translation) {
        translations.add(translation);
        translation.setSourceCard(this);
    }

    public void removeTranslation(DbTranslation translation) {
        translations.remove(translation);
        translation.setSourceCard(null);
    }

    public Long getId() {
        return id;
    }

    public String getTranslatedWord() {
        return translatedWord;
    }

    public String getLanguage() {
        return language;
    }

    public List<DbTranslation> getTranslations() {
        return translations;
    }

    public LocalDateTime getTimeCreated() {
        return timeCreated;
    }

    public LocalDateTime getTimeModified() {
        return timeModified;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public void setTranslatedWord(String translatedWord) {
        this.translatedWord = translatedWord;
    }

    public void setLanguage(String language) {
        this.language = language;
    }

    public void setTranslations(List<DbTranslation> translations) {
        this.translations = translations;
    }

    public void setUserDictionary(DbUserDictionary userDictionary) {
        this.userDictionary = userDictionary;
    }
}
