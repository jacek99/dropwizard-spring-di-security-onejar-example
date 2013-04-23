package com.github.jacek99.myapp.resource;

import com.github.jacek99.myapp.dao.CountryDAO;
import com.github.jacek99.myapp.domain.Country;
import com.github.jacek99.myapp.rest.PATCH;
import com.github.jacek99.myapp.rest.RestUtils;
import org.springframework.stereotype.Service;

import javax.inject.Inject;
import javax.ws.rs.Consumes;
import javax.ws.rs.DELETE;
import javax.ws.rs.FormParam;
import javax.ws.rs.GET;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import java.util.List;

@Path("/country")
@Produces(MediaType.APPLICATION_JSON)
@Service
public class CountryResource {

    @Inject private CountryDAO dao;

    @GET
    public List<Country> getAll() {
        return dao.getAll();
    }

    @GET @Path("/{countryCode}")
    public Country getOne(@PathParam("countryCode") String countryCode) {
        return dao.getExistingById(countryCode);
    }

    @POST
    @Consumes(MediaType.APPLICATION_FORM_URLENCODED)
    public Response add(@FormParam("countryCode") String countryCode, @FormParam("name") String name) {
        Country country = new Country();
        country.setCountryCode(countryCode);
        country.setName(name);
        dao.add(country);

        return RestUtils.getCreatedResponse(CountryResource.class, country, country.getCountryCode());
    }

    @PATCH
    @Path("/{countryCode}")
    @Consumes(MediaType.APPLICATION_FORM_URLENCODED)
    public Response update(@PathParam("countryCode") String countryCode, @FormParam("name") String name) {
        Country country = dao.getExistingById(countryCode);
        if(name != null) {
            country.setName(name);
        }
        dao.update(country);
        return Response.ok().build();
    }

    @DELETE
    @Path("/{countryCode}")
    public Response delete(@PathParam("countryCode") String countryCode) {
        Country country = dao.getExistingById(countryCode);
        dao.delete(country.getCountryCode());
        return Response.ok().build();
    }

}



















