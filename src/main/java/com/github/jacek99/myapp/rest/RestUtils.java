package com.github.jacek99.myapp.rest;


import javax.ws.rs.core.Response;
import javax.ws.rs.core.UriBuilder;
import java.net.URI;

/**
 * URI builder service...builds nicer/better URIs than the default one
 */
public class RestUtils {

    /**
     * Returns a 201 Created response that returns a location header which strips out the server/ip port,
     * so that the caller does not have to remove it themselves (since it refers to the server's IP address,
     * which may not be available behind a firewall that exposes only a load balancer in production)
     * @param resource JAX-RS resource class
     * @param entity Newly created entity
     * @param params The list of params, including parent @PathParams + the Id of the newly created object
     * @return 201 Response
     */
    public static Response getCreatedResponse(Class<?> resource, Object entity, Object... params) {
        URI uri = getUri(resource,params);
        return Response.created(null).header("location",uri.toString()).entity(entity).build();
    }

    /**
     * Builds a default proper URI for a newly created entity
     * @param resource Resource class (i.e. the JAX-RS class with @Path on it)
     * @param params The list of params, including parent @PathParams + the Id of the newly created object
     * @return URI
     */
    public static URI getUri(Class<?> resource, Object... params) {
        try {
            return UriBuilder.fromResource(resource).path("/{id}").build(params);
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }
}
