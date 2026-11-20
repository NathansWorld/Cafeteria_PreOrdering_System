package org.example.cafeteria_ordering_backend.event;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public class WebSocketMessageEvent<T> {

    private final String destination;
    // "CREATE", "UPDATE", "DELETE"
    private final String action;
    // "CATEGORY", "MENU_ITEM", "ORDER"
    private final String type;
    private final T data;

}