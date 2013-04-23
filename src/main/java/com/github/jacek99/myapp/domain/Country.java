package com.github.jacek99.myapp.domain;

import lombok.Data;
import lombok.EqualsAndHashCode;

import javax.validation.constraints.NotNull;
import javax.validation.constraints.Size;

@Data
@EqualsAndHashCode(of="countryCode")
public class Country {
    @NotNull
    @Size(min=2,max=2)
    private String countryCode;
    @NotNull
    @Size(min=3,max=50)
    private String name;
}
