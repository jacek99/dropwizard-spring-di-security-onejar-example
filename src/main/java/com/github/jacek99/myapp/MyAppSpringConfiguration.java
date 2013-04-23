package com.github.jacek99.myapp;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.ImportResource;
import org.springframework.security.access.vote.RoleVoter;

/**
Main Spring Configuration
 */
@Configuration
@ImportResource("classpath:myapp-security.xml")
@ComponentScan(basePackageClasses = MyAppSpringConfiguration.class)
public class MyAppSpringConfiguration {


    @Bean
    public RoleVoter getRoleVoter() {
        RoleVoter roleVoter = new RoleVoter();
        roleVoter.setRolePrefix("ROLE _");
        return roleVoter;
    }
}
