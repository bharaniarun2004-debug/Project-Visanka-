<?php
require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../utils/response.php';
require_once __DIR__ . '/../middleware/auth.php';

$user = requireRole(['provider']);

$data = json_decode(file_get_contents("php://input"), true);

if (!isset($data['appointment_id']) || !isset($data['status'])) {
    sendResponse(false, 'Missing required fields', null, 400);
}

if (!in_array($data['status'], ['accepted', 'rejected'])) {
    sendResponse(false, 'Invalid status', null, 400);
}

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
    
    // Check if appointment belongs to this provider
    $checkQuery = "SELECT a.appointment_id, a.status, u.email as user_email, u.name as user_name 
                   FROM appointments a 
                   JOIN users u ON a.user_id = u.user_id
                   WHERE a.appointment_id = :appointment_id AND a.provider_id = :provider_id";
    $checkStmt = $db->prepare($checkQuery);
    $checkStmt->bindParam(':appointment_id', $data['appointment_id']);
    $checkStmt->bindParam(':provider_id', $provider['provider_id']);
    $checkStmt->execute();
    
    $appointment = $checkStmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$appointment) {
        sendResponse(false, 'Appointment not found', null, 404);
    }
    
    if ($appointment['status'] !== 'pending') {
        sendResponse(false, 'Appointment already processed', null, 400);
    }
    
    $meetingId = null;
    if ($data['status'] === 'accepted') {
        $meetingId = 'MEET-' . strtoupper(substr(md5(uniqid()), 0, 10));
    }
    
    $updateQuery = "UPDATE appointments SET status = :status, meeting_id = :meeting_id WHERE appointment_id = :appointment_id";
    $updateStmt = $db->prepare($updateQuery);
    $updateStmt->bindParam(':status', $data['status']);
    $updateStmt->bindParam(':meeting_id', $meetingId);
    $updateStmt->bindParam(':appointment_id', $data['appointment_id']);
    $updateStmt->execute();
    
    // Email notification logic (placeholder - requires mail server configuration)
    if ($data['status'] === 'accepted') {
        $to = $appointment['user_email'];
        $subject = "Appointment Confirmed - Meeting ID: " . $meetingId;
        $message = "Dear " . $appointment['user_name'] . ",\n\n";
        $message .= "Your appointment has been confirmed!\n";
        $message .= "Meeting ID: " . $meetingId . "\n\n";
        $message .= "Best regards,\n" . $user['name'];
        $headers = "From: noreply@appointmentbooking.com";
        
        // Uncomment when mail server is configured
        // mail($to, $subject, $message, $headers);
    }
    
    sendResponse(true, 'Appointment updated successfully', [
        'meeting_id' => $meetingId
    ]);
    
} catch(PDOException $e) {
    sendResponse(false, 'Database error: ' . $e->getMessage(), null, 500);
}
?>