package com.github.jacek99.myapp.health;

import com.github.jacek99.myapp.dao.CountryDAO;
import com.yammer.metrics.core.HealthCheck;
import org.springframework.stereotype.Service;

import javax.inject.Inject;

@Service
public class DatabaseHealthCheck extends HealthCheck {

    @Inject private CountryDAO countryDAO;

    public DatabaseHealthCheck() {
        super("database");
    }

    @Override
    protected Result check() throws Exception {
        if (countryDAO.getAll().size() > 0) {
            return Result.unhealthy("no data in database");
        } else {
            return Result.healthy();
        }

    }
}
