package org.example.cafeteria_ordering_backend.repository;

import org.example.cafeteria_ordering_backend.entity.Notification;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface NotificationRepository extends JpaRepository<Notification, Long> {

    // Get all notifications for specific user, ordered by creation date
    List<Notification> findByUserIdOrderByCreatedAtDesc(long userId);
}
