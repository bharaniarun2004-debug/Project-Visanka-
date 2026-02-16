<?php
require_once '../config/db.php';
require_once '../utils/response.php';

$database = new Database();
$db = $database->getConnection();

try {
    // Sample Providers Data
    $providers = [
        [
            'name' => 'Dr. Alice Smith',
            'email' => 'alice@example.com',
            'password' => password_hash('password123', PASSWORD_BCRYPT),
            'role' => 'provider',
            'service_name' => 'General Physician',
            'description' => 'Experienced general physician with over 10 years of practice.'
        ],
        [
            'name' => 'Dr. Bob Jones',
            'email' => 'bob@example.com',
            'password' => password_hash('password123', PASSWORD_BCRYPT),
            'role' => 'provider',
            'service_name' => 'Dermatologist',
            'description' => 'Specialist in skin care, acne treatment, and cosmetic procedures.'
        ],
        [
            'name' => 'Dr. Charlie Brown',
            'email' => 'charlie@example.com',
            'password' => password_hash('password123', PASSWORD_BCRYPT),
            'role' => 'provider',
            'service_name' => 'Cardiologist',
            'description' => 'Expert in heart health and cardiovascular diseases.'
        ],
         [
            'name' => 'Dr. Diana Prince',
            'email' => 'diana@example.com',
            'password' => password_hash('password123', PASSWORD_BCRYPT),
            'role' => 'provider',
            'service_name' => 'Neurologist',
            'description' => 'Specializing in disorders of the nervous system.'
        ]
    ];

    $count = 0;

    foreach ($providers as $provider) {
        // Check if user exists
        $checkQuery = "SELECT user_id FROM users WHERE email = :email";
        $stmt = $db->prepare($checkQuery);
        $stmt->bindParam(":email", $provider['email']);
        $stmt->execute();

        if ($stmt->rowCount() == 0) {
            // Insert User
            $userQuery = "INSERT INTO users (name, email, password, role) VALUES (:name, :email, :password, :role)";
            $userStmt = $db->prepare($userQuery);
            $userStmt->bindParam(":name", $provider['name']);
            $userStmt->bindParam(":email", $provider['email']);
            $userStmt->bindParam(":password", $provider['password']);
            $userStmt->bindParam(":role", $provider['role']);
            $userStmt->execute();
            
            $user_id = $db->lastInsertId();

            // Insert Provider Details
            $provQuery = "INSERT INTO providers (user_id, service_name, description) VALUES (:user_id, :service_name, :description)";
            $provStmt = $db->prepare($provQuery);
            $provStmt->bindParam(":user_id", $user_id);
            $provStmt->bindParam(":service_name", $provider['service_name']);
            $provStmt->bindParam(":description", $provider['description']);
            $provStmt->execute();
            
            $count++;
        }
    }

    sendResponse(true, "Database seeded successfully. Added $count new providers.");

} catch (PDOException $e) {
    sendResponse(false, "Database error: " . $e->getMessage());
}
?>
