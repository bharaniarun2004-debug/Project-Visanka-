$headers = @{
    "Content-Type" = "application/json"
}
$body = @{
    email = "alice@example.com"
    password = "password123"
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "http://10.23.21.57/online-appointment-booking-final/backend/auth/login.php" -Method Post -Headers $headers -Body $body
    Write-Output "Login Response:"
    Write-Output $response
} catch {
    Write-Error "Login failed: $_"
    Write-Output "Status Code: $($_.Exception.Response.StatusCode.value__)"
}
