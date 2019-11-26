package com.syno_back.backend.service;

public interface IEntityCloner<T> {
    T clone(T cloneable);
}
