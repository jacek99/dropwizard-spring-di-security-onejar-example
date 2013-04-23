package com.github.jacek99.myapp.dao;

import com.github.jacek99.myapp.domain.Country;
import com.github.jacek99.myapp.domain.EntityValidator;
import com.github.jacek99.myapp.exception.ConflictException;
import com.github.jacek99.myapp.exception.NotFoundException;
import com.github.jacek99.myapp.security.Authorities;
import com.google.common.base.Optional;
import com.google.common.collect.Lists;
import org.springframework.security.access.annotation.Secured;
import org.springframework.stereotype.Repository;

import javax.inject.Inject;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@Repository
@Secured(Authorities.ROLE_READ_ONLY)
public class CountryDAO {

    private Map<String,Country> database = new ConcurrentHashMap<>();

    @Inject private EntityValidator entityValidator;

    public List<Country> getAll() {
        return Lists.newLinkedList(database.values());
    }

    public Optional<Country> getById(String countryCode) {
        return Optional.fromNullable(database.get(countryCode));
    }

    /**
     * throws exception if country not found for easy 404 error handling throughout app
     */
    public Country getExistingById(String countryCode) {
        Country country = getById(countryCode).orNull();
        if (country != null) {
            return country;
        } else {
            throw new NotFoundException("Country",countryCode);
        }
    }

    @Secured(Authorities.ROLE_ADMIN)
    public void add(Country country) {
        entityValidator.validate(country,"countryCode");
        if (database.containsKey(country.getCountryCode())) {
            throw new ConflictException("Country","countryCode",country.getCountryCode());
        } else {
            database.put(country.getCountryCode(),country);
        }
    }

    @Secured(Authorities.ROLE_ADMIN)
    public void update(Country country) {
        entityValidator.validate(country,"countryCode");
        database.put(country.getCountryCode(),country);
    }

    @Secured(Authorities.ROLE_ADMIN)
    public void delete(String countryCode) {
        database.remove(countryCode);
    }

    @Secured(Authorities.ROLE_ADMIN)
    public void deleteAll() {
        database.clear();
    }

}













