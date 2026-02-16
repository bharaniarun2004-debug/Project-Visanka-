<?php
require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../utils/response.php';
require_once __DIR__ . '/../middleware/auth.php';

$user = requireRole(['provider']);

try {
    $database = new Database();
    $db = $database->getConnection();
    
    // Get provider_id for this user
    $providerQuery = "SELECT provider_id FROM providers WHERE user_id = :user_id";
    $providerStmt = $db->prepare($providerQuery);
    $providerStmt->bindParam(':user_id', $user['user_id']);
    $providerStmt->execute();
    
    $provider = $providerStmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$provider) {
        sendResponse(false, 'Provider profile not found', null, 404);
    }
    
    $query = "SELECT 
                a.appointment_id,
                a.provider_id,
                a.user_id,
                a.date,
                a.time,
                a.reason,
                a.status,
                a.meeting_id,
                u.name as user_name,
                u.email as user_email
              FROM appointments a
              JOIN users u ON a.user_id = u.user_id
              WHERE a.provider_id = :provider_id
              ORDER BY a.date DESC, a.time DESC";
    
    $stmt = $db->prepare($query);
    $stmt->bindParam(':provider_id', $provider['provider_id']);
    $stmt->execute();
    
    $appointments = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    sendResponse(true, 'Appointment requests fetched successfully', $appointments);
    
} catch(PDOException $e) {
    sendResponse(false, 'Database error: ' . $e->getMessage(), null, 500);
}
?>