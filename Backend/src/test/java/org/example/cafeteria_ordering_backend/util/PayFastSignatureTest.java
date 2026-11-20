package org.example.cafeteria_ordering_backend.util;

import org.junit.jupiter.api.Test;
import java.util.HashMap;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.*;

class PayFastSignatureTest {

    @Test
    void testGenerateSignature() {
        Map<String, String> data = new HashMap<>();
        data.put("merchant_id", "10000100");
        data.put("merchant_key", "46f0cd6975815");
        data.put("amount", "25.00");
        data.put("item_name", "EduEats Order #1");

        String passphrase = "test_passphrase";
        String signature = PayFastSignatureUtil.generateSignature(data, passphrase);

        assertNotNull(signature);
        assertEquals(32, signature.length()); // MD5 hashes are always 32 hex chars
    }
}