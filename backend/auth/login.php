<?php
require_once '../config/db.php';
require_once '../utils/response.php';

$database = new Database();
$db = $database->getConnection();

$data = json_decode(file_get_contents("php://input"));

if (!isset($data->email) || !isset($data->password)) {
    sendResponse(false, "Missing email or password");
}

$email = htmlspecialchars(strip_tags($data->email));
$password = $data->password;

try {
    $query = "SELECT user_id, name, email, password, role FROM users WHERE email = :email";
    $stmt = $db->prepare($query);
    $stmt->bindParam(":email", $email);
    $stmt->execute();

    if ($stmt->rowCount() > 0) {
        $row = $stmt->fetch(PDO::FETCH_ASSOC);
        $hashed_password = $row['password'];
        
        if (password_verify($password, $hashed_password)) {
            $user_id = $row['user_id'];
            $token = generateToken($user_id);
            
            // Remove password from response
            unset($row['password']);
            
            sendResponse(true, "Login successful", [
                'token' => $token,
                'user' => $row
            ]);
        } else {
            sendResponse(false, "Invalid password");
        }
    } else {
        sendResponse(false, "User not found");
    }
} catch (PDOException $e) {
    sendResponse(false, "Database error: " . $e->getMessage());
}
?>
