package com.github.jacek99.myapp.health;

import com.github.jacek99.myapp.dao.CountryDAO;
import com.github.jacek99.myapp.security.Authorities;
import com.github.jacek99.myapp.security.MyAuthenticationManager;
import com.yammer.metrics.core.HealthCheck;
import org.springframework.stereotype.Service;

import javax.inject.Inject;

@Service
public class DatabaseHealthCheck extends HealthCheck {

    @Inject private MyAuthenticationManager auth;
    @Inject private CountryDAO countryDAO;

    public DatabaseHealthCheck() {
        super("database");
    }

    @Override
    protected Result check() throws Exception {

        auth.authenticateBackgroundTask(DatabaseHealthCheck.class, Authorities.ROLE_READ_ONLY);

        if (countryDAO.getAll().size() >= 0) {
            return Result.healthy();
        } else {
            return Result.unhealthy("unable to reach database");
        }

    }
}
