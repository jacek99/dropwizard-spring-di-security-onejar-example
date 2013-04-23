package com.github.jacek99.myapp.exception;

/**
 * Created with IntelliJ IDEA.
 * User: jacekf
 * Date: 3/18/13
 * Time: 1:44 PM
 * To change this template use File | Settings | File Templates.
 */
public class ConflictException extends RuntimeException {

    private String entityName;
    private String fieldName;
    private Object fieldValue;

    public ConflictException(String entityName, String fieldName, Object fieldValue) {
        super(String.format("A data conflict has occurred. An entity of type %s identified by %s=%s conflicts with an existing entity",
                entityName,fieldName,fieldValue));
        this.entityName = entityName;
        this.fieldName = fieldName;
        this.fieldValue = fieldValue;
    }

    public String getEntityName() {
        return entityName;
    }

    public String getFieldName() {
        return fieldName;
    }

    public Object getFieldValue() {
        return fieldValue;
    }
}









