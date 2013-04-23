package com.github.jacek99.myapp.rest;

import javax.ws.rs.HttpMethod;
import java.lang.annotation.Documented;
import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

/**
 * Creates the PATCH HTTP method, since JAX-RS does not support it natively yet
 */
@Documented
@Target({ ElementType.METHOD })
@Retention(RetentionPolicy.RUNTIME)
@HttpMethod("PATCH")
public @interface PATCH {
}
