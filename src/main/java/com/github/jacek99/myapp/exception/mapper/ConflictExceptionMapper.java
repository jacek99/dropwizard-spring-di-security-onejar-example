package com.github.jacek99.myapp.exception.mapper;

import com.github.jacek99.myapp.exception.ConflictException;
import org.springframework.stereotype.Component;

import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import javax.ws.rs.ext.ExceptionMapper;
import javax.ws.rs.ext.Provider;

@Provider
@Component
public class ConflictExceptionMapper implements ExceptionMapper<ConflictException> {
    @Override
    public Response toResponse(ConflictException ex) {
        return Response.status(Response.Status.CONFLICT)
                .entity(new OperationError(ex.getEntityName(),ex.getFieldName(), ex.getFieldValue(), ex.getMessage()))
                .type(MediaType.APPLICATION_JSON).build();
    }
}
