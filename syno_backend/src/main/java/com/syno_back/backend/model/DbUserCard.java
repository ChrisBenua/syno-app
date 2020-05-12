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
import java.util.UUID;

/**
 * Class for mapping DB user_cards to java object
 */
@Builder
@Getter
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name="user_cards")
public class DbUserCard {
    /**
     * DB's id
     */
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private Long id;

    /**
     * Actual translated word
     */
    @Column(name="translated_word")
    private String translatedWord;

    /**
     * Unique card's id
     */
    @Column(name="pin")
    private String pin;

    /**
     * Time when <code>DbUserCard</code> was created
     */
    @CreationTimestamp
    @Column(name="time_created")
    private LocalDateTime timeCreated;

    /**
     * Time when <code>DbUserCard</code> was modified
     */
    @UpdateTimestamp
    @Column(name="time_modified")
    private LocalDateTime timeModified;

    /**
     * Card's translation
     */
    @OneToMany(mappedBy = "sourceCard",
               cascade = CascadeType.ALL,
               orphanRemoval = true)
    @Builder.Default
    private List<DbTranslation> translations = new ArrayList<>();

    /**
     * Dictionary that owns this card
     */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "source_dictionary_id")
    private DbUserDictionary userDictionary;

    /**
     * Creates new <code>DbUserCard</code>
     * @param translatedWord actual translated word
     */
    public DbUserCard(String translatedWord) {
        this.translatedWord = translatedWord;
    }

    /**
     * Adds new translation to card
     * @param translation translation to add
     */
    public void addTranslation(DbTranslation translation) {
        translations.add(translation);
        translation.setSourceCard(this);
    }

    /**
     * Removes translation from card
     * @param translation translation to remove
     */
    public void removeTranslation(DbTranslation translation) {
        translations.remove(translation);
        translation.setSourceCard(null);
    }

    /**
     * Sets id
     * @param id DB's id
     */
    public void setId(Long id) {
        this.id = id;
    }

    /**
     * Sets translatedWord
     * @param translatedWord actual translated word
     */
    public void setTranslatedWord(String translatedWord) {
        this.translatedWord = translatedWord;
    }

    /**
     * Sets list of translation for this card
     * @param translations list of translations to add
     */
    public void setTranslations(List<DbTranslation> translations) {
        this.translations = translations;
        translations.forEach(trans -> trans.setSourceCard(this));
    }

    /**
     * Sets <code>DbUserDictionary</code> that will own this card
     * @param userDictionary parent dictionary
     */
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

    /**
     * Sets random uuid if needed
     */
    @PrePersist
    private void setUUID() {
        if (pin == null)
            this.pin = UUID.randomUUID().toString();
    }

    @Override
    public int hashCode() {
        return this.getId().hashCode();
    }
}
