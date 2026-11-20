package org.example.cafeteria_ordering_backend.service.interfaces;

import io.github.bucket4j.Bucket;

public interface RateLimitService {

    // Retrieves the rate-limit bucket associated with a client.
    Bucket resolveBucket(String clientKey);
}