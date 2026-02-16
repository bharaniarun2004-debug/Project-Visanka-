<?php
function sendResponse($success, $message, $data = null, $code = 200) {
    http_response_code($code);
    echo json_encode([
        'success' => $success,
        'message' => $message,
        'data' => $data
    ]);
    exit();
}

function generateToken($userId) {
    return bin2hex(random_bytes(32)) . '_' . $userId . '_' . time();
}

function verifyToken($token) {
    if (empty($token)) {
        return false;
    }
    
    $parts = explode('_', $token);
    if (count($parts) !== 3) {
        return false;
    }
    
    return [
        'user_id' => (int)$parts[1],
        'timestamp' => (int)$parts[2]
    ];
}
?>