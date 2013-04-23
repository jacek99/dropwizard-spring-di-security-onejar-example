package com.github.jacek99.myapp.exception.mapper;

import com.github.jacek99.myapp.exception.EntityConstraintViolationException;
import org.springframework.stereotype.Component;

import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import javax.ws.rs.ext.ExceptionMapper;
import javax.ws.rs.ext.Provider;

/**
 * Maps the Hibernate validator exception to a nice 400 error
 */
@Provider
@Component
public class EntityConstraintViolationExceptionMapper implements ExceptionMapper<EntityConstraintViolationException> {
    @Override
    public Response toResponse(EntityConstraintViolationException ex) {
        return Response.status(Response.Status.BAD_REQUEST)
                .entity(new OperationError(ex.getEntityName(),ex.getFieldName(), ex.getInvalidValue(),ex.getMessage()))
                .type(MediaType.APPLICATION_JSON).build();
    }


}
