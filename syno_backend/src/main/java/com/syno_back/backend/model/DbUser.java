package com.syno_back.backend.model;

import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import javax.persistence.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import java.util.Optional;

@Builder
@AllArgsConstructor
@NoArgsConstructor
@Entity
@Table(name="users")
public class DbUser {

    @Builder.Default
    @Getter
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private Long id = 0L;

    @Getter
    @Setter
    @Column(name="email")
    private String email;

    @Getter
    @Setter
    @Column(name="password")
    private String password;

    @Getter
    @CreationTimestamp
    @Column(name="time_created")
    private LocalDateTime timeCreated;

    @Getter
    @UpdateTimestamp
    @Column(name="time_modified")
    private LocalDateTime timeModified;

    @Setter
    @ManyToMany(fetch = FetchType.EAGER)
    @JoinTable(
            name = "users_roles",
            joinColumns = @JoinColumn(name="user_id", referencedColumnName = "id"),
            inverseJoinColumns = @JoinColumn(name="role_id", referencedColumnName = "id"))
    @Builder.Default
    private Collection<DbRole> roles = new ArrayList<>();

    @Getter
    @OneToMany(mappedBy = "owner",
               cascade = CascadeType.ALL,
               orphanRemoval = true)
    @Builder.Default
    private List<DbUserDictionary> userDictionaries = new ArrayList<>();

    public DbUser(String email, String password) {
        this.email = email;
        this.password = password;
    }

    public void addUserDictionary(DbUserDictionary userDictionary) {
        userDictionaries.add(userDictionary);
        userDictionary.setOwner(this);
    }

    public Optional<Collection<DbRole>> getRoles() {
        return Optional.ofNullable(roles);
    }

    @Override
    public boolean equals(Object other) {
        if (other == null) {
            return false;
        }

        if (other.getClass().equals(this.getClass())) {
            return ((DbUser)other).getId().equals(this.getId());
        }
        return false;
    }

    @Override
    public int hashCode() {
        return this.getId().hashCode();
    }
}
