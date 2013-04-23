package com.github.jacek99.myapp.exception;

public class NotFoundException extends RuntimeException {

    private String entityName;
    private String key;

    public NotFoundException(String entityName, String key) {
        super(String.format("Entity %s identified by key %s not found",entityName,key));
        this.entityName = entityName;
        this.key = key;
    }

    public String getEntityName() {
        return entityName;
    }

    public String getKey() {
        return key;
    }

}
