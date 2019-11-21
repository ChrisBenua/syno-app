package com.syno_back.backend.model;

import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import javax.persistence.*;
import java.time.LocalDateTime;
import java.util.UUID;

@Getter
@NoArgsConstructor
@Entity
@Table(name="dict_shares")
public class DbDictShare {
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private Long id;

    @Column(name = "share_uuid")
    private UUID shareUUID;

    @Column(name = "time_created")
    @CreationTimestamp
    private LocalDateTime timeCreated;

    @UpdateTimestamp
    @Column(name="time_modified")
    private LocalDateTime timeModified;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name="owner_id")
    private DbUser owner;

    @OneToOne(cascade = CascadeType.ALL)
    @JoinColumn(name="dict_id", referencedColumnName = "id")
    private DbUserDictionary sharedDictionary;

    public static Builder builder() {
        return new Builder();
    }

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

    public static class Builder {
        private Long id;
        private DbUser owner;
        private DbUserDictionary sharedDictionary;

        public Builder id(@NonNull Long id) {
            this.id = id;
            return this;
        }

        public Builder owner(@NonNull DbUser owner) {
            this.owner = owner;
            return this;
        }

        public Builder sharedDictionary(@NonNull DbUserDictionary sharedDictionary) {
            this.sharedDictionary = sharedDictionary;
            return this;
        }

        private UUID generateUUIDForDict() {
            return UUID.nameUUIDFromBytes(sharedDictionary.getId().toString().getBytes());
        }

        public DbDictShare build() {
            return new DbDictShare(id, generateUUIDForDict(), owner, sharedDictionary);
        }
    }
}
