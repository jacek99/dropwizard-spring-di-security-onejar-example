package com.github.jacek99.myapp.admin;

import com.github.jacek99.myapp.dao.CountryDAO;
import com.github.jacek99.myapp.security.Authorities;
import com.github.jacek99.myapp.security.MyAuthenticationManager;
import com.google.common.collect.ImmutableMultimap;
import com.yammer.dropwizard.tasks.Task;
import org.springframework.stereotype.Service;

import javax.inject.Inject;
import java.io.PrintWriter;

/**
 * Admin API to delete all data in memory when resetting DB during unit test runs
 */
@Service
public class ClearDataTask extends Task {
    @Inject private CountryDAO countryDAO;
    @Inject private MyAuthenticationManager auth;

    public ClearDataTask() {
        super("clearData");
    }

    @Override
    public void execute(ImmutableMultimap<String, String> parameters, PrintWriter output) throws Exception {
        //required by Spring Security
        auth.authenticateBackgroundTask(ClearDataTask.class, Authorities.ROLE_READ_ONLY, Authorities.ROLE_ADMIN);
        countryDAO.deleteAll();
    }

}
