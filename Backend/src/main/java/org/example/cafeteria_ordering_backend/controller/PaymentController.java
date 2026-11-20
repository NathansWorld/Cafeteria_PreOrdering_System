package org.example.cafeteria_ordering_backend.controller;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.example.cafeteria_ordering_backend.dto.requests.OrderRequestDTO;
import org.example.cafeteria_ordering_backend.service.implementation.PayFastServiceImpl;
import org.example.cafeteria_ordering_backend.service.implementation.PaygateServiceImpl;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import org.springframework.http.HttpHeaders;
import java.net.URI;
import org.springframework.http.MediaType;
import org.slf4j.Logger;
import jakarta.servlet.http.HttpServletRequest;
import org.slf4j.LoggerFactory;

import java.util.Map;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/payments")
public class PaymentController {

    private final PayFastServiceImpl payFastService;
    private final PaygateServiceImpl payGateService;

    private static final Logger logger = LoggerFactory.getLogger(PaygateServiceImpl.class);

    // Initiate PayFast checkout session
    @PostMapping("/payfast/initiate")
    @PreAuthorize("hasRole('CUSTOMER')")
    public ResponseEntity<Map<String, String>> initiatePayment (
            @Valid @RequestBody OrderRequestDTO orderRequest,
            Authentication authentication) {

        String userEmail = authentication != null ? authentication.getName() : "student@edueats.test";
        Map<String, String> payload = payFastService.createPaymentPayload(orderRequest, userEmail);

        return new ResponseEntity<>(payload, HttpStatus.OK);
    }

    // Handle PayFast ITN webhook callback (publicly accessible via SecurityConfig)
    @PostMapping("/payfast/itn")
    public ResponseEntity<Void> handleInstantTransactionNotification (@RequestParam Map<String, String> itnParams) {

        payFastService.processPayFastITN(itnParams);
        return ResponseEntity.ok().build();
    }

    // Handle redirect when user successfully pays on PayFast
    @GetMapping("/payfast/return")
    public ResponseEntity<String> paymentReturn () {

        HttpHeaders headers = new HttpHeaders();
        headers.setLocation(URI.create("http://localhost:5173/?payment=success#orders"));
        return new ResponseEntity<>(headers, HttpStatus.FOUND);
    }

    // Handle redirect when user cancels payment on PayFast
    @GetMapping("/payfast/cancel")
    public ResponseEntity<String> paymentCancel() {

        HttpHeaders headers = new HttpHeaders();
        headers.setLocation(URI.create("http://localhost:5173/?payment=cancelled#cart"));
        return new ResponseEntity<>(headers, HttpStatus.FOUND);
    }

    // Initiate PayGate checkout session
    @PostMapping("/paygate/initiate")
    @PreAuthorize("hasRole('CUSTOMER')")
    public ResponseEntity<Map<String, String>> initiatePayGatePayment(
            @Valid @RequestBody OrderRequestDTO orderRequest,
            HttpServletRequest request,
            Authentication authentication) {

        String userEmail = authentication.getName();

        // Dynamically derive base URL from tunnel/request headers
        String scheme = request.getHeader("X-Forwarded-Proto") != null
                ? request.getHeader("X-Forwarded-Proto")
                : request.getScheme();

        String serverHost = request.getHeader("X-Forwarded-Host") != null
                ? request.getHeader("X-Forwarded-Host")
                : request.getHeader("Host");

        String baseUrl = scheme + "://" + serverHost;

        Map<String, String> payload =
                payGateService.createPaymentPayload(orderRequest, userEmail, baseUrl);

        return ResponseEntity.ok(payload);
    }

    @PostMapping(
            value = "/paygate/notify",
            consumes = MediaType.APPLICATION_FORM_URLENCODED_VALUE,
            produces = MediaType.TEXT_PLAIN_VALUE
    )
    public ResponseEntity<String> payGateNotification(
            @RequestParam Map<String, String> notification) {

        payGateService.processPayGateNotification(notification);

        return ResponseEntity.ok()
                .contentType(MediaType.TEXT_PLAIN)
                .body("OK");
    }

    @Value("${app.frontend.url:http://localhost:5173}")
    private String frontendBaseUrl;

    @RequestMapping(
            value = "/paygate/return",
            method = {RequestMethod.GET, RequestMethod.POST},
            consumes = {MediaType.APPLICATION_FORM_URLENCODED_VALUE, MediaType.ALL_VALUE},
            produces = MediaType.TEXT_HTML_VALUE
    )
    public ResponseEntity<String> payGateReturn(
            @RequestParam Map<String, String> returnParams,
            HttpServletRequest request) {

        try {
            logger.info("Received PayGate return parameters: {}", returnParams);
            payGateService.processPayGateReturnOrNotification(returnParams);
        } catch (Exception e) {
            logger.error("Failed to process PayGate return synchronously: {}", e.getMessage(), e);
        }

        // Use the configured frontend URL (supports local dev or remote frontend Cloudflare tunnel)
        String redirectUrl = frontendBaseUrl + "/?payment=success#orders";

        String html = """
            <!DOCTYPE html>
            <html>
            <head>
                <title>Redirecting to EduEats...</title>
                <meta http-equiv="refresh" content="0;url=%s">
            </head>
            <body>
                <p>Payment successful! Redirecting you back to EduEats...</p>
                <script>
                    window.location.replace("%s");
                </script>
            </body>
            </html>
            """.formatted(redirectUrl, redirectUrl);

        return ResponseEntity.ok()
                .contentType(MediaType.TEXT_HTML)
                .body(html);
    }
}