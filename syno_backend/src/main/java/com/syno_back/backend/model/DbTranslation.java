package com.syno_back.backend.model;

import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import javax.persistence.*;
import java.time.LocalDateTime;
import java.util.UUID;

/**
 * Class for mapping DB translation to java object
 */
@Builder
@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter
@Entity
@Table(name="translations")
public class DbTranslation {
    /**
     * DB's id
     */
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private Long id;

    /**
     * Actual translation
     */
    @Column(name="translation")
    private String translation;

    /**
     * User's comment
     */
    @Column(name="comment")
    private String comment;

    /**
     * Translation's transcription
     */
    @Column(name="transcription")
    private String transcription;

    /**
     * Translation usage sample
     */
    @Column(name="usage_sample")
    private String usageSample;

    /**
     * Unique <code>DbTranslation</code> id
     */
    @Column(name="pin")
    private String pin;

    /**
     * Time when translation was created
     */
    @CreationTimestamp
    @Column(name="time_created")
    private LocalDateTime timeCreated;

    /**
     * Time when translation was modified
     */
    @UpdateTimestamp
    @Column(name="time_modified")
    private LocalDateTime timeModified;

    /**
     * Card that owns this translation
     */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name="source_card_id")
    private DbUserCard sourceCard;

    /**
     * Creates new <code>DbTranslation</code>
     * @param translation actual translation
     * @param comment user's comment
     * @param usageSample translation usage sample
     * @param transcription translation's transcription
     */
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
