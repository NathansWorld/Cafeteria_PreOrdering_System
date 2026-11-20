package org.example.cafeteria_ordering_backend.event;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Component;
import org.springframework.transaction.event.TransactionPhase;
import org.springframework.transaction.event.TransactionalEventListener;

import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

@Component
public class WebSocketEventListener {

    private static final Logger logger = LoggerFactory.getLogger(WebSocketEventListener.class);
    private final SimpMessagingTemplate messagingTemplate;

    public WebSocketEventListener (SimpMessagingTemplate messagingTemplate) {

        this.messagingTemplate = messagingTemplate;
    }

    @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT)
    public void handleWebSocketBroadcast (WebSocketMessageEvent<?> event) {

        try {
            Map<String, Object> safePayload = new HashMap<>();
            safePayload.put("action", event.getAction());
            safePayload.put("type", event.getType());
            safePayload.put("data", event.getData());

            messagingTemplate.convertAndSend((String) event.getDestination(), (Object) safePayload);

            logger.info("Successfully broadcasted [{}] event for type [{}] to {}",
                    event.getAction(), event.getType(), event.getDestination());
        } catch (Exception e) {
            logger.error("Failed to broadcast WebSocket message: {}", e.getMessage(), e);
        }
    }
}