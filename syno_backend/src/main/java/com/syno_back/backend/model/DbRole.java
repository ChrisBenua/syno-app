package com.syno_back.backend.model;


import javax.persistence.*;

@Entity
@Table(name="roles")
public class DbRole {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private Long id;

    @Column(name="name")
    private String name;


    public Long getId() {
        return id;
    }

    public String getName() {
        return name;
    }

    @Override
    public boolean equals(Object other) {
        if (other == null) {
            return false;
        }

        if (other.getClass().equals(this.getClass())) {
            return ((DbRole)other).getId().equals(this.getId());
        }
        return false;
    }

    @Override
    public int hashCode() {
        return 31;
    }
}
