package org.example.cafeteria_ordering_backend.component;

import org.example.cafeteria_ordering_backend.dto.requests.OrderRequestDTO;
import org.example.cafeteria_ordering_backend.entity.*;
import org.example.cafeteria_ordering_backend.exception.ResourceNotFoundException;
import org.example.cafeteria_ordering_backend.exception.ResourceUnavailableException;
import org.example.cafeteria_ordering_backend.repository.MenuItemRepository;
import org.example.cafeteria_ordering_backend.repository.ModifierRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.CsvSource;
import org.junit.jupiter.params.provider.ValueSource;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.Mockito.when;

// Mockito is used to isolate it from DB
@ExtendWith(MockitoExtension.class)
class OrderItemCalculatorTest {

    @Mock
    private MenuItemRepository menuItemRepository;

    @Mock
    private ModifierRepository modifierRepository;

    @InjectMocks
    private OrderItemCalculator orderItemCalculator;

    private MenuItems mockMenuItem;
    private Modifier mockModifier;
    private ModifierGroup mockModifierGroup;
    private Order mockOrder;

    // Initialize test data before each test
    @BeforeEach
    void setUp () {

        mockModifierGroup = new ModifierGroup();
        mockModifierGroup.setId(1L);
        mockModifierGroup.setName("Size / Add-ons");
        mockModifierGroup.setMinSelections(1);
        mockModifierGroup.setMaxSelections(2);
        mockModifierGroup.setIsRequired(true);
        mockModifierGroup.setAvailable(true);

        mockModifier = new Modifier();
        mockModifier.setId(100L);
        mockModifier.setName("Extra Shot");
        mockModifier.setPriceModifier(new BigDecimal("5.00"));
        mockModifier.setAvailable(true);
        mockModifier.setModifierGroup(mockModifierGroup);

        mockMenuItem = new MenuItems();
        mockMenuItem.setMenuItemId(10L);
        mockMenuItem.setName("Espresso");
        mockMenuItem.setPrice(new BigDecimal("25.00"));
        mockMenuItem.setAvailable(true);

        MenuItemModifierGroup menuItemModifierGroup = new MenuItemModifierGroup();
        menuItemModifierGroup.setMenuItem(mockMenuItem);
        menuItemModifierGroup.setModifierGroup(mockModifierGroup);

        mockMenuItem.setMenuItemModifierGroups(new HashSet<>(Set.of(menuItemModifierGroup)));

        mockOrder = new Order();
        mockOrder.setOrderId(50L);
    }

    // Tests correct price calculations with no modifiers.
    @ParameterizedTest(name = "Quantity {0} without modifiers -> total {1}")
    @CsvSource({
            "2, 50.00, 50.00",
            "1, 25.00, 25.00"
    })
    void calculateAndBuildItems_Success_NoModifiers (int quantity, String expectedTotal, String expectedSubtotal) {

        mockMenuItem.setMenuItemModifierGroups(new HashSet<>());

        OrderRequestDTO.OrderItemRequest itemRequest = new OrderRequestDTO.OrderItemRequest();
        itemRequest.setMenuItemId(10L);
        itemRequest.setQuantity(quantity);

        when(menuItemRepository.findAllById(Set.of(10L))).thenReturn(List.of(mockMenuItem));
        OrderItemCalculator.CalculationResult result = orderItemCalculator.calculateAndBuildItems(
                List.of(itemRequest), mockOrder);

        assertThat(result).isNotNull();
        assertThat(result.totalPrice()).isEqualByComparingTo(expectedTotal);
        assertThat(result.orderItems()).hasSize(1);
        assertThat(result.orderItems().getFirst().getQuantity()).isEqualTo(quantity);
        assertThat(result.orderItems().getFirst().calculateSubtotal()).isEqualByComparingTo(expectedSubtotal);
    }

    // Ensure base and modifier price are multiplied correctly
    @Test
    @DisplayName("Should multiply the base price and modifier price by quantity")
    void calculateAndBuildItems_WithModifier_MultipliesByQuantity () {

        OrderRequestDTO.OrderItemRequest itemRequest = new OrderRequestDTO.OrderItemRequest();
        itemRequest.setMenuItemId(10L);
        itemRequest.setQuantity(3);
        itemRequest.setModifierIds(List.of(100L));

        when(menuItemRepository.findAllById(Set.of(10L))).thenReturn(List.of(mockMenuItem));
        when(modifierRepository.findAllById(Set.of(100L))).thenReturn(List.of(mockModifier));

        OrderItemCalculator.CalculationResult result = orderItemCalculator.calculateAndBuildItems(List.of(itemRequest), mockOrder);

        assertThat(result.totalPrice()).isEqualByComparingTo("90.00");
        assertThat(result.orderItems()).hasSize(1);
        OrderItem orderItem = result.orderItems().getFirst();
        assertThat(orderItem.getQuantity()).isEqualTo(3);
        assertThat(orderItem.calculateSubtotal()).isEqualByComparingTo("90.00");
    }

    // Ensures null quantity is rejected
    @Test
    @DisplayName("Should reject a null quantity")
    void calculateAndBuildItems_NullQuantity_ThrowsException () {

        OrderRequestDTO.OrderItemRequest itemRequest = new OrderRequestDTO.OrderItemRequest();
        itemRequest.setMenuItemId(10L);
        itemRequest.setQuantity(null);

        assertThatThrownBy(() -> orderItemCalculator.calculateAndBuildItems(List.of(itemRequest), mockOrder))
                .isInstanceOf(ResourceUnavailableException.class)
                .hasMessageContaining("Order quantity must be at least 1");
    }

    // Tests invalid quantities
    @ParameterizedTest
    @ValueSource(ints = {0, -2})
    @DisplayName("Should reject zero or negative quantities")
    void calculateAndBuildItems_ZeroOrNegativeQuantity_ThrowsException (int quantity) {

        OrderRequestDTO.OrderItemRequest itemRequest = new OrderRequestDTO.OrderItemRequest();
        itemRequest.setMenuItemId(10L);
        itemRequest.setQuantity(quantity);

        assertThatThrownBy(() -> orderItemCalculator.calculateAndBuildItems(List.of(itemRequest), mockOrder))
                .isInstanceOf(ResourceUnavailableException.class)
                .hasMessageContaining("Order quantity must be at least 1");
    }

    // Ensure calc reports error when menuItem cannot be found in repository
    @Test
    @DisplayName("Should throw ResourceNotFoundException when menu item does not exist")
    void calculateAndBuildItems_MenuItemNotFound_ThrowsException () {

        OrderRequestDTO.OrderItemRequest itemRequest = new OrderRequestDTO.OrderItemRequest();
        itemRequest.setMenuItemId(99L);
        itemRequest.setQuantity(1);

        when(menuItemRepository.findAllById(Set.of(99L))).thenReturn(List.of());

        assertThatThrownBy(() -> orderItemCalculator.calculateAndBuildItems(List.of(itemRequest), mockOrder))
                .isInstanceOf(ResourceNotFoundException.class)
                .hasMessageContaining("Menu item not found with ID: 99");
    }

    // Ensure unavailable menu item cannot be ordered
    @Test
    @DisplayName("Should throw ResourceUnavailableException when menu item is unavailable")
    void calculateAndBuildItems_MenuItemOutOfStock_ThrowsException () {

        mockMenuItem.setAvailable(false);
        OrderRequestDTO.OrderItemRequest itemRequest = new OrderRequestDTO.OrderItemRequest();
        itemRequest.setMenuItemId(10L);
        itemRequest.setQuantity(1);

        when(menuItemRepository.findAllById(Set.of(10L))).thenReturn(List.of(mockMenuItem));

        assertThatThrownBy(() -> orderItemCalculator.calculateAndBuildItems(List.of(itemRequest), mockOrder))
                .isInstanceOf(ResourceUnavailableException.class)
                .hasMessageContaining("currently out of stock");
    }

    // Ensures request modifier should exist, it checks to see the correct response is provided
    @Test
    @DisplayName("Should throw ResourceNotFoundException when modifier does not exist")
    void calculateAndBuildItems_ModifierNotFound_ThrowsException () {

        OrderRequestDTO.OrderItemRequest itemRequest = new OrderRequestDTO.OrderItemRequest();
        itemRequest.setMenuItemId(10L);
        itemRequest.setQuantity(1);
        itemRequest.setModifierIds(List.of(999L));

        when(menuItemRepository.findAllById(Set.of(10L))).thenReturn(List.of(mockMenuItem));
        when(modifierRepository.findAllById(Set.of(999L))).thenReturn(List.of());

        assertThatThrownBy(() -> orderItemCalculator.calculateAndBuildItems(List.of(itemRequest), mockOrder))
                .isInstanceOf(ResourceNotFoundException.class)
                .hasMessageContaining("Modifier not found with ID: 999");
    }

    // Verify existing modifier cannot be selected when availability is set to false
    @Test
    @DisplayName("Should throw ResourceUnavailableException when modifier is unavailable")
    void calculateAndBuildItems_ModifierUnavailable_ThrowsException () {

        mockModifier.setAvailable(false);

        OrderRequestDTO.OrderItemRequest itemRequest = new OrderRequestDTO.OrderItemRequest();
        itemRequest.setMenuItemId(10L);
        itemRequest.setQuantity(1);
        itemRequest.setModifierIds(List.of(100L));

        when(menuItemRepository.findAllById(Set.of(10L))).thenReturn(List.of(mockMenuItem));
        when(modifierRepository.findAllById(Set.of(100L))).thenReturn(List.of(mockModifier));

        assertThatThrownBy(() -> orderItemCalculator.calculateAndBuildItems(List.of(itemRequest), mockOrder))
                .isInstanceOf(ResourceUnavailableException.class)
                .hasMessageContaining("Modifier 'Extra Shot' is currently unavailable");
    }

    // Verify modifier groups meet minimum selection requirement
    @Test
    @DisplayName("Should reject an order that does not meet the required modifier group minimum")
    void calculateAndBuildItems_BelowMinimumSelections_ThrowsException () {

        OrderRequestDTO.OrderItemRequest itemRequest = new OrderRequestDTO.OrderItemRequest();
        itemRequest.setMenuItemId(10L);
        itemRequest.setQuantity(1);
        itemRequest.setModifierIds(List.of());

        when(menuItemRepository.findAllById(Set.of(10L))).thenReturn(List.of(mockMenuItem));

        assertThatThrownBy(() -> orderItemCalculator.calculateAndBuildItems(List.of(itemRequest), mockOrder))
                .isInstanceOf(ResourceUnavailableException.class)
                .hasMessageContaining("Modifier group 'Size / Add-ons' requires at least 1 selection(s).");
    }

    // Verify num of selected modifiers cannot exceed maximum allowed for group.
    // Group used in this test should only allow 2
    @Test
    @DisplayName("Should reject selections exceeding the modifier group maximum")
    void calculateAndBuildItems_ExceedsMaximumSelections_ThrowsException () {

        Modifier mockModifier2 = new Modifier();
        mockModifier2.setId(101L);
        mockModifier2.setName("Syrup Pump");
        mockModifier2.setPriceModifier(new BigDecimal("3.00"));
        mockModifier2.setAvailable(true);
        mockModifier2.setModifierGroup(mockModifierGroup);

        Modifier mockModifier3 = new Modifier();
        mockModifier3.setId(102L);
        mockModifier3.setName("Soy Milk");
        mockModifier3.setPriceModifier(new BigDecimal("4.00"));
        mockModifier3.setAvailable(true);
        mockModifier3.setModifierGroup(mockModifierGroup);

        OrderRequestDTO.OrderItemRequest itemRequest = new OrderRequestDTO.OrderItemRequest();
        itemRequest.setMenuItemId(10L);
        itemRequest.setQuantity(1);
        itemRequest.setModifierIds(List.of(100L, 101L, 102L));

        when(menuItemRepository.findAllById(Set.of(10L))).thenReturn(List.of(mockMenuItem));
        when(modifierRepository.findAllById(Set.of(100L, 101L, 102L))).thenReturn(List.of(mockModifier, mockModifier2, mockModifier3));

        assertThatThrownBy(() -> orderItemCalculator.calculateAndBuildItems(List.of(itemRequest), mockOrder))
                .isInstanceOf(ResourceUnavailableException.class)
                .hasMessageContaining("Modifier group 'Size / Add-ons' allows a maximum of 2 selection(s).");
    }

    // Test null prices are treated as zero
    @Test
    @DisplayName("Should default null item and modifier prices to zero")
    void calculateAndBuildItems_NullPrices_DefaultsToZero () {

        mockMenuItem.setPrice(null);
        mockModifier.setPriceModifier(null);

        OrderRequestDTO.OrderItemRequest itemRequest = new OrderRequestDTO.OrderItemRequest();
        itemRequest.setMenuItemId(10L);
        itemRequest.setQuantity(3);
        itemRequest.setModifierIds(List.of(100L));

        when(menuItemRepository.findAllById(Set.of(10L))).thenReturn(List.of(mockMenuItem));
        when(modifierRepository.findAllById(Set.of(100L))).thenReturn(List.of(mockModifier));

        OrderItemCalculator.CalculationResult result = orderItemCalculator.calculateAndBuildItems(List.of(itemRequest), mockOrder);

        assertThat(result.totalPrice()).isEqualByComparingTo(BigDecimal.ZERO);
        assertThat(result.orderItems().getFirst().getQuantity()).isEqualTo(3);
    }
}