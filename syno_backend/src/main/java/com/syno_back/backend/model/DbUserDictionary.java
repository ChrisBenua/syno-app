package com.syno_back.backend.model;

import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import javax.persistence.*;
import java.time.LocalDateTime;
import java.util.List;

@Entity
@Table(name="user_dictionaries")
public class DbUserDictionary {
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private Long id = 0L;

    @Column(name="name")
    private String name;

    @CreationTimestamp
    @Column(name="time_created")
    private LocalDateTime timeCreated;

    @UpdateTimestamp
    @Column(name="time_modified")
    private LocalDateTime timeModified;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name="owner_id")
    private DbUser owner;

    @OneToMany(mappedBy = "userDictionary",
               cascade = CascadeType.ALL,
               orphanRemoval = false)
    private List<DbUserCard> userCards;

    public void addUserCard(DbUserCard card) {
        card.setUserDictionary(this);
        this.userCards.add(card);
    }

    public Long getId() {
        return id;
    }

    public String getName() {
        return name;
    }

    public DbUser getOwner() {
        return owner;
    }

    public List<DbUserCard> getUserCards() {
        return userCards;
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

    public void setName(String name) {
        this.name = name;
    }

    public void setOwner(DbUser owner) {
        this.owner = owner;
    }

    public void setUserCards(List<DbUserCard> userCards) {
        this.userCards = userCards;
    }
}
