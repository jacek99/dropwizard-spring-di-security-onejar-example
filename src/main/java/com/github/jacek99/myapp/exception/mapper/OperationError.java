package com.github.jacek99.myapp.exception.mapper;

import lombok.Data;
import lombok.RequiredArgsConstructor;

/**
* An object that represents a REST operation error
 */
@Data @RequiredArgsConstructor
public class OperationError {
    private final String entityName;
    private final String field;
    private final Object value;
    private final String error;
}
