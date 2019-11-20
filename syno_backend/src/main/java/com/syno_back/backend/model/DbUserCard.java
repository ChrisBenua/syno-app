package com.syno_back.backend.model;


import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import javax.persistence.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Builder
@Getter
@NoArgsConstructor
@AllArgsConstructor
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
    @Builder.Default
    private List<DbTranslation> translations = new ArrayList<>();

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "source_dictionary_id")
    private DbUserDictionary userDictionary;

    public DbUserCard(String translatedWord, String language) {
        this.translatedWord = translatedWord;
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
        translations.forEach(trans -> trans.setSourceCard(this));
    }

    public void setUserDictionary(DbUserDictionary userDictionary) {
        this.userDictionary = userDictionary;
    }

    @Override
    public boolean equals(Object other) {
        if (other == null) {
            return false;
        }

        if (other.getClass().equals(this.getClass())) {
            return ((DbUserCard)other).getId().equals(this.getId());
        }
        return false;
    }

    @Override
    public int hashCode() {
        return this.getId().hashCode();
    }
}
