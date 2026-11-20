package org.example.cafeteria_ordering_backend.service;

import org.example.cafeteria_ordering_backend.entity.Category;
import org.example.cafeteria_ordering_backend.event.WebSocketMessageEvent;
import org.example.cafeteria_ordering_backend.repository.CategoryRepository;
import org.example.cafeteria_ordering_backend.service.implementation.CategoryServiceImpl;
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

import java.util.Arrays;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class CategoryServiceImplTest {

    @Mock private CategoryRepository categoryRepository;
    @Mock private ApplicationEventPublisher eventPublisher;

    // Inject mocked repo and event publisher into service being tested
    @InjectMocks
    private CategoryServiceImpl categoryService;
    private Category categoryOne;
    private Category categoryTwo;

    @BeforeEach
    void setup () {

        categoryOne = new Category();
        categoryOne.setCategoryId(1L);
        categoryOne.setCategoryName("Beverages");
        categoryOne.setDisplayOrder(2);

        categoryTwo = new Category();
        categoryTwo.setCategoryId(2L);
        categoryTwo.setCategoryName("Hot Meals");
        categoryTwo.setDisplayOrder(1);
    }

    @Nested
    @DisplayName("CreateCategory Method tests")
    class CreateCategoryTests {

        @Test
        @DisplayName("Should successfully create category with provided display order and publish WebSocket event")
        void createCategory_Success_WithDisplayOrder () {

            // Confirm the category name unique
            when(categoryRepository.existsByCategoryName("Beverages")).thenReturn(false);

            // Mock saving the cat and filling its timestamp
            when(categoryRepository.save(any(Category.class))).thenAnswer(invocation -> {
                        Category cat = invocation.getArgument(0);
                        cat.setCreatedAt(java.time.LocalDateTime.now());
                        cat.setUpdatedAt(java.time.LocalDateTime.now());
                        return cat;
                    });

            Category created = categoryService.createCategory(categoryOne);

            // Verify category still has given details
            assertNotNull(created);
            assertEquals("Beverages", created.getCategoryName());
            assertEquals(2, created.getDisplayOrder());

            assertNotNull(created.getCreatedAt());
            assertNotNull(created.getUpdatedAt());

            verify(categoryRepository).save(categoryOne);

            // Verify WebSocket event was published
            ArgumentCaptor<WebSocketMessageEvent<?>> eventCaptor = ArgumentCaptor.forClass(WebSocketMessageEvent.class);
            verify(eventPublisher).publishEvent(eventCaptor.capture());

            WebSocketMessageEvent<?> event = eventCaptor.getValue();
            assertEquals("/topic/menu/updates", event.getDestination());
            assertEquals("CREATE", event.getAction());
            assertEquals("CATEGORY", event.getType());
            assertEquals(categoryOne, event.getData());
        }

        @Test
        @DisplayName("Should default displayOrder to 0 when user provides null and publish event")
        void createCategory_Success_DefaultsDisplayOrderToZero () {

            Category inputCategory = new Category();
            inputCategory.setCategoryName("Snacks");
            inputCategory.setDisplayOrder(null);

            when(categoryRepository.existsByCategoryName("Snacks")).thenReturn(false);
            when(categoryRepository.save(any(Category.class)))
                    .thenAnswer(invocation -> {
                        Category cat = invocation.getArgument(0);
                        cat.setCreatedAt(java.time.LocalDateTime.now());
                        cat.setUpdatedAt(java.time.LocalDateTime.now());
                        return cat;
                    });

            Category created = categoryService.createCategory(inputCategory);

            assertNotNull(created);
            assertEquals(0, created.getDisplayOrder());
            assertNotNull(inputCategory.getCreatedAt());
            assertNotNull(inputCategory.getUpdatedAt());

            verify(categoryRepository).save(inputCategory);
            verify(eventPublisher).publishEvent(any(WebSocketMessageEvent.class));
        }

        @Test
        @DisplayName("Should throw RuntimeException when category name already exists and NOT publish event")
        void createCategory_ThrowsException_WhenNameExists () {

            when(categoryRepository.existsByCategoryName("Beverages")).thenReturn(true);

            RuntimeException exception = assertThrows(
                    RuntimeException.class,
                    () -> categoryService.createCategory(categoryOne)
            );

            assertEquals("Category name already exists!", exception.getMessage());

            verify(categoryRepository, never()).save(any(Category.class));
            verify(eventPublisher, never()).publishEvent(any());
        }
    }

    @Nested
    @DisplayName("GetAllActiveCategories Method Tests")
    class GetAllActiveCategoriesTests {

        @Test
        @DisplayName("Should fetch all categories sorted by displayOrder ASC from repository")
        void getAllActiveCategories_ReturnsSortedByDisplayOrder () {

            when(categoryRepository.findAllByOrderByDisplayOrderAsc())
                    .thenReturn(Arrays.asList(categoryTwo, categoryOne));

            List<Category> result = categoryService.getAllActiveCategories();

            assertNotNull(result);
            assertEquals(2, result.size());
            assertEquals("Hot Meals", result.get(0).getCategoryName());
            assertEquals("Beverages", result.get(1).getCategoryName());

            verify(categoryRepository).findAllByOrderByDisplayOrderAsc();
            verifyNoInteractions(eventPublisher);
        }
    }

    @Nested
    @DisplayName("GetCategoryById Method Tests")
    class GetCategoryByIdTests {

        @Test
        @DisplayName("Should return category when valid ID is provided")
        void getCategoryById_Success () {

            when(categoryRepository.findById(1L)).thenReturn(java.util.Optional.of(categoryOne));

            Category found = categoryService.getCategoryById(1L);

            assertNotNull(found);
            assertEquals(1L, found.getCategoryId());
            assertEquals("Beverages", found.getCategoryName());

            verify(categoryRepository).findById(1L);
            verifyNoInteractions(eventPublisher);
        }

        @Test
        @DisplayName("Should throw ResourceNotFoundException when category ID does not exist")
        void getCategoryById_ThrowsException_WhenNotFound () {

            when(categoryRepository.findById(999L)).thenReturn(java.util.Optional.empty());

            org.example.cafeteria_ordering_backend.exception.ResourceNotFoundException exception = assertThrows(
                    org.example.cafeteria_ordering_backend.exception.ResourceNotFoundException.class,
                    () -> categoryService.getCategoryById(999L)
            );

            assertTrue(exception.getMessage().contains("Category not found with id: 999"));

            verify(categoryRepository).findById(999L);
            verifyNoInteractions(eventPublisher);
        }
    }

    @Nested
    @DisplayName("UpdateCategory Method Tests")
    class UpdateCategoryTests {

        @Test
        @DisplayName("Should successfully update category when valid details provided and publish update event")
        void updateCategory_Success () {

            Category updateDetails = new Category();
            updateDetails.setCategoryName("Cold Beverages");
            updateDetails.setDisplayOrder(3);

            when(categoryRepository.findById(1L)).thenReturn(java.util.Optional.of(categoryOne));
            when(categoryRepository.existsByCategoryName("Cold Beverages")).thenReturn(false);
            when(categoryRepository.save(any(Category.class)))
                    .thenAnswer(invocation -> invocation.getArgument(0));

            Category updated = categoryService.updateCategory(1L, updateDetails);

            assertNotNull(updated);
            assertEquals("Cold Beverages", updated.getCategoryName());
            assertEquals(3, updated.getDisplayOrder());

            verify(categoryRepository).findById(1L);
            verify(categoryRepository).existsByCategoryName("Cold Beverages");
            verify(categoryRepository).save(categoryOne);

            // Verify UPDATE WebSocket event was published
            ArgumentCaptor<WebSocketMessageEvent<?>> eventCaptor = ArgumentCaptor.forClass(WebSocketMessageEvent.class);
            verify(eventPublisher).publishEvent(eventCaptor.capture());

            WebSocketMessageEvent<?> event = eventCaptor.getValue();
            assertEquals("UPDATE", event.getAction());
            assertEquals("CATEGORY", event.getType());
        }

        @Test
        @DisplayName("Should throw RuntimeException when updating to an existing category name")
        void updateCategory_ThrowsException_WhenNameExists () {

            Category updateDetails = new Category();
            updateDetails.setCategoryName("Hot Meals");

            when(categoryRepository.findById(1L)).thenReturn(java.util.Optional.of(categoryOne));
            when(categoryRepository.existsByCategoryName("Hot Meals")).thenReturn(true);

            RuntimeException exception = assertThrows(
                    RuntimeException.class,
                    () -> categoryService.updateCategory(1L, updateDetails)
            );

            assertEquals("Category name already exists!", exception.getMessage());

            verify(categoryRepository).findById(1L);
            verify(categoryRepository, never()).save(any(Category.class));
            verify(eventPublisher, never()).publishEvent(any());
        }
    }

    @Nested
    @DisplayName("DeleteCategory Method Tests")
    class DeleteCategoryTests {

        @Test
        @DisplayName("Should successfully delete category when found and publish delete event")
        void deleteCategory_Success () {

            when(categoryRepository.findById(1L)).thenReturn(java.util.Optional.of(categoryOne));
            doNothing().when(categoryRepository).delete(categoryOne);

            categoryService.deleteCategory(1L);

            verify(categoryRepository).findById(1L);
            verify(categoryRepository).delete(categoryOne);

            // Verify DELETE WebSocket event was published
            ArgumentCaptor<WebSocketMessageEvent<?>> eventCaptor = ArgumentCaptor.forClass(WebSocketMessageEvent.class);
            verify(eventPublisher).publishEvent(eventCaptor.capture());

            WebSocketMessageEvent<?> event = eventCaptor.getValue();
            assertEquals("DELETE", event.getAction());
            assertEquals("CATEGORY", event.getType());
            assertEquals(categoryOne, event.getData());
        }

        @Test
        @DisplayName("Should throw ResourceNotFoundException when deleting non-existent category")
        void deleteCategory_ThrowsException_WhenNotFound () {

            when(categoryRepository.findById(999L)).thenReturn(java.util.Optional.empty());

            org.example.cafeteria_ordering_backend.exception.ResourceNotFoundException exception = assertThrows(
                    org.example.cafeteria_ordering_backend.exception.ResourceNotFoundException.class,
                    () -> categoryService.deleteCategory(999L)
            );

            assertTrue(exception.getMessage().contains("Category not found with id: 999"));

            verify(categoryRepository).findById(999L);
            verify(categoryRepository, never()).delete(any(Category.class));
            verify(eventPublisher, never()).publishEvent(any());
        }
    }
}