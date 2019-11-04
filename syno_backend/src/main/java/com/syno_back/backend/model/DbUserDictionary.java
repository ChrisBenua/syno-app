package com.syno_back.backend.model;

import javax.persistence.*;

@Entity
@Table(name="user_dictionary")
public class DbUserDictionary {
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private Long id = 0L;

    @Column(name="name")
    private String name;

    //@ManyToOne
}
