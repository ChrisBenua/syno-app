package com.syno_back.backend.model;

import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import javax.persistence.*;
import java.time.LocalDateTime;
import java.util.UUID;

@Builder
@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter
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

    @Column(name="pin")
    private String pin;

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
