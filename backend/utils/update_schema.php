<?php
require_once '../config/db.php';
require_once '../utils/response.php';

$database = new Database();
$db = $database->getConnection();

try {
    // Check if password column exists
    $checkQuery = "SHOW COLUMNS FROM users LIKE 'password'";
    $stmt = $db->prepare($checkQuery);
    $stmt->execute();
    
    if ($stmt->rowCount() == 0) {
        // Add password column
        $alterQuery = "ALTER TABLE users ADD COLUMN password VARCHAR(255) NULL AFTER email";
        $db->exec($alterQuery);
        
        // Make google_id nullable since email/password users won't have it
        $alterGoogleId = "ALTER TABLE users MODIFY COLUMN google_id VARCHAR(255) NULL";
        $db->exec($alterGoogleId);
        
        sendResponse(true, "Schema updated successfully: Key columns modified.");
    } else {
        sendResponse(true, "Schema already up to date.");
    }
} catch (PDOException $e) {
    sendResponse(false, "Database error: " . $e->getMessage());
}
?>
