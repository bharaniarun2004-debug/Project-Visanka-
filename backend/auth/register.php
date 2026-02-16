<?php
require_once '../config/db.php';
require_once '../utils/response.php';

$database = new Database();
$db = $database->getConnection();

$data = json_decode(file_get_contents("php://input"));

if (!isset($data->name) || !isset($data->email) || !isset($data->password) || !isset($data->role)) {
    sendResponse(false, "Missing required fields");
}

$name = htmlspecialchars(strip_tags($data->name));
$email = htmlspecialchars(strip_tags($data->email));
$password = password_hash($data->password, PASSWORD_BCRYPT);
$role = htmlspecialchars(strip_tags($data->role));

// Default service name for providers if not provided
$service_name = "General Consultation"; 
$description = "New provider";

try {
    // Check if email exists
    $checkQuery = "SELECT user_id FROM users WHERE email = :email";
    $stmt = $db->prepare($checkQuery);
    $stmt->bindParam(":email", $email);
    $stmt->execute();

    if ($stmt->rowCount() > 0) {
        sendResponse(false, "Email already registered");
    }

    // Insert new user
    $query = "INSERT INTO users (name, email, password, role) VALUES (:name, :email, :password, :role)";
    $stmt = $db->prepare($query);
    $stmt->bindParam(":name", $name);
    $stmt->bindParam(":email", $email);
    $stmt->bindParam(":password", $password);
    $stmt->bindParam(":role", $role);

    if ($stmt->execute()) {
        $user_id = $db->lastInsertId();
        
        // If provider, insert into providers table
        if ($role === 'provider') {
            $providerQuery = "INSERT INTO providers (user_id, service_name, description) VALUES (:user_id, :service_name, :description)";
            $providerStmt = $db->prepare($providerQuery);
            $providerStmt->bindParam(":user_id", $user_id);
            $providerStmt->bindParam(":service_name", $service_name);
            $providerStmt->bindParam(":description", $description);
            $providerStmt->execute();
        }

        $token = generateToken($user_id);
        
        $user_data = [
            'user_id' => $user_id,
            'name' => $name,
            'email' => $email,
            'role' => $role
        ];

        sendResponse(true, "User registered successfully", [
            'token' => $token,
            'user' => $user_data
        ]);
    } else {
        sendResponse(false, "Unable to register user");
    }
} catch (PDOException $e) {
    sendResponse(false, "Database error: " . $e->getMessage());
}
?>
