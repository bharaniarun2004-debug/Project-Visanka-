<?php
require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../utils/response.php';

$data = json_decode(file_get_contents("php://input"), true);

if (!isset($data['google_id']) || !isset($data['name']) || !isset($data['email']) || !isset($data['role'])) {
    sendResponse(false, 'Missing required fields', null, 400);
}

$googleId = $data['google_id'];
$name = $data['name'];
$email = $data['email'];
$role = $data['role'];

if (!in_array($role, ['user', 'provider'])) {
    sendResponse(false, 'Invalid role', null, 400);
}

try {
    $database = new Database();
    $db = $database->getConnection();
    
    // Check if user exists
    $query = "SELECT user_id, google_id, name, email, role FROM users WHERE google_id = :google_id";
    $stmt = $db->prepare($query);
    $stmt->bindParam(':google_id', $googleId);
    $stmt->execute();
    
    $user = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if ($user) {
        // Update user info
        $updateQuery = "UPDATE users SET name = :name, email = :email WHERE google_id = :google_id";
        $updateStmt = $db->prepare($updateQuery);
        $updateStmt->bindParam(':name', $name);
        $updateStmt->bindParam(':email', $email);
        $updateStmt->bindParam(':google_id', $googleId);
        $updateStmt->execute();
        
        $userId = $user['user_id'];
    } else {
        // Create new user
        $insertQuery = "INSERT INTO users (google_id, name, email, role) VALUES (:google_id, :name, :email, :role)";
        $insertStmt = $db->prepare($insertQuery);
        $insertStmt->bindParam(':google_id', $googleId);
        $insertStmt->bindParam(':name', $name);
        $insertStmt->bindParam(':email', $email);
        $insertStmt->bindParam(':role', $role);
        $insertStmt->execute();
        
        $userId = $db->lastInsertId();
        
        // If provider, create provider profile
        if ($role === 'provider') {
            $providerQuery = "INSERT INTO providers (user_id, service_name, description) VALUES (:user_id, 'General Consulting', 'Professional consulting services')";
            $providerStmt = $db->prepare($providerQuery);
            $providerStmt->bindParam(':user_id', $userId);
            $providerStmt->execute();
        }
    }
    
    // Generate token
    $token = generateToken($userId);
    
    // Get updated user data
    $userQuery = "SELECT user_id, google_id, name, email, role FROM users WHERE user_id = :user_id";
    $userStmt = $db->prepare($userQuery);
    $userStmt->bindParam(':user_id', $userId);
    $userStmt->execute();
    $userData = $userStmt->fetch(PDO::FETCH_ASSOC);
    
    sendResponse(true, 'Login successful', [
        'token' => $token,
        'user' => $userData
    ]);
    
} catch(PDOException $e) {
    sendResponse(false, 'Database error: ' . $e->getMessage(), null, 500);
}
?>