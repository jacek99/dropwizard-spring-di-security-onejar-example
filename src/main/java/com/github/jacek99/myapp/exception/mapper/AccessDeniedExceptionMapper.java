package com.github.jacek99.myapp.exception.mapper;

import lombok.extern.slf4j.Slf4j;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Component;

import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import javax.ws.rs.ext.ExceptionMapper;
import javax.ws.rs.ext.Provider;

/**
 * Maps the Spring Security AccessDeniedException to a nice 401 error
 */
@Component
@Provider
@Slf4j
public class AccessDeniedExceptionMapper implements ExceptionMapper<AccessDeniedException> {

    @Override
    public Response toResponse(AccessDeniedException exception) {
        log.info("Security exception",exception);
        return Response.status(Response.Status.FORBIDDEN)
                .entity(new OperationError(null,null,null,"Access denied"))
                .type(MediaType.APPLICATION_JSON).build();
    }
}
