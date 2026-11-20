package org.example.cafeteria_ordering_backend.security;

import io.github.bucket4j.Bucket;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.example.cafeteria_ordering_backend.service.interfaces.RateLimitService;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;

@Component
public class RateLimitFilter extends OncePerRequestFilter {

    private final RateLimitService rateLimitService;

    public RateLimitFilter(RateLimitService rateLimitService) {
        this.rateLimitService = rateLimitService;
    }

    @Override
    protected void doFilterInternal(
            HttpServletRequest request,
            HttpServletResponse response,
            FilterChain filterChain
    ) throws ServletException, IOException {

        // Identifies the client making the request.
        Authentication authentication =
                SecurityContextHolder.getContext().getAuthentication();

        String clientKey;

        if (authentication != null && authentication.isAuthenticated()
                && !"anonymousUser".equals(authentication.getPrincipal())) {

            // Uses the authenticated user's identity.
            clientKey = "USER:" + authentication.getName();

        } else {

            // Uses the client's IP address if they are unauthenticated.
            clientKey = "IP:" + request.getRemoteAddr();
        }

        // Retrieves the client's rate-limit bucket.
        Bucket bucket = rateLimitService.resolveBucket(clientKey);

        // Rejects the request if the client has exceeded the limit.
        if (bucket.tryConsume(1)) {

            filterChain.doFilter(request, response);

        } else {

            response.setStatus(HttpStatus.TOO_MANY_REQUESTS.value());
            response.setContentType("application/json");
            response.getWriter().write(
                    "{\"message\":\"Too many requests. Please try again later.\"}"
            );
        }
    }
}