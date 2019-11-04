package com.syno_back.backend.model;

import javax.persistence.*;
import java.util.Collection;
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

    @ManyToMany(fetch = FetchType.EAGER)
    @JoinTable(
            name = "users_roles",
            joinColumns = @JoinColumn(name="user_id", referencedColumnName = "id"),
            inverseJoinColumns = @JoinColumn(name="role_id", referencedColumnName = "id"))
    private Collection<DbRole> roles;

    public DbUser() {}

    public DbUser(String email, String password) {
        this.email = email;
        this.password = password;
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

    public Optional<Collection<DbRole>> getRoles() {
        return Optional.ofNullable(roles);
    }

    public void setRoles(Collection<DbRole> roles) {
        this.roles = roles;
    }
}
