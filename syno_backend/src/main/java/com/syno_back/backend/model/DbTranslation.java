package com.syno_back.backend.model;

import lombok.AllArgsConstructor;
import lombok.Builder;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import javax.persistence.*;
import java.time.LocalDateTime;

@Builder
@AllArgsConstructor
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

    @Column(name="transcription")
    private String transcription;

    @Column(name="usage_sample")
    private String usageSample;

    @CreationTimestamp
    @Column(name="time_created")
    private LocalDateTime timeCreated;

    @UpdateTimestamp
    @Column(name="time_modified")
    private LocalDateTime timeModified;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name="source_card_id")
    private DbUserCard sourceCard;

    public DbTranslation(String translation, String comment, String usageSample, String transcription) {
        this.translation = translation;
        this.comment = comment;
        this.usageSample = usageSample;
        this.transcription = transcription;
    }

    public DbTranslation() {}

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

    public String getTranscription() {
        return transcription;
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

    public void setTranscription(String transcription) {
        this.transcription = transcription;
    }

    public LocalDateTime getTimeCreated() {
        return timeCreated;
    }

    public LocalDateTime getTimeModified() {
        return timeModified;
    }

    @Override
    public boolean equals(Object other) {
        if (other == null) {
            return false;
        }

        if (other.getClass().equals(this.getClass())) {
            return ((DbTranslation)other).getId().equals(this.getId());
        }
        return false;
    }

    @Override
    public int hashCode() {
        return 31;
    }
}
