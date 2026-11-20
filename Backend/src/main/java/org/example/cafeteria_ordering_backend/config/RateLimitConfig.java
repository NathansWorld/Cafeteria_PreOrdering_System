package org.example.cafeteria_ordering_backend.config;

import org.example.cafeteria_ordering_backend.security.RateLimitFilter;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import io.github.bucket4j.Bandwidth;
import io.github.bucket4j.Bucket;
import io.github.bucket4j.Refill;
import java.time.Duration;
import org.springframework.boot.web.servlet.FilterRegistrationBean;

@Configuration
public class RateLimitConfig {

    // Creates a rate-limit bucket for a client with 100 tokens.
    // Each request consumes 1 token.
    // Refills 100 tokens every minute.
    // Once all tokens are consumed further requests are rejected.
    public Bucket createBucket() {

        Bandwidth limit = Bandwidth.classic(
                100,
                Refill.intervally(100, Duration.ofMinutes(3))
        );

        return Bucket.builder()
                .addLimit(limit)
                .build();
    }


    // Prevents Spring Boot from registering the filter outside Spring Security.
    @Bean
    public FilterRegistrationBean<RateLimitFilter> rateLimitFilterRegistration(
            RateLimitFilter rateLimitFilter
    ) {

        FilterRegistrationBean<RateLimitFilter> registration =
                new FilterRegistrationBean<>(rateLimitFilter);

        registration.setEnabled(false);

        return registration;
    }




}