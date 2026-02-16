$headers = @{
    "Content-Type" = "application/json"
}
$body = @{
    name = "Alice Smith"
    email = "alice@example.com"
    password = "password123"
    role = "provider" 
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "http://10.23.21.57/online-appointment-booking-final/backend/auth/register.php" -Method Post -Headers $headers -Body $body
    Write-Output "Registration Response:"
    Write-Output $response
} catch {
    Write-Error "Registration failed: $_"
    Write-Output "Status Code: $($_.Exception.Response.StatusCode.value__)"
    Write-Output "Body: $($_.ErrorDetails.Message)"
}
