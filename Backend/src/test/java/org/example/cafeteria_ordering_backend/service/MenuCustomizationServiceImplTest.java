package org.example.cafeteria_ordering_backend.service;

import org.example.cafeteria_ordering_backend.entity.MenuItemModifierGroup;
import org.example.cafeteria_ordering_backend.entity.MenuItems;
import org.example.cafeteria_ordering_backend.entity.Modifier;
import org.example.cafeteria_ordering_backend.entity.ModifierGroup;
import org.example.cafeteria_ordering_backend.event.WebSocketMessageEvent;
import org.example.cafeteria_ordering_backend.exception.BusinessException;
import org.example.cafeteria_ordering_backend.exception.ResourceNotFoundException;
import org.example.cafeteria_ordering_backend.repository.MenuItemRepository;
import org.example.cafeteria_ordering_backend.repository.ModifierGroupRepository;
import org.example.cafeteria_ordering_backend.repository.ModifierRepository;
import org.example.cafeteria_ordering_backend.service.implementation.MenuCustomizationServiceImpl;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.context.ApplicationEventPublisher;

import java.math.BigDecimal;
import java.util.HashSet;
import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class MenuCustomizationServiceImplTest {

    @Mock private ModifierGroupRepository groupRepository;
    @Mock private ModifierRepository modifierRepository;
    @Mock private MenuItemRepository menuItemRepository;
    @Mock private ApplicationEventPublisher eventPublisher;

    // Inject mocks into service being tested
    @InjectMocks
    private MenuCustomizationServiceImpl customizationService;

    private MenuItems mockMenuItem;
    private ModifierGroup mockModifierGroup;
    private Modifier mockModifier;

    @BeforeEach
    void setUp () {

        mockMenuItem = new MenuItems();
        mockMenuItem.setMenuItemId(1L);
        mockMenuItem.setName("Cappuccino");
        mockMenuItem.setMenuItemModifierGroups(new HashSet<>());

        mockModifierGroup = new ModifierGroup();
        mockModifierGroup.setId(10L);
        mockModifierGroup.setName("Milk Options");

        mockModifier = new Modifier();
        mockModifier.setId(100L);
        mockModifier.setName("Oat Milk");
        mockModifier.setPriceModifier(new BigDecimal("5.00"));
    }

    @Nested
    @DisplayName("Create Modifier Group Tests")
    class CreatedModifierGroupTests {

        @Test
        @DisplayName("Should successfully create modifier group and establish junction link with correct display order")
        void createModifierGroup_Success () {

            Long menuItemId = 1L;

            when(menuItemRepository.findById(menuItemId)).thenReturn(Optional.of(mockMenuItem));
            when(groupRepository.save(any(ModifierGroup.class))).thenReturn(mockModifierGroup);
            when(menuItemRepository.save(any(MenuItems.class))).thenReturn(mockMenuItem);

            ModifierGroup result = customizationService.createModifierGroup(menuItemId, mockModifierGroup);

            assertThat(result).isNotNull();
            assertThat(result.getId()).isEqualTo(10L);
            assertThat(result.getName()).isEqualTo("Milk Options");

            assertThat(mockMenuItem.getMenuItemModifierGroups()).hasSize(1);
            MenuItemModifierGroup link = mockMenuItem.getMenuItemModifierGroups().iterator().next();
            assertThat(link.getMenuItem()).isEqualTo(mockMenuItem);
            assertThat(link.getModifierGroup()).isEqualTo(mockModifierGroup);
            assertThat(link.getDisplayOrder()).isEqualTo(1);

            verify(menuItemRepository).findById(menuItemId);
            verify(groupRepository).save(mockModifierGroup);
            verify(menuItemRepository).save(mockMenuItem);
        }

        @Test
        @DisplayName("Should increment display order sequentially when adding subsequent modifier groups")
        void createModifierGroup_IncrementDisplayOrder () {

            Long menuItemId = 1L;

            MenuItemModifierGroup existingLink = new MenuItemModifierGroup();
            existingLink.setDisplayOrder(1);

            mockMenuItem.getMenuItemModifierGroups().add(existingLink);

            ModifierGroup secondGroup = new ModifierGroup();
            secondGroup.setId(11L);
            secondGroup.setName("Syrup Flavors");

            when(menuItemRepository.findById(menuItemId)).thenReturn(Optional.of(mockMenuItem));
            when(groupRepository.save(secondGroup)).thenReturn(secondGroup);

            customizationService.createModifierGroup(menuItemId, secondGroup);

            assertThat(mockMenuItem.getMenuItemModifierGroups()).hasSize(2);

            MenuItemModifierGroup secondLink = mockMenuItem.getMenuItemModifierGroups()
                    .stream()
                    .filter(link -> link.getDisplayOrder() == 2)
                    .findFirst()
                    .orElse(null);

            assertThat(secondLink).isNotNull();
            assertThat(secondLink.getDisplayOrder()).isEqualTo(2);
        }

        @Test
        @DisplayName("Should throw Runtime Exception when menu item ID not found")
        void createModifierGroup_MenuItemNotFound_ThrowsException () {

            Long invalidId = 999L;
            when(menuItemRepository.findById(invalidId)).thenReturn(Optional.empty());

            assertThatThrownBy(() -> customizationService.createModifierGroup(invalidId, mockModifierGroup))
                    .isInstanceOf(RuntimeException.class)
                    .hasMessageContaining("Menu item not found with id: " + invalidId);

            verify(groupRepository, never()).save(any());
            verify(menuItemRepository, never()).save(any());
        }
    }

    @Nested
    @DisplayName("Create Modifier Tests")
    class CreatedModifierTests {

        @Test
        @DisplayName("Should successfully attach modifier to group and save")
        void createModifier_Success () {

            Long groupId = 10L;

            when(groupRepository.findById(groupId)).thenReturn(Optional.of(mockModifierGroup));
            when(modifierRepository.save(mockModifier)).thenReturn(mockModifier);

            Modifier result = customizationService.createModifier(groupId, mockModifier);

            assertThat(result).isNotNull();
            assertThat(result.getModifierGroup()).isEqualTo(mockModifierGroup);
            assertThat(result.getName()).isEqualTo("Oat Milk");

            verify(groupRepository).findById(groupId);
            verify(modifierRepository).save(mockModifier);
        }

        @Test
        @DisplayName("Should throw Runtime Exception when group ID is not found")
        void createModifier_GroupNotFound_ThrowsException () {

            Long invalidGroupId = 999L;

            when(groupRepository.findById(invalidGroupId)).thenReturn(Optional.empty());

            assertThatThrownBy(() -> customizationService.createModifier(invalidGroupId, mockModifier))
                    .isInstanceOf(RuntimeException.class)
                    .hasMessageContaining("Modifier group not found with id: " + invalidGroupId);

            verify(modifierRepository, never()).save(any());
        }
    }

    @Nested
    @DisplayName("Get customization by menu item tests")
    class GetCustomizationByMenuItemTests {

        @Test
        @DisplayName("Should return modifier group sorted by display order")
        void getCustomizationsByMenuItem_ReturnsSortedGroups () {

            Long menuItemId = 1L;

            ModifierGroup groupA = new ModifierGroup();
            groupA.setId(10L);
            groupA.setName("Size");

            ModifierGroup groupB = new ModifierGroup();
            groupB.setId(11L);
            groupB.setName("Syrups");

            MenuItemModifierGroup link1 = new MenuItemModifierGroup();
            link1.setModifierGroup(groupB);
            link1.setDisplayOrder(2);

            MenuItemModifierGroup link2 = new MenuItemModifierGroup();
            link2.setModifierGroup(groupA);
            link2.setDisplayOrder(1);

            mockMenuItem.getMenuItemModifierGroups().add(link1);
            mockMenuItem.getMenuItemModifierGroups().add(link2);

            when(menuItemRepository.findById(menuItemId)).thenReturn(Optional.of(mockMenuItem));

            List<ModifierGroup> results = customizationService.getCustomizationsByMenuItem(menuItemId);

            assertThat(results).hasSize(2);
            assertThat(results.get(0)).isEqualTo(groupA);
            assertThat(results.get(1)).isEqualTo(groupB);

            verify(menuItemRepository).findById(menuItemId);
        }

        @Test
        @DisplayName("Should return empty list when menu item has no customizations attached")
        void getCustomizationsByMenuItem_ReturnsEmptyList () {

            Long menuItemId = 1L;
            when(menuItemRepository.findById(menuItemId)).thenReturn(Optional.of(mockMenuItem));

            List<ModifierGroup> results = customizationService.getCustomizationsByMenuItem(menuItemId);
            assertThat(results).isEmpty();
        }

        @Test
        @DisplayName("Should throw RuntimeException when menu item ID is not found")
        void getCustomizationsByMenuItem_NotFound_ThrowsException () {

            Long invalidId = 999L;
            when(menuItemRepository.findById(invalidId)).thenReturn(Optional.empty());

            assertThatThrownBy(() -> customizationService.getCustomizationsByMenuItem(invalidId))
                    .isInstanceOf(RuntimeException.class)
                    .hasMessageContaining("Menu item not found with id: " + invalidId);
        }
    }

    @Nested
    @DisplayName("Update Modifier Group Tests")
    class UpdateModifierGroupTests {

        @Test
        @DisplayName("Should successfully update modifier group details and publish event")
        void updateModifierGroup_Success () {

            ModifierGroup updateInfo = new ModifierGroup();
            updateInfo.setName("Updated Milk Options");
            updateInfo.setMinSelections(1);
            updateInfo.setMaxSelections(2);
            updateInfo.setAvailable(false);
            updateInfo.setIsRequired(true);

            when(groupRepository.findById(10L)).thenReturn(Optional.of(mockModifierGroup));
            when(groupRepository.save(any(ModifierGroup.class))).thenAnswer(invocation -> invocation.getArgument(0));

            ModifierGroup updated = customizationService.updateModifierGroup(10L, updateInfo);

            assertThat(updated).isNotNull();
            assertThat(updated.getName()).isEqualTo("Updated Milk Options");
            assertThat(updated.getMinSelections()).isEqualTo(1);
            assertThat(updated.getMaxSelections()).isEqualTo(2);
            assertThat(updated.getAvailable()).isFalse();
            assertThat(updated.getIsRequired()).isTrue();

            verify(groupRepository).findById(10L);
            verify(groupRepository).save(mockModifierGroup);

            // Verify WebSocket event
            ArgumentCaptor<WebSocketMessageEvent<?>> eventCaptor = ArgumentCaptor.forClass(WebSocketMessageEvent.class);
            verify(eventPublisher).publishEvent(eventCaptor.capture());
            assertThat(eventCaptor.getValue().getAction()).isEqualTo("UPDATE");
            assertThat(eventCaptor.getValue().getType()).isEqualTo("MODIFIER_GROUP");
        }

        @Test
        @DisplayName("Should throw ResourceNotFoundException when modifier group ID for update is not found")
        void updateModifierGroup_NotFound_ThrowsException () {

            ModifierGroup updateInfo = new ModifierGroup();
            when(groupRepository.findById(999L)).thenReturn(Optional.empty());

            assertThatThrownBy(() -> customizationService.updateModifierGroup(999L, updateInfo))
                    .isInstanceOf(ResourceNotFoundException.class)
                    .hasMessageContaining("Modifier group not found with ID: 999");

            verify(groupRepository).findById(999L);
            verify(groupRepository, never()).save(any());
            verify(eventPublisher, never()).publishEvent(any());
        }
    }

    @Nested
    @DisplayName("Delete Modifier Group Tests")
    class DeleteModifierGroupTests {

        @Test
        @DisplayName("Should successfully delete modifier group by ID")
        void deleteModifierGroup_Success () {

            when(groupRepository.findById(10L)).thenReturn(Optional.of(mockModifierGroup));
            doNothing().when(groupRepository).delete(mockModifierGroup);

            org.junit.jupiter.api.Assertions.assertDoesNotThrow(() -> customizationService.deleteModifierGroup(10L));

            verify(groupRepository).findById(10L);
            verify(groupRepository).delete(mockModifierGroup);
        }

        @Test
        @DisplayName("Should throw BusinessException when deleting modifier group tied to past orders")
        void deleteModifierGroup_ForeignKeyViolation_ThrowsException () {

            when(groupRepository.findById(10L)).thenReturn(Optional.of(mockModifierGroup));
            doThrow(new org.springframework.dao.DataIntegrityViolationException("Foreign key violation"))
                    .when(groupRepository).delete(mockModifierGroup);

            assertThatThrownBy(() -> customizationService.deleteModifierGroup(10L))
                    .isInstanceOf(BusinessException.class)
                    .hasMessageContaining("Cannot delete this modifier group because one or more of its options have been purchased");

            verify(groupRepository).findById(10L);
            verify(groupRepository).delete(mockModifierGroup);
        }
    }

    @Nested
    @DisplayName("Update Modifier Tests")
    class UpdateModifierTests {

        @Test
        @DisplayName("Should successfully update modifier details and publish event")
        void updateModifier_Success () {

            Modifier updateInfo = new Modifier();
            updateInfo.setName("Almond Milk");
            updateInfo.setPriceModifier(new BigDecimal("7.50"));
            updateInfo.setAvailable(false);

            when(modifierRepository.findById(100L)).thenReturn(Optional.of(mockModifier));
            when(modifierRepository.save(any(Modifier.class))).thenAnswer(invocation ->
                    invocation.getArgument(0));

            Modifier updated = customizationService.updateModifier(100L, updateInfo);

            assertThat(updated).isNotNull();
            assertThat(updated.getName()).isEqualTo("Almond Milk");
            assertThat(updated.getPriceModifier()).isEqualByComparingTo(new BigDecimal("7.50"));
            assertThat(updated.getAvailable()).isFalse();

            verify(modifierRepository).findById(100L);
            verify(modifierRepository).save(mockModifier);

            // Verify WebSocket event
            ArgumentCaptor<WebSocketMessageEvent<?>> eventCaptor = ArgumentCaptor.forClass(WebSocketMessageEvent.class);
            verify(eventPublisher).publishEvent(eventCaptor.capture());
            assertThat(eventCaptor.getValue().getAction()).isEqualTo("UPDATE");
            assertThat(eventCaptor.getValue().getType()).isEqualTo("MODIFIER");
        }

        @Test
        @DisplayName("Should throw ResourceNotFoundException when modifier ID for update is not found")
        void updateModifier_NotFound_ThrowsException () {

            Modifier updateInfo = new Modifier();
            when(modifierRepository.findById(999L)).thenReturn(Optional.empty());

            assertThatThrownBy(() -> customizationService.updateModifier(999L, updateInfo))
                    .isInstanceOf(ResourceNotFoundException.class)
                    .hasMessageContaining("Modifier not found with ID: 999");

            verify(modifierRepository).findById(999L);
            verify(modifierRepository, never()).save(any());
            verify(eventPublisher, never()).publishEvent(any());
        }
    }

    @Nested
    @DisplayName("Delete Modifier Tests")
    class DeleteModifierTests {

        @Test
        @DisplayName("Should successfully delete modifier by ID")
        void deleteModifier_Success () {

            when(modifierRepository.findById(100L)).thenReturn(Optional.of(mockModifier));
            doNothing().when(modifierRepository).delete(mockModifier);

            org.junit.jupiter.api.Assertions.assertDoesNotThrow(() -> customizationService.deleteModifier(100L));

            verify(modifierRepository).findById(100L);
            verify(modifierRepository).delete(mockModifier);
        }

        @Test
        @DisplayName("Should throw ResponseStatusException when deleting modifier tied to past orders")
        void deleteModifier_ForeignKeyViolation_ThrowsException () {

            when(modifierRepository.findById(100L)).thenReturn(Optional.of(mockModifier));
            doThrow(new org.springframework.dao.DataIntegrityViolationException("Foreign key violation"))
                    .when(modifierRepository).delete(mockModifier);

            assertThatThrownBy(() -> customizationService.deleteModifier(100L))
                    .isInstanceOf(org.springframework.web.server.ResponseStatusException.class)
                    .hasMessageContaining("Cannot delete this modifier because it has been purchased");

            verify(modifierRepository).findById(100L);
            verify(modifierRepository).delete(mockModifier);
        }
    }
}