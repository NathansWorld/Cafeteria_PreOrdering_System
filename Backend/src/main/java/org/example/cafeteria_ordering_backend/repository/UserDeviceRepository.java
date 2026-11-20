package org.example.cafeteria_ordering_backend.repository;

import org.example.cafeteria_ordering_backend.entity.UserDevice;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface UserDeviceRepository extends JpaRepository<UserDevice, Long> {

    // Find a specific device token record
    Optional<UserDevice> findByFcmToken(String fcmToken);

    // Get all registered devices for a specific user
    List<UserDevice> findByUserUserId(Long userId);

    // Delete a token when a user logs out or the token becomes invalid
    void deleteByFcmToken(String fcmToken);
}