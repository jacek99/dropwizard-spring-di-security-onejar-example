package com.github.jacek99.myapp.exception.mapper;

import com.github.jacek99.myapp.exception.NotFoundException;
import org.springframework.stereotype.Component;

import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import javax.ws.rs.ext.ExceptionMapper;
import javax.ws.rs.ext.Provider;


@Provider
@Component
public class NotFoundExceptionMapper implements ExceptionMapper<NotFoundException> {
    @Override
    public Response toResponse(NotFoundException ex) {
        return Response.status(Response.Status.NOT_FOUND)
                .entity(new OperationError(ex.getEntityName(),null,ex.getKey(), ex.getMessage()))
                .type(MediaType.APPLICATION_JSON).build();
    }
}
