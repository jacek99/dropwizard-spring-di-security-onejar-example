package com.github.jacek99.myapp.exception.mapper;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;

import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import javax.ws.rs.ext.ExceptionMapper;
import javax.ws.rs.ext.Provider;

@Provider
@Component
public class GenericExceptionMapper implements ExceptionMapper<Exception> {

    private static final Logger log = LoggerFactory.getLogger(GenericExceptionMapper.class);

    @Override
    public Response toResponse(Exception exception) {
        log.error("Unexpected server error",exception);
        //we don't display any details of the exception (which may be sensitive), just its class name
        return Response.serverError()
                .entity(new OperationError(null,null,null, "Internal server error"))
                .type(MediaType.APPLICATION_JSON).build();
    }
}
