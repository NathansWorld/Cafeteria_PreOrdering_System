
package org.example.cafeteria_ordering_backend.util;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.List;
import java.util.Map;

public class PaygateChecksumUtil {

    /**
     * Generates the checksum for a PayWeb3 initiation request.
     * Values must be concatenated in the exact order they are sent.
     */
    public static String generateInitiateChecksum(
            Map<String, String> data,
            String encryptionKey) {

        List<String> keys = List.of(
                "PAYGATE_ID", "REFERENCE", "AMOUNT", "CURRENCY", "RETURN_URL",
                "TRANSACTION_DATE", "LOCALE", "COUNTRY", "EMAIL", "NOTIFY_URL"
        );

        StringBuilder checksumData = new StringBuilder();

        for (String key : keys) {
            String value = data.get(key);
            if (value != null) {
                checksumData.append(value);
            }
        }

        checksumData.append(encryptionKey);

        return md5(checksumData.toString());
    }

    /**
     * Generates the checksum used for the PayWeb3 hosted checkout
     * form and for validating the initiation response.
     */
    public static String generateProcessChecksum(
            String payGateId,
            String payRequestId,
            String reference,
            String encryptionKey) {

        String checksumData =
                payGateId + payRequestId + reference + encryptionKey;

        return md5(checksumData);
    }

    /**
     * Generates the checksum for a PayGate notification response.
     *
     * Fields are concatenated in PayGate's documented order.
     * CHECKSUM itself is deliberately excluded.
     */
    public static String generateNotificationChecksum(
            Map<String, String> data,
            String encryptionKey) {

        List<String> fields = List.of(
                "PAYGATE_ID",
                "PAY_REQUEST_ID",
                "REFERENCE",
                "TRANSACTION_STATUS",
                "RESULT_CODE",
                "AUTH_CODE",
                "CURRENCY",
                "AMOUNT",
                "RESULT_DESC",
                "TRANSACTION_ID",
                "RISK_INDICATOR",
                "PAY_METHOD",
                "PAY_METHOD_DETAIL",
                "USER1",
                "USER2",
                "USER3",
                "VAULT_ID",
                "PAYVAULT_DATA_1",
                "PAYVAULT_DATA_2"
        );

        StringBuilder checksumData = new StringBuilder();

        for (String field : fields) {
            String value = data.get(field);

            if (value != null) {
                checksumData.append(value);
            }
        }

        checksumData.append(encryptionKey);

        return md5(checksumData.toString());
    }

    /**
     * Compares a supplied checksum against the expected checksum.
     */
    public static boolean verifyChecksum(
            String expectedChecksum,
            String receivedChecksum) {

        if (expectedChecksum == null ||
                receivedChecksum == null ||
                receivedChecksum.isBlank()) {
            return false;
        }

        return MessageDigest.isEqual(
                expectedChecksum.toLowerCase().getBytes(StandardCharsets.UTF_8),
                receivedChecksum.toLowerCase().getBytes(StandardCharsets.UTF_8)
        );
    }

    private static String md5(String input) {

        try {
            MessageDigest md = MessageDigest.getInstance("MD5");

            byte[] digest = md.digest(
                    input.getBytes(StandardCharsets.UTF_8)
            );

            StringBuilder result = new StringBuilder();

            for (byte b : digest) {
                result.append(String.format("%02x", b & 0xff));
            }

            return result.toString();

        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("MD5 algorithm unavailable", e);
        }
    }
}
