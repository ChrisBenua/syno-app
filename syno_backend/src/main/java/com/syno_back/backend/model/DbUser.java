package com.syno_back.backend.model;

import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import javax.persistence.*;
import java.time.LocalDateTime;
import java.util.Collection;
import java.util.List;
import java.util.Optional;

@Entity
@Table(name="users")
public class DbUser {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private Long id = 0L;

    @Column(name="email")
    private String email;

    @Column(name="password")
    private String password;

    @CreationTimestamp
    @Column(name="time_created")
    private LocalDateTime timeCreated;

    @UpdateTimestamp
    @Column(name="time_modified")
    private LocalDateTime timeModified;

    @ManyToMany(fetch = FetchType.EAGER)
    @JoinTable(
            name = "users_roles",
            joinColumns = @JoinColumn(name="user_id", referencedColumnName = "id"),
            inverseJoinColumns = @JoinColumn(name="role_id", referencedColumnName = "id"))
    private Collection<DbRole> roles;

    @OneToMany(mappedBy = "owner",
               cascade = CascadeType.ALL,
               orphanRemoval = true)
    private List<DbUserDictionary> userDictionaries;

    public DbUser() {}

    public DbUser(String email, String password) {
        this.email = email;
        this.password = password;
    }

    public void addUserDictionary(DbUserDictionary userDictionary) {
        userDictionaries.add(userDictionary);
        userDictionary.setOwner(this);
    }

    public Long getId() {
        return id;
    }

    public String getEmail() {
        return email;
    }

    public String getPassword() {
        return password;
    }

    public List<DbUserDictionary> getUserDictionaries() {
        return userDictionaries;
    }

    public Optional<Collection<DbRole>> getRoles() {
        return Optional.ofNullable(roles);
    }

    public void setRoles(Collection<DbRole> roles) {
        this.roles = roles;
    }
}
