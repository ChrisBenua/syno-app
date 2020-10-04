package com.syno_back.backend.model;

import lombok.*;
import org.hibernate.annotations.UpdateTimestamp;

import javax.persistence.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

/**
 * Class for mapping DB user_dictionaries to java object
 */
@Builder
@AllArgsConstructor
@NoArgsConstructor
@Getter
@Entity
@Table(name="user_dictionaries")
public class DbUserDictionary {
    /**
     * DB's id
     */
    @Builder.Default
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private Long id = 0L;

    /**
     * Dictionary name
     */
    @Column(name="name")
    private String name;

    /**
     * Unique <code>DbUserDictionary</code> id
     */
    @Column(name="pin")
    private String pin;

    /**
     * Dictionary language
     */
    @Setter
    @Column(name="language")
    private String language;

    /**
     * Time when <code>DbUserDictionary</code> was created
     */
    @Setter
    @Column(name="time_created")
    private LocalDateTime timeCreated;

    /**
     * Time when <code>DbUserDictionary</code> was modified
     */
    @Setter
    @UpdateTimestamp
    @Column(name="time_modified")
    private LocalDateTime timeModified;

    /**
     * <code>DbUserDictionary</code> owner
     */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name="owner_id")
    private DbUser owner;

    /**
     * List of <code>DbUserDictionary</code> cards
     */
    @OneToMany(mappedBy = "userDictionary",
               cascade = CascadeType.ALL,
               orphanRemoval = false)
    @Builder.Default
    private List<DbUserCard> userCards = new ArrayList<>();

    /**
     * Adds card to <code>DbUserDictionary</code>
     * @param card
     */
    public void addUserCard(DbUserCard card) {
        card.setUserDictionary(this);
        this.userCards.add(card);
    }

    /**
     * Sets id
     * @param id DB's id
     */
    public void setId(Long id) {
        this.id = id;
    }

    /**
     * Sets dictionary name
     * @param name new dictionary name
     */
    public void setName(String name) {
        this.name = name;
    }

    /**
     * Sets dictionary owner
     * @param owner new dictionary owner
     */
    public void setOwner(DbUser owner) {
        this.owner = owner;
    }

    /**
     * Sets dictionary user cards
     * @param userCards list of new dictionary cards
     */
    public void setUserCards(List<DbUserCard> userCards) {
        this.userCards = userCards;
        this.userCards.forEach(card -> card.setUserDictionary(this));
    }

    /**
     * Remove given card from dictionary
     * @param card card to remove
     */
    public void removeUserCard(DbUserCard card) {
        this.userCards.remove(card);
    }

    @Override
    public boolean equals(Object other) {
        if (other == null) {
            return false;
        }

        if (other.getClass().equals(this.getClass())) {
            return ((DbUserDictionary)other).getId().equals(this.getId());
        }
        return false;
    }

    /**
     * Sets random UUID if needed
     */
    @PrePersist
    private void setUUID() {
        if (pin == null)
            this.pin = UUID.randomUUID().toString();
        if (timeCreated == null) {
            this.timeCreated = LocalDateTime.now();
        }
    }

    @Override
    public int hashCode() {
        return this.getId().hashCode();
    }
}
