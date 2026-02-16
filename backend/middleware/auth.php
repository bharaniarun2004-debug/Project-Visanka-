<?php
require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../utils/response.php';

function authenticate() {
    $headers = getallheaders();
    $token = null;

    if (isset($headers['Authorization'])) {
        $token = str_replace('Bearer ', '', $headers['Authorization']);
    } elseif (isset($_SERVER['HTTP_AUTHORIZATION'])) { // Fallback for some server configs
        $token = str_replace('Bearer ', '', $_SERVER['HTTP_AUTHORIZATION']);
    }
    
    if (!$token) {
        sendResponse(false, 'No token provided', null, 401);
    }
    
    $tokenData = verifyToken($token);
    if (!$tokenData) {
        sendResponse(false, 'Invalid token', null, 401);
    }
    
    $database = new Database();
    $db = $database->getConnection();
    
    $query = "SELECT user_id, google_id, name, email, role FROM users WHERE user_id = :user_id";
    $stmt = $db->prepare($query);
    $stmt->bindParam(':user_id', $tokenData['user_id']);
    $stmt->execute();
    
    $user = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$user) {
        sendResponse(false, 'User not found', null, 401);
    }
    
    return $user;
}

function requireRole($allowedRoles) {
    $user = authenticate();
    
    if (!in_array($user['role'], $allowedRoles)) {
        sendResponse(false, 'Unauthorized access', null, 403);
    }
    
    return $user;
}
?>