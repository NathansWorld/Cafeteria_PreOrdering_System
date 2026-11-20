# EduEats Project Documentation Hub

Welcome to the backend and architecture documentation for the EduEats Cafeteria Pre-Ordering System.

## Current System State & Capabilities

- **Backend Architecture**: Spring Boot application running Spring Security, JWT authentication (Access & Refresh tokens), and WebSocket STOMP messaging for real-time order updates.
- **Image Storage**: **Cloudinary Storage Service Enabled**.
    - Dual implementation via `ImageStorageService` interface (`CloudinaryImageStorageServiceImpl` vs `LocalImageStorageServiceImpl`).
    - Active profile/configuration relies on Cloudinary for scalable image delivery for menu items.
- **Database**: Relational MySQL schema with historical migration tracking under `DBHistory/`.
- **Testing**: Complete unit and integration test coverage for services, controllers, security evaluators, and WebSocket checkout/cancellation flows.
