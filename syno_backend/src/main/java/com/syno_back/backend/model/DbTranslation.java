package com.syno_back.backend.model;

import javax.persistence.*;

@Entity
@Table(name="translations")
public class DbTranslation {
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private Long id;

    @Column(name="translation")
    private String translation;

    @Column(name="comment")
    private String comment;

    @Column(name="usage_sample")
    private String usageSample;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name="source_card_id")
    private DbUserCard sourceCard;

    public Long getId() {
        return id;
    }

    public String getTranslation() {
        return translation;
    }

    public String getComment() {
        return comment;
    }

    public String getUsageSample() {
        return usageSample;
    }

    public DbUserCard getSourceCard() {
        return sourceCard;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public void setTranslation(String translation) {
        this.translation = translation;
    }

    public void setComment(String comment) {
        this.comment = comment;
    }

    public void setUsageSample(String usageSample) {
        this.usageSample = usageSample;
    }

    public void setSourceCard(DbUserCard sourceCard) {
        this.sourceCard = sourceCard;
    }
}
