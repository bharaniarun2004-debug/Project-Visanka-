-- ============================================
-- Appointment Booking System - Database Schema
-- ============================================

-- Create database
CREATE DATABASE IF NOT EXISTS appointment_booking;
USE appointment_booking;

-- Users table
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    google_id VARCHAR(255) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    role ENUM('user', 'provider') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_google_id (google_id),
    INDEX idx_email (email),
    INDEX idx_role (role)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Providers table
CREATE TABLE providers (
    provider_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    service_name VARCHAR(255) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Appointments table
CREATE TABLE appointments (
    appointment_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    provider_id INT NOT NULL,
    date DATE NOT NULL,
    time TIME NOT NULL,
    reason TEXT,
    status ENUM('pending', 'accepted', 'rejected', 'cancelled') DEFAULT 'pending',
    meeting_id VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (provider_id) REFERENCES providers(provider_id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_provider_id (provider_id),
    INDEX idx_status (status),
    INDEX idx_date (date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- Sample Data - Providers
-- ============================================

INSERT INTO users (google_id, name, email, role) VALUES
('google_provider_1', 'Dr. Sarah Johnson', 'sarah.johnson@gmail.com', 'provider'),
('google_provider_2', 'Dr. Michael Chen', 'michael.chen@gmail.com', 'provider'),
('google_provider_3', 'Dr. Emily Rodriguez', 'emily.rodriguez@gmail.com', 'provider'),
('google_provider_4', 'Dr. David Kim', 'david.kim@gmail.com', 'provider'),
('google_provider_5', 'Dr. Jessica Martinez', 'jessica.martinez@gmail.com', 'provider');

INSERT INTO providers (user_id, service_name, description) VALUES
(1, 'Career Counseling', 'Expert career guidance and mentorship for professionals seeking growth and advancement in their careers'),
(2, 'Tech Interview Prep', 'Specialized coaching for software engineering interviews, coding challenges, and technical assessments'),
(3, 'Business Strategy', 'Strategic consulting for startups and small businesses focusing on growth planning and market positioning'),
(4, 'Financial Planning', 'Comprehensive financial advisory services for personal wealth management and investment strategies'),
(5, 'Health & Wellness Coaching', 'Personalized health coaching focused on nutrition, fitness, and lifestyle optimization');

-- ============================================
-- Verification Queries
-- ============================================

-- Check if tables were created successfully
SHOW TABLES;

-- Verify sample data
SELECT COUNT(*) as total_providers FROM providers;
SELECT p.provider_id, p.service_name, u.name as provider_name, u.email 
FROM providers p 
JOIN users u ON p.user_id = u.user_id;

-- ============================================
-- Database Setup Complete
-- ============================================
