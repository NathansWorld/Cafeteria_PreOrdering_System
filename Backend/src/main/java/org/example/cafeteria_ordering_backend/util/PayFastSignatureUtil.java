package org.example.cafeteria_ordering_backend.util;

import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.Map;
import java.util.TreeMap;

public class PayFastSignatureUtil {

    public static String generateSignature (Map<String, String> data, String passphrase) {

        // TreeMap sorts parameters alphabetically by key
        Map<String, String> sortedData = new TreeMap<>(data);
        StringBuilder sb = new StringBuilder();

        for (Map.Entry<String, String> entry : sortedData.entrySet()) {
            if (entry.getValue() != null && !entry.getValue().isEmpty()) {
                sb.append(entry.getKey())
                        .append("=")
                        .append(urlEncode(entry.getValue().trim()))
                        .append("&");
            }
        }

        // Remove trailing ampersand
        String queryString = sb.substring(0, sb.length() - 1);

        // Append passphrase if provided and not empty
        if (passphrase != null && !passphrase.isBlank()) {
            queryString += "&passphrase=" + urlEncode(passphrase.trim());
        }

        return hashMd5(queryString);
    }

    private static String urlEncode(String value) {
        try {
            return URLEncoder.encode(value, StandardCharsets.UTF_8.toString())
                    .replace("+", "%20");
        } catch (UnsupportedEncodingException e) {
            throw new RuntimeException("UTF-8 encoding not supported", e);
        }
    }

    private static String hashMd5(String input) {
        try {
            MessageDigest md = MessageDigest.getInstance("MD5");
            byte[] messageDigest = md.digest(input.getBytes(StandardCharsets.UTF_8));
            StringBuilder sb = new StringBuilder();
            for (byte b : messageDigest) {
                sb.append(String.format("%02x", b));
            }
            return sb.toString();
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("MD5 algorithm not found", e);
        }
    }
}