package com.syno_back.backend.model;

import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import javax.persistence.*;
import java.time.LocalDateTime;
import java.util.UUID;

/**
 * Class for mapping DB <b>dict_share</b> instance to Java object
 */
@Getter
@NoArgsConstructor
@Entity
@Table(name="dict_shares")
public class DbDictShare {
    /**
     * DB's dict_share id
     */
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private Long id;

    /**
     * Unique random id for <code>DbDictShare</code>
     */
    @Column(name = "share_uuid")
    private UUID shareUUID;

    /**
     * Timestamp when <code>DbDictShare</code> was created
     */
    @Column(name = "time_created")
    @CreationTimestamp
    private LocalDateTime timeCreated;

    /**
     * Timestamp when <code>DbDictShare</code> was modified
     */
    @UpdateTimestamp
    @Column(name="time_modified")
    private LocalDateTime timeModified;

    /**
     * Time when share was activated
     */
    @Column(name="activation_time")
    private LocalDateTime activationTime;

    /**
     * Share's owner
     */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name="owner_id", referencedColumnName = "id")
    private DbUser owner;

    /**
     * Which dictionary was shared
     */
    @OneToOne(cascade = CascadeType.ALL)
    @JoinColumn(name="dict_id", referencedColumnName = "id")
    private DbUserDictionary sharedDictionary;

    /**
     * Activates this <code>DbDictShare</code>
     */
    public void activate() {
        this.activationTime = LocalDateTime.now();
    }

    /**
     * When Share is created need activate it
     */
    @PrePersist
    void setActivationTimeOnPrePersist() {
        this.activate();
    }

    /**
     * Gets <code>DbDictShare</code> builder
     * @return builder
     */
    public static Builder builder() {
        return new Builder();
    }

    /**
     * Creates new <code>DbDictShare</code>
     * @param id DB's id
     * @param shareUUID unique random id
     * @param owner share's owner
     * @param sharedDictionary dictionary to be shared
     */
    private DbDictShare(Long id, UUID shareUUID, DbUser owner, DbUserDictionary sharedDictionary) {
        this.id = id;
        this.shareUUID = shareUUID;
        this.owner = owner;
        this.sharedDictionary = sharedDictionary;
    }

    @Override
    public int hashCode() {
        return this.id.hashCode();
    }

    @Override
    public boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }

        if (obj == null || obj.getClass() != this.getClass()) {
            return false;
        }

        return getId().equals(((DbDictShare)obj).getId());
    }

    /**
     * Custom builder for <code>DbUserCard</code>
     */
    public static class Builder {
        /**
         * DB's id
         */
        private Long id;
        /**
         * Share's owner
         */
        private DbUser owner;
        /**
         * Dictionary to be shared
         */
        private DbUserDictionary sharedDictionary;

        /**
         * Sets id
         * @param id DB's id
         * @return this
         */
        public Builder id(@NonNull Long id) {
            this.id = id;
            return this;
        }

        /**
         * Sets owner
         * @param owner share's onwer
         * @return this
         */
        public Builder owner(@NonNull DbUser owner) {
            this.owner = owner;
            return this;
        }

        /**
         * Sets shared dictionary
         * @param sharedDictionary dictionary to be shared
         * @return this
         */
        public Builder sharedDictionary(@NonNull DbUserDictionary sharedDictionary) {
            this.sharedDictionary = sharedDictionary;
            return this;
        }

        /**
         * Generates UUID
         * @return new UUID
         */
        private UUID generateUUIDForDict() {
            return UUID.nameUUIDFromBytes(sharedDictionary.getId().toString().getBytes());
        }

        /**
         * Builds builder
         * @return new <code>DbDictShare</code> instance
         */
        public DbDictShare build() {
            return new DbDictShare(id, generateUUIDForDict(), owner, sharedDictionary);
        }
    }
}
