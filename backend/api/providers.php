<?php
require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../utils/response.php';
require_once __DIR__ . '/../middleware/auth.php';

$user = requireRole(['user']);

try {
    $database = new Database();
    $db = $database->getConnection();
    
    $query = "SELECT 
                p.provider_id,
                p.service_name,
                p.description,
                u.name,
                u.email
              FROM providers p
              JOIN users u ON p.user_id = u.user_id
              WHERE u.role = 'provider'
              ORDER BY p.created_at DESC";
    
    $stmt = $db->prepare($query);
    $stmt->execute();
    
    $providers = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    sendResponse(true, 'Providers fetched successfully', $providers);
    
} catch(PDOException $e) {
    sendResponse(false, 'Database error: ' . $e->getMessage(), null, 500);
}
?>