package org.example.cafeteria_ordering_backend.component;

import org.example.cafeteria_ordering_backend.repository.OrderRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.Clock;
import java.time.Instant;
import java.time.ZoneId;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class OrderNumberGeneratorTest {

    @Mock
    private OrderRepository orderRepository;

    private OrderNumberGenerator generator;

    // Initialize test data before each test
    @BeforeEach
    void setUp () {

        Clock fixedClock = Clock.fixed(
                Instant.parse("2026-10-09T10:15:30.00Z"),
                ZoneId.of("Africa/Johannesburg")
        );
        generator = new OrderNumberGenerator(fixedClock, orderRepository);
    }

    // Ensure generator correctly creates ord number when no collision takes place
    @Test
    @DisplayName("Generates unique order number on first attempt when no collision exists")
    void testGenerateOrderNumberSuccess () {

        when(orderRepository.existsByCustomerOrderNumber(anyString())).thenReturn(false);

        String orderNumber = generator.generate();

        assertThat(orderNumber).isNotNull().matches("^ORD-\\d{2}-\\d{2}-[A-Z0-9]{4}$");
        verify(orderRepository).existsByCustomerOrderNumber(orderNumber);
    }

    // Ensures generator retires if first attempt results in collision
    @Test
    @DisplayName("Retries generation when a collision occurs")
    void testCollisionRetry () {

        when(orderRepository.existsByCustomerOrderNumber(anyString()))
                .thenReturn(true)
                .thenReturn(false);

        String orderNumber = generator.generate();

        assertThat(orderNumber).isNotNull();
        verify(orderRepository, times(2)).existsByCustomerOrderNumber(anyString());
    }
}