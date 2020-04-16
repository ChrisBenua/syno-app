package com.syno_back.backend.model;

import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import javax.persistence.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Builder
@AllArgsConstructor
@NoArgsConstructor
@Getter
@Entity
@Table(name="user_dictionaries")
public class DbUserDictionary {
    @Builder.Default
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private Long id = 0L;

    @Column(name="name")
    private String name;

    @Column(name="pin")
    private String pin;

    @Setter
    @Column(name="language")
    private String language;

    @Setter
    @CreationTimestamp
    @Column(name="time_created")
    private LocalDateTime timeCreated;

    @Setter
    @UpdateTimestamp
    @Column(name="time_modified")
    private LocalDateTime timeModified;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name="owner_id")
    private DbUser owner;

    @OneToMany(mappedBy = "userDictionary",
               cascade = CascadeType.ALL,
               orphanRemoval = false)
    @Builder.Default
    private List<DbUserCard> userCards = new ArrayList<>();

    public void addUserCard(DbUserCard card) {
        card.setUserDictionary(this);
        this.userCards.add(card);
    }

    public void setId(Long id) {
        this.id = id;
    }

    public void setName(String name) {
        this.name = name;
    }

    public void setOwner(DbUser owner) {
        this.owner = owner;
    }

    public void setUserCards(List<DbUserCard> userCards) {
        this.userCards = userCards;
        this.userCards.forEach(card -> card.setUserDictionary(this));
    }

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
