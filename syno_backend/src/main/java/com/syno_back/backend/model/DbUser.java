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

/**
 * Class for mapping DB users to java object
 */
@Builder
@AllArgsConstructor
@NoArgsConstructor
@Entity
@Table(name="users")
public class DbUser {

    /**
     * DB's id
     */
    @Builder.Default
    @Getter
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private Long id = 0L;

    /**
     * User's email
     */
    @Getter
    @Setter
    @Column(name="email")
    private String email;

    /**
     * User's password
     *
     * Encrypted
     */
    @Getter
    @Setter
    @Column(name="password")
    private String password;

    /**
     * Time when user was created
     */
    @Getter
    @CreationTimestamp
    @Column(name="time_created")
    private LocalDateTime timeCreated;

    /**
     * Time when user was modified
     */
    @Getter
    @UpdateTimestamp
    @Column(name="time_modified")
    private LocalDateTime timeModified;

    /**
     * User's roles
     */
    @Setter
    @ManyToMany(fetch = FetchType.EAGER)
    @JoinTable(
            name = "users_roles",
            joinColumns = @JoinColumn(name="user_id", referencedColumnName = "id"),
            inverseJoinColumns = @JoinColumn(name="role_id", referencedColumnName = "id"))
    @Builder.Default
    private Collection<DbRole> roles = new ArrayList<>();

    /**
     * User's dictionary
     */
    @Getter
    @OneToMany(mappedBy = "owner",
               cascade = CascadeType.ALL,
               orphanRemoval = true)
    @Builder.Default
    private List<DbUserDictionary> userDictionaries = new ArrayList<>();

    /**
     * Remove dictionary from user
     * @param dict dictionary to remove
     */
    public void removeDictionary(DbUserDictionary dict) {
        userDictionaries.remove(dict);
    }

    /**
     * Creates new <code>DbUser</code>
     * @param email new user's email
     * @param password new user's password
     */
    public DbUser(String email, String password) {
        this.email = email;
        this.password = password;
    }

    /**
     * Adds given dictionary to user
     * @param userDictionary dictionary to add
     */
    public void addUserDictionary(DbUserDictionary userDictionary) {
        userDictionaries.add(userDictionary);
        userDictionary.setOwner(this);
    }

    /**
     * Gets roles
     * @return user's roles
     */
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
