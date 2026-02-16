<?php
require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../utils/response.php';
require_once __DIR__ . '/../middleware/auth.php';

$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'GET') {
    $user = requireRole(['user']);
    
    try {
        $database = new Database();
        $db = $database->getConnection();
        
        $query = "SELECT 
                    a.appointment_id,
                    a.provider_id,
                    a.user_id,
                    a.date,
                    a.time,
                    a.reason,
                    a.status,
                    a.meeting_id,
                    p.service_name,
                    u.name as provider_name,
                    u.email as provider_email
                  FROM appointments a
                  JOIN providers p ON a.provider_id = p.provider_id
                  JOIN users u ON p.user_id = u.user_id
                  WHERE a.user_id = :user_id
                  ORDER BY a.date DESC, a.time DESC";
        
        $stmt = $db->prepare($query);
        $stmt->bindParam(':user_id', $user['user_id']);
        $stmt->execute();
        
        $appointments = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        sendResponse(true, 'Appointments fetched successfully', $appointments);
        
    } catch(PDOException $e) {
        sendResponse(false, 'Database error: ' . $e->getMessage(), null, 500);
    }
    
} elseif ($method === 'PUT') {
    $user = requireRole(['user']);
    
    $data = json_decode(file_get_contents("php://input"), true);
    
    if (!isset($data['appointment_id'])) {
        sendResponse(false, 'Missing appointment_id', null, 400);
    }
    
    try {
        $database = new Database();
        $db = $database->getConnection();
        
        // Check if appointment belongs to user and is pending
        $checkQuery = "SELECT status FROM appointments WHERE appointment_id = :appointment_id AND user_id = :user_id";
        $checkStmt = $db->prepare($checkQuery);
        $checkStmt->bindParam(':appointment_id', $data['appointment_id']);
        $checkStmt->bindParam(':user_id', $user['user_id']);
        $checkStmt->execute();
        
        $appointment = $checkStmt->fetch(PDO::FETCH_ASSOC);
        
        if (!$appointment) {
            sendResponse(false, 'Appointment not found', null, 404);
        }
        
        if ($appointment['status'] !== 'pending') {
            sendResponse(false, 'Only pending appointments can be cancelled', null, 400);
        }
        
        $updateQuery = "UPDATE appointments SET status = 'cancelled' WHERE appointment_id = :appointment_id";
        $updateStmt = $db->prepare($updateQuery);
        $updateStmt->bindParam(':appointment_id', $data['appointment_id']);
        $updateStmt->execute();
        
        sendResponse(true, 'Appointment cancelled successfully');
        
    } catch(PDOException $e) {
        sendResponse(false, 'Database error: ' . $e->getMessage(), null, 500);
    }
}
?>