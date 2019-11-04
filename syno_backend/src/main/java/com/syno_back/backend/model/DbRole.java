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
}
