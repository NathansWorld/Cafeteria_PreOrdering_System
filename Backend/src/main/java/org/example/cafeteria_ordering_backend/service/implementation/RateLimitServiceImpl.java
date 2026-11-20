package org.example.cafeteria_ordering_backend.service.implementation;

import io.github.bucket4j.Bucket;
import org.example.cafeteria_ordering_backend.config.RateLimitConfig;
import org.example.cafeteria_ordering_backend.service.interfaces.RateLimitService;
import org.springframework.stereotype.Service;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@Service
public class RateLimitServiceImpl implements RateLimitService {

    private final RateLimitConfig rateLimitConfig;

    // Stores a separate rate-limit bucket for each client.
    private final Map<String, Bucket> buckets = new ConcurrentHashMap<>();

    public RateLimitServiceImpl(RateLimitConfig rateLimitConfig) {
        this.rateLimitConfig = rateLimitConfig;
    }

    @Override
    public Bucket resolveBucket(String clientKey) {

        // Creates a bucket only if the client does not already have one.
        return buckets.computeIfAbsent(
                clientKey,
                key -> rateLimitConfig.createBucket()
        );
    }
}