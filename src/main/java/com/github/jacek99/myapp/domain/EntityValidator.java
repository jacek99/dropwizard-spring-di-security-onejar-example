package com.github.jacek99.myapp.domain;

import com.github.jacek99.myapp.exception.EntityConstraintViolationException;
import org.springframework.stereotype.Service;

import javax.validation.ConstraintViolation;
import javax.validation.Validation;
import javax.validation.Validator;
import javax.validation.ValidatorFactory;
import java.util.Comparator;
import java.util.Set;
import java.util.TreeSet;

@Service
public class EntityValidator {

    private ValidatorFactory validatorFactory = Validation.buildDefaultValidatorFactory();

    /**
     * Validates an entity against its Hibernate validators
     * @param entity Entity
     * @param idFieldName  The name of its primary Id field (used for sorting error messages)
     */
    public <E> void validate(E entity, String idFieldName) {
        Validator v = validatorFactory.getValidator();

        Set<ConstraintViolation<E>> violations = v.validate(entity);
        if (violations.size() > 0) {
            ConstraintViolation   cv = getFirstContraintViolation(violations, idFieldName);
            //return first error
            throw new EntityConstraintViolationException(cv.getRootBeanClass().getSimpleName(),
                    cv.getPropertyPath().toString(),cv.getInvalidValue(),cv.getMessage());
        }
    }

    //for consistency during testing, sorts by property path and returns the first one
    private <E> ConstraintViolation<E> getFirstContraintViolation(Set<ConstraintViolation<E>> allViolations, String idFieldName) {

        //first look for any errors on the ID field, the most important
        for(ConstraintViolation<E> cv : allViolations) {
            if (idFieldName.equals(cv.getPropertyPath().toString())) {
                return  cv;
            }
        }

        //if none found for ID field, then sort by field name and get first one
        TreeSet<ConstraintViolation<E>> violations = new TreeSet<>(new Comparator<ConstraintViolation<E>>() {
            @Override
            public int compare(ConstraintViolation<E> o1, ConstraintViolation<E> o2) {
                return o1.getPropertyPath().toString().compareTo(o2.getPropertyPath().toString());
            }
        });
        for(ConstraintViolation<E> cv : allViolations) {
            violations.add(cv);
        }
        return violations.first();
    }

}
