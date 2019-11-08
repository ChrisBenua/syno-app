package com.syno_back.backend.dto;

import java.io.Serializable;

public class NewUserDictionary implements Serializable {

    private String name;

    public NewUserDictionary() {}

    public NewUserDictionary(String name) {
        this.name = name;
    }

    public String getName() {
        return name;
    }

    private static final long serialVersionUID = -1264970284522287974L;
}
