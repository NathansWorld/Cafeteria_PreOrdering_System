package org.example.cafeteria_ordering_backend.service.interfaces;

import org.example.cafeteria_ordering_backend.dto.requests.OrderRequestDTO;
import java.util.Map;

public interface PayFastService {

    Map<String, String> createPaymentPayload(OrderRequestDTO orderRequest, String userEmail);
    void processPayFastITN(Map<String, String> itnParams);

}
