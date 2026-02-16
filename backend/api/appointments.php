<?php
require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../utils/response.php';
require_once __DIR__ . '/../middleware/auth.php';

$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'POST') {
    $user = requireRole(['user']);
    
    $data = json_decode(file_get_contents("php://input"), true);
    
    if (!isset($data['provider_id']) || !isset($data['date']) || !isset($data['time']) || !isset($data['reason'])) {
        sendResponse(false, 'Missing required fields', null, 400);
    }
    
    try {
        $database = new Database();
        $db = $database->getConnection();
        
        // Check if provider exists
        $checkQuery = "SELECT provider_id FROM providers WHERE provider_id = :provider_id";
        $checkStmt = $db->prepare($checkQuery);
        $checkStmt->bindParam(':provider_id', $data['provider_id']);
        $checkStmt->execute();
        
        if ($checkStmt->rowCount() === 0) {
            sendResponse(false, 'Provider not found', null, 404);
        }
        
        $query = "INSERT INTO appointments (user_id, provider_id, date, time, reason, status) 
                  VALUES (:user_id, :provider_id, :date, :time, :reason, 'pending')";
        
        $stmt = $db->prepare($query);
        $stmt->bindParam(':user_id', $user['user_id']);
        $stmt->bindParam(':provider_id', $data['provider_id']);
        $stmt->bindParam(':date', $data['date']);
        $stmt->bindParam(':time', $data['time']);
        $stmt->bindParam(':reason', $data['reason']);
        $stmt->execute();
        
        $appointmentId = $db->lastInsertId();
        
        sendResponse(true, 'Appointment booked successfully', [
            'appointment_id' => $appointmentId
        ]);
        
    } catch(PDOException $e) {
        sendResponse(false, 'Database error: ' . $e->getMessage(), null, 500);
    }
}
?>