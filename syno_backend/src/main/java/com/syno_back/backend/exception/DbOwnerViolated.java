package com.syno_back.backend.exception;

/**
 * Exception for indicating access to not current user's data
 */
public class DbOwnerViolated extends RuntimeException {
    public DbOwnerViolated(String message) {
        super("Db Access Violated: " + message);
    }

    public DbOwnerViolated(String message, Throwable cause) {
        super("Db Access Violated: " + message, cause);
    }
}
