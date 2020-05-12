package com.syno_back.backend.service;

/**
 * Service interface for cloning <code>T</code> instances
 * @param <T> type of object to be cloned
 */
public interface IEntityCloner<T> {
    /**
     * Clones object
     * @param cloneable object to be cloned
     * @return clone of <code>cloneable</code>
     */
    T clone(T cloneable);
}
