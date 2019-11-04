package com.syno_back.backend.model;


import javax.persistence.*;
import java.util.List;

@Entity
@Table(name="user_card")
public class DbUserCard {
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private Long id;

    @Column(name="name")
    private String name;

    @Column(name="language")
    private String language;

    @OneToMany(mappedBy = "source_card")
    private List<DbTranslation> translations;

    public Long getId() {
        return id;
    }

    public String getName() {
        return name;
    }

    public String getLanguage() {
        return language;
    }

    public List<DbTranslation> getTranslations() {
        return translations;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public void setName(String name) {
        this.name = name;
    }

    public void setLanguage(String language) {
        this.language = language;
    }

    public void setTranslations(List<DbTranslation> translations) {
        this.translations = translations;
    }
}
