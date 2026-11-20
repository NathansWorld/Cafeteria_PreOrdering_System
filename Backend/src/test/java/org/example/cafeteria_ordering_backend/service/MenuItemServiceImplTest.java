package org.example.cafeteria_ordering_backend.service;

import org.example.cafeteria_ordering_backend.entity.Category;
import org.example.cafeteria_ordering_backend.entity.MenuItems;
import org.example.cafeteria_ordering_backend.event.WebSocketMessageEvent;
import org.example.cafeteria_ordering_backend.exception.ResourceNotFoundException;
import org.example.cafeteria_ordering_backend.repository.CategoryRepository;
import org.example.cafeteria_ordering_backend.repository.MenuItemRepository;
import org.example.cafeteria_ordering_backend.service.implementation.MenuItemServiceImpl;
import org.example.cafeteria_ordering_backend.service.interfaces.ImageStorageService;
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
import org.springframework.mock.web.MockMultipartFile;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.Collections;
import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class MenuItemServiceImplTest {

    @Mock
    private MenuItemRepository menuItemRepository;

    @Mock
    private CategoryRepository categoryRepository;

    @Mock private ImageStorageService imageStorageService;
    @Mock private ApplicationEventPublisher eventPublisher;

    // Injecting mocks into service being tested
    @InjectMocks
    private MenuItemServiceImpl menuItemService;

    private Category mockCategory;
    private MenuItems mockMenuItem;

    // Initialize reusable category/ item for testing
    @BeforeEach
    void setUp () {

        mockCategory = new Category();
        mockCategory.setCategoryId(1L);
        mockCategory.setCategoryName("Beverages");

        mockMenuItem = new MenuItems();
        mockMenuItem.setMenuItemId(100L);
        mockMenuItem.setName("Cappuccino");
        mockMenuItem.setPrice(new BigDecimal("35.00"));
        mockMenuItem.setDisplayOrder(1);
        mockMenuItem.setAvailable(true);
    }

    @Nested
    @DisplayName("Create Menu Item Tests")
    class CreateMenuItemTests {

        @Test
        @DisplayName("Should successfully create a menu item with default vals when category exists")
        void createMenuItem_Success () {

            Long categoryId = 1L;

            MenuItems inputMenuItem = new MenuItems();
            inputMenuItem.setName("Cappuccino");
            inputMenuItem.setPrice(new BigDecimal("35.00"));

            when(categoryRepository.findById(categoryId)).thenReturn(Optional.of(mockCategory));
            when(menuItemRepository.save(any(MenuItems.class)))
                    .thenAnswer(invocation -> {
                        MenuItems itemToSave = invocation.getArgument(0);
                        itemToSave.setMenuItemId(100L);
                        itemToSave.setCreatedAt(LocalDateTime.now());
                        itemToSave.setUpdatedAt(LocalDateTime.now());
                        return itemToSave;
                    });

            MenuItems result = menuItemService.createMenuItem(categoryId, inputMenuItem);

            assertThat(result).isNotNull();
            assertThat(result.getMenuItemId()).isEqualTo(100L);
            assertThat(result.getCategory()).isEqualTo(mockCategory);
            assertThat(result.getAvailable()).isTrue();
            assertThat(result.getDisplayOrder()).isEqualTo(0);
            assertThat(result.getCreatedAt()).isNotNull();
            assertThat(result.getUpdatedAt()).isNotNull();

            verify(categoryRepository).findById(categoryId);
            verify(menuItemRepository).save(inputMenuItem);

            // Verify WebSocket event
            ArgumentCaptor<WebSocketMessageEvent<?>> eventCaptor = ArgumentCaptor.forClass(WebSocketMessageEvent.class);
            verify(eventPublisher).publishEvent(eventCaptor.capture());
            assertThat(eventCaptor.getValue().getAction()).isEqualTo("CREATE");
            assertThat(eventCaptor.getValue().getType()).isEqualTo("MENU-ITEM");
        }

        @Test
        @DisplayName("Should preserve displayOrder if provided when creating item")
        void createMenuItem_PreservesDisplayOrder () {

            Long categoryId = 1L;
            mockMenuItem.setDisplayOrder(5);

            when(categoryRepository.findById(categoryId)).thenReturn(Optional.of(mockCategory));
            when(menuItemRepository.save(any(MenuItems.class)))
                    .thenAnswer(invocation -> {
                        MenuItems itemToSave = invocation.getArgument(0);
                        itemToSave.setUpdatedAt(LocalDateTime.now());
                        return itemToSave;
                    });

            MenuItems result = menuItemService.createMenuItem(categoryId, mockMenuItem);

            assertThat(result.getDisplayOrder()).isEqualTo(5);
            verify(menuItemRepository).save(mockMenuItem);
            verify(eventPublisher).publishEvent(any(WebSocketMessageEvent.class));
        }

        @Test
        @DisplayName("Should throw ResourceNotFoundException when category ID is not found")
        void createMenuItem_CategoryNotFound_ThrowsException () {

            Long invalidCategoryId = 999L;

            when(categoryRepository.findById(invalidCategoryId)).thenReturn(Optional.empty());

            assertThatThrownBy(() -> menuItemService.createMenuItem(invalidCategoryId, mockMenuItem))
                    .isInstanceOf(ResourceNotFoundException.class)
                    .hasMessageContaining("Category not found with id: " + invalidCategoryId);

            verify(categoryRepository).findById(invalidCategoryId);
            verify(menuItemRepository, never()).save(any());
            verify(eventPublisher, never()).publishEvent(any());
        }
    }

    @Nested
    @DisplayName("Update Menu Item Tests")
    class UpdateMenuItemTests {

        @Test
        @DisplayName("Should successfully update menu item details")
        void updateMenuItem_Success () {

            Long menuItemId = 100L;
            MenuItems details = new MenuItems();
            details.setName("Espresso");
            details.setDescription("Strong black coffee");
            details.setPrice(new BigDecimal("30.00"));
            details.setAvailable(false);
            details.setDisplayOrder(2);

            when(menuItemRepository.findById(menuItemId)).thenReturn(Optional.of(mockMenuItem));
            when(menuItemRepository.save(any(MenuItems.class)))
                    .thenAnswer(invocation -> invocation.getArgument(0));

            MenuItems result = menuItemService.updateMenuItem(menuItemId, details);

            assertThat(result).isNotNull();
            assertThat(result.getName()).isEqualTo("Espresso");
            assertThat(result.getDescription()).isEqualTo("Strong black coffee");
            assertThat(result.getPrice()).isEqualByComparingTo(new BigDecimal("30.00"));
            assertThat(result.getAvailable()).isFalse();
            assertThat(result.getDisplayOrder()).isEqualTo(2);

            verify(menuItemRepository).findById(menuItemId);
            verify(menuItemRepository).save(mockMenuItem);

            // Verify WebSocket event
            ArgumentCaptor<WebSocketMessageEvent<?>> eventCaptor = ArgumentCaptor.forClass(WebSocketMessageEvent.class);
            verify(eventPublisher).publishEvent(eventCaptor.capture());
            assertThat(eventCaptor.getValue().getAction()).isEqualTo("UPDATE");
            assertThat(eventCaptor.getValue().getType()).isEqualTo("MENU-ITEM");
        }

        @Test
        @DisplayName("Should update category when category ID is provided in update details")
        void updateMenuItem_WithNewCategory_Success () {

            Long menuItemId = 100L;

            Category newCategory = new Category();
            newCategory.setCategoryId(2L);
            newCategory.setCategoryName("Hot Drinks");

            MenuItems details = new MenuItems();
            details.setName("Cappuccino");
            details.setPrice(new BigDecimal("35.00"));
            details.setCategory(newCategory);

            when(menuItemRepository.findById(menuItemId)).thenReturn(Optional.of(mockMenuItem));
            when(categoryRepository.findById(2L)).thenReturn(Optional.of(newCategory));
            when(menuItemRepository.save(any(MenuItems.class)))
                    .thenAnswer(invocation -> invocation.getArgument(0));

            MenuItems result = menuItemService.updateMenuItem(menuItemId, details);

            assertThat(result.getCategory()).isEqualTo(newCategory);

            verify(categoryRepository).findById(2L);
            verify(menuItemRepository).save(mockMenuItem);
            verify(eventPublisher).publishEvent(any(WebSocketMessageEvent.class));
        }

        @Test
        @DisplayName("Should throw ResourceNotFoundException when updating non-existent menu item")
        void updateMenuItem_NotFound_ThrowsException () {

            Long invalidId = 999L;
            MenuItems details = new MenuItems();

            when(menuItemRepository.findById(invalidId)).thenReturn(Optional.empty());

            assertThatThrownBy(() -> menuItemService.updateMenuItem(invalidId, details))
                    .isInstanceOf(ResourceNotFoundException.class)
                    .hasMessageContaining("Menu item not found with id: " + invalidId);

            verify(menuItemRepository).findById(invalidId);
            verify(menuItemRepository, never()).save(any());
            verify(eventPublisher, never()).publishEvent(any());
        }
    }

    @Nested
    @DisplayName("Delete Menu Item Tests")
    class DeleteMenuItemTests {

        @Test
        @DisplayName("Should successfully delete menu item and cleanup image if present")
        void deleteMenuItem_Success_WithImage () {

            Long menuItemId = 100L;
            mockMenuItem.setImagePath("http://localhost:8080/uploads/menu-items/test.jpg");

            when(menuItemRepository.findById(menuItemId)).thenReturn(Optional.of(mockMenuItem));
            doNothing().when(imageStorageService).deleteImage(anyString());
            doNothing().when(menuItemRepository).delete(any(MenuItems.class));

            menuItemService.deleteMenuItem(menuItemId);

            verify(menuItemRepository).findById(menuItemId);
            verify(imageStorageService).deleteImage("http://localhost:8080/uploads/menu-items/test.jpg");
            verify(menuItemRepository).delete(mockMenuItem);

            // Verify WebSocket event
            ArgumentCaptor<WebSocketMessageEvent<?>> eventCaptor = ArgumentCaptor.forClass(WebSocketMessageEvent.class);
            verify(eventPublisher).publishEvent(eventCaptor.capture());
            assertThat(eventCaptor.getValue().getAction()).isEqualTo("DELETE");
            assertThat(eventCaptor.getValue().getType()).isEqualTo("MENU-ITEM");
        }

        @Test
        @DisplayName("Should successfully delete menu item without image cleanup when no image exists")
        void deleteMenuItem_Success_WithoutImage () {

            Long menuItemId = 100L;
            mockMenuItem.setImagePath(null);

            when(menuItemRepository.findById(menuItemId)).thenReturn(Optional.of(mockMenuItem));
            doNothing().when(menuItemRepository).delete(any(MenuItems.class));

            menuItemService.deleteMenuItem(menuItemId);

            verify(menuItemRepository).findById(menuItemId);
            verify(imageStorageService, never()).deleteImage(any());
            verify(menuItemRepository).delete(mockMenuItem);
            verify(eventPublisher).publishEvent(any(WebSocketMessageEvent.class));
        }

        @Test
        @DisplayName("Should throw ResourceNotFoundException when deleting non-existent menu item")
        void deleteMenuItem_NotFound_ThrowsException () {

            Long invalidId = 999L;

            when(menuItemRepository.findById(invalidId)).thenReturn(Optional.empty());

            assertThatThrownBy(() -> menuItemService.deleteMenuItem(invalidId))
                    .isInstanceOf(ResourceNotFoundException.class)
                    .hasMessageContaining("Menu item not found with id: " + invalidId);

            verify(menuItemRepository).findById(invalidId);
            verify(menuItemRepository, never()).delete(any());
            verify(eventPublisher, never()).publishEvent(any());
        }
    }

    @Nested
    @DisplayName("Get menu items by category tests")
    class GetMenuItemsByCategoryTests {

        @Test
        @DisplayName("Should return available menu items sorted by display order")
        void getMenuItemsByCategory_ReturnsList () {

            Long categoryId = 1L;

            when(menuItemRepository
                    .findByCategoryCategoryIdAndAvailableTrueOrderByDisplayOrderAsc(categoryId))
                    .thenReturn(List.of(mockMenuItem));

            List<MenuItems> results = menuItemService.getMenuItemsByCategory(categoryId);

            assertThat(results).hasSize(1);
            assertThat(results.getFirst().getName()).isEqualTo("Cappuccino");

            verify(menuItemRepository).findByCategoryCategoryIdAndAvailableTrueOrderByDisplayOrderAsc(categoryId);
            verifyNoInteractions(eventPublisher);
        }

        @Test
        @DisplayName("Should return empty list when no active items exist in category")
        void getMenuItemsByCategory_ReturnsEmptyList () {

            Long categoryId = 1L;

            when(menuItemRepository
                    .findByCategoryCategoryIdAndAvailableTrueOrderByDisplayOrderAsc(categoryId))
                    .thenReturn(Collections.emptyList());

            List<MenuItems> results = menuItemService.getMenuItemsByCategory(categoryId);

            assertThat(results).isEmpty();
            verify(menuItemRepository).findByCategoryCategoryIdAndAvailableTrueOrderByDisplayOrderAsc(categoryId);
            verifyNoInteractions(eventPublisher);
        }
    }

    @Nested
    @DisplayName("Get All Menu Items Tests (Staff/Admin)")
    class GetAllMenuItemsTests {

        @Test
        @DisplayName("Should return all menu items including inactive ones")
        void getAllMenuItems_ReturnsList () {

            MenuItems inactiveItem = new MenuItems();
            inactiveItem.setMenuItemId(101L);
            inactiveItem.setName("Latte");
            inactiveItem.setAvailable(false);

            when(menuItemRepository.findAll()).thenReturn(List.of(mockMenuItem, inactiveItem));

            List<MenuItems> results = menuItemService.getAllMenuItems();

            assertThat(results).hasSize(2);
            verify(menuItemRepository).findAll();
            verifyNoInteractions(eventPublisher);
        }
    }

    @Nested
    @DisplayName("Get Menu Item By ID Tests")
    class GetMenuItemByIdTests {

        @Test
        @DisplayName("Should return menu item when valid ID is provided")
        void getMenuItemById_Success () {

            Long menuItemId = 100L;

            when(menuItemRepository.findById(menuItemId)).thenReturn(Optional.of(mockMenuItem));

            MenuItems result = menuItemService.getMenuItemById(menuItemId);

            assertThat(result).isNotNull();
            assertThat(result.getMenuItemId()).isEqualTo(menuItemId);
            assertThat(result.getName()).isEqualTo("Cappuccino");

            verify(menuItemRepository).findById(menuItemId);
            verifyNoInteractions(eventPublisher);
        }

        @Test
        @DisplayName("Should throw ResourceNotFoundException when menu item ID is not found")
        void getMenuItemById_NotFound_ThrowsException () {

            Long invalidId = 999L;

            when(menuItemRepository.findById(invalidId)).thenReturn(Optional.empty());

            assertThatThrownBy(() -> menuItemService.getMenuItemById(invalidId))
                    .isInstanceOf(ResourceNotFoundException.class)
                    .hasMessageContaining("Menu item not found with id: " + invalidId);

            verify(menuItemRepository).findById(invalidId);
            verifyNoInteractions(eventPublisher);
        }
    }

    @Nested
    @DisplayName("Upload Menu Item Image Tests")
    class UploadMenuItemImageTests {

        @Test
        @DisplayName("Should upload image via ImageStorageService and save new URL and publish event")
        void uploadMenuItemImage_Success () {

            Long menuItemId = 100L;

            MockMultipartFile file = new MockMultipartFile(
                    "file",
                    "cappuccino.jpg",
                    "image/jpeg",
                    "fake-image-bytes".getBytes()
            );

            String generatedUrl = "http://localhost:8080/uploads/menu-items/generated-uuid.jpg";

            when(menuItemRepository.findById(menuItemId)).thenReturn(Optional.of(mockMenuItem));
            when(imageStorageService.uploadImage(eq(file), eq("menu-items"))).thenReturn(generatedUrl);

            when(menuItemRepository.save(any(MenuItems.class)))
                    .thenAnswer(invocation -> {
                        MenuItems itemToSave = invocation.getArgument(0);
                        itemToSave.setUpdatedAt(LocalDateTime.now());
                        return itemToSave;
                    });

            MenuItems result = menuItemService.uploadMenuItemImage(menuItemId, file);

            assertThat(result.getImagePath()).isEqualTo(generatedUrl);

            verify(menuItemRepository).findById(menuItemId);
            verify(imageStorageService).uploadImage(file, "menu-items");
            verify(menuItemRepository).save(mockMenuItem);
            verify(eventPublisher).publishEvent(any(WebSocketMessageEvent.class));
        }

        @Test
        @DisplayName("Should delete old image prior to uploading new image if old image exists")
        void uploadMenuItemImage_ReplacesExistingImage () {

            Long menuItemId = 100L;

            String oldUrl = "http://localhost:8080/uploads/menu-items/old-uuid.jpg";
            String newUrl = "http://localhost:8080/uploads/menu-items/new-uuid.jpg";

            mockMenuItem.setImagePath(oldUrl);

            MockMultipartFile file = new MockMultipartFile(
                    "file",
                    "cappuccino.jpg",
                    "image/jpeg",
                    "fake-image-bytes".getBytes()
            );

            when(menuItemRepository.findById(menuItemId)).thenReturn(Optional.of(mockMenuItem));
            when(imageStorageService.uploadImage(eq(file), eq("menu-items"))).thenReturn(newUrl);

            when(menuItemRepository.save(any(MenuItems.class)))
                    .thenAnswer(invocation -> {
                        MenuItems itemToSave = invocation.getArgument(0);
                        itemToSave.setUpdatedAt(LocalDateTime.now());
                        return itemToSave;
                    });

            MenuItems result = menuItemService.uploadMenuItemImage(menuItemId, file);

            assertThat(result.getImagePath()).isEqualTo(newUrl);

            verify(imageStorageService).deleteImage(oldUrl);
            verify(imageStorageService).uploadImage(file, "menu-items");
            verify(menuItemRepository).save(mockMenuItem);
            verify(eventPublisher).publishEvent(any(WebSocketMessageEvent.class));
        }
    }

    @Nested
    @DisplayName("Delete Menu Item Image Tests")
    class DeleteMenuItemImageTests {

        @Test
        @DisplayName("Should clear imagePath and delegate deletion to ImageStorageService and publish event")
        void deleteMenuItemImage_Success () {

            Long menuItemId = 100L;
            String existingUrl = "http://localhost:8080/uploads/menu-items/sample.jpg";

            mockMenuItem.setImagePath(existingUrl);

            when(menuItemRepository.findById(menuItemId)).thenReturn(Optional.of(mockMenuItem));
            when(menuItemRepository.save(any(MenuItems.class)))
                    .thenAnswer(invocation -> {
                        MenuItems itemToSave = invocation.getArgument(0);
                        itemToSave.setUpdatedAt(LocalDateTime.now());
                        return itemToSave;
                    });

            MenuItems result = menuItemService.deleteMenuItemImage(menuItemId);

            assertThat(result.getImagePath()).isNull();

            verify(imageStorageService).deleteImage(existingUrl);
            verify(menuItemRepository).save(mockMenuItem);
            verify(eventPublisher).publishEvent(any(WebSocketMessageEvent.class));
        }

        @Test
        @DisplayName("Should handle delete gracefully when no image exists")
        void deleteMenuItemImage_NoExistingImage () {

            Long menuItemId = 100L;
            mockMenuItem.setImagePath(null);

            when(menuItemRepository.findById(menuItemId)).thenReturn(Optional.of(mockMenuItem));

            MenuItems result = menuItemService.deleteMenuItemImage(menuItemId);

            assertThat(result.getImagePath()).isNull();

            verify(imageStorageService, never()).deleteImage(any());
            verify(menuItemRepository, never()).save(any());
            verify(eventPublisher, never()).publishEvent(any());
        }
    }

    @Nested
    @DisplayName("Update Menu Item Availability Tests")
    class UpdateAvailabilityTests {

        @Test
        @DisplayName("Should successfully update menu item availability and publish UPDATE event")
        void updateAvailability_Success () {

            Long menuItemId = 100L;
            mockMenuItem.setAvailable(true);

            when(menuItemRepository.findById(menuItemId)).thenReturn(Optional.of(mockMenuItem));
            when(menuItemRepository.save(any(MenuItems.class)))
                    .thenAnswer(invocation -> invocation.getArgument(0));

            MenuItems result = menuItemService.updateAvailability(menuItemId, false);

            assertThat(result).isNotNull();
            assertThat(result.getAvailable()).isFalse();

            verify(menuItemRepository).findById(menuItemId);
            verify(menuItemRepository).save(mockMenuItem);

            // Verify WebSocket event
            ArgumentCaptor<WebSocketMessageEvent<?>> eventCaptor = ArgumentCaptor.forClass(WebSocketMessageEvent.class);
            verify(eventPublisher).publishEvent(eventCaptor.capture());
            assertThat(eventCaptor.getValue().getAction()).isEqualTo("UPDATE");
            assertThat(eventCaptor.getValue().getType()).isEqualTo("MENU-ITEM");
        }
    }
}