package com.github.jacek99.myapp.exception;

/**
 * 400 input error
 */
public class EntityConstraintViolationException extends RuntimeException {

    private String entityName;
    private String fieldName;
    private String errorMessage;
    private Object invalidValue;

    public EntityConstraintViolationException(String entityName, String fieldName, Object invalidValue, String errorMessage) {
        super(errorMessage);
        this.entityName =entityName;
        this.fieldName=fieldName;
        this.errorMessage =errorMessage;
        this.invalidValue =invalidValue;
    }

    public String getEntityName() {
        return entityName;
    }

    public String getFieldName() {
        return fieldName;
    }

    public String getErrorMessage() {
        return errorMessage;
    }

    public Object getInvalidValue() {
        return invalidValue;
    }

}
