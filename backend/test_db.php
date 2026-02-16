<?php
header('Content-Type: application/json');

$host = 'localhost';
$db_name = 'appointment_booking';
$username = 'root';
$password = '';

$response = [
    'status' => 'error',
    'message' => '',
    'details' => []
];

try {
    $conn = new PDO("mysql:host=$host;dbname=$db_name", $username, $password);
    $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    $response['status'] = 'success';
    $response['message'] = 'Database connection successful!';
    
    // Check if users table exists
    $stmt = $conn->query("SHOW TABLES LIKE 'users'");
    if ($stmt->rowCount() > 0) {
        $response['details']['users_table'] = 'Exists';
        
        // Check columns
        $stmt = $conn->query("SHOW COLUMNS FROM users");
        $columns = $stmt->fetchAll(PDO::FETCH_COLUMN);
        $response['details']['columns'] = $columns;
    } else {
        $response['details']['users_table'] = 'Missing';
    }
    
} catch(PDOException $e) {
    $response['message'] = 'Connection failed: ' . $e->getMessage();
}

echo json_encode($response);
?>
