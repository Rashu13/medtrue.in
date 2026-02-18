<?php
// Include database connection
require_once 'db.php';

// Set the Content-Type to JSON
header("Content-Type: application/json");

// Get the HTTP request method (POST)
$method = $_SERVER['REQUEST_METHOD'];

if ($method == 'POST') {
    // Get JSON data from the request body
    $input = json_decode(file_get_contents("php://input"), true);

    // Validate input — email, token, and new_password are required
    if (!isset($input['email']) || !isset($input['token']) || !isset($input['new_password'])) {
        echo json_encode(["success" => false, "message" => "Email, token, and new_password are required"]);
        exit();
    }

    $email = $conn->real_escape_string($input['email']);
    $token = $input['token'];
    $new_password = $input['new_password'];

    // Validate password strength
    if (strlen($new_password) < 6) {
        echo json_encode(["success" => false, "message" => "Password must be at least 6 characters long"]);
        exit();
    }

    // Hash the provided token to compare with stored hash
    $hashed_token = hash('sha256', $token);

    // Look up the reset token in the database
    $stmt = $conn->prepare("SELECT pr.id, pr.user_id, pr.expires_at, pr.used 
                            FROM password_resets pr 
                            WHERE pr.email = ? AND pr.token = ? 
                            ORDER BY pr.created_at DESC 
                            LIMIT 1");
    $stmt->bind_param("ss", $email, $hashed_token);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($result->num_rows === 0) {
        echo json_encode(["success" => false, "message" => "Invalid or expired reset token"]);
        exit();
    }

    $reset_record = $result->fetch_assoc();
    $stmt->close();

    // Check if token has already been used
    if ($reset_record['used'] == 1) {
        echo json_encode(["success" => false, "message" => "This reset token has already been used"]);
        exit();
    }

    // Check if token has expired
    if (strtotime($reset_record['expires_at']) < time()) {
        // Mark token as used
        $expire_stmt = $conn->prepare("UPDATE password_resets SET used = 1 WHERE id = ?");
        $expire_stmt->bind_param("i", $reset_record['id']);
        $expire_stmt->execute();
        $expire_stmt->close();

        echo json_encode(["success" => false, "message" => "Reset token has expired. Please request a new one."]);
        exit();
    }

    // Hash the new password
    $hashed_password = password_hash($new_password, PASSWORD_BCRYPT);

    // Update user's password
    $update_stmt = $conn->prepare("UPDATE users SET password = ? WHERE id = ?");
    $update_stmt->bind_param("si", $hashed_password, $reset_record['user_id']);

    if ($update_stmt->execute()) {
        // Mark token as used
        $mark_used_stmt = $conn->prepare("UPDATE password_resets SET used = 1 WHERE id = ?");
        $mark_used_stmt->bind_param("i", $reset_record['id']);
        $mark_used_stmt->execute();
        $mark_used_stmt->close();

        // Also invalidate all other tokens for this email
        $invalidate_stmt = $conn->prepare("UPDATE password_resets SET used = 1 WHERE email = ?");
        $invalidate_stmt->bind_param("s", $email);
        $invalidate_stmt->execute();
        $invalidate_stmt->close();

        echo json_encode(["success" => true, "message" => "Password reset successfully"]);
    } else {
        echo json_encode(["success" => false, "message" => "Error resetting password"]);
    }

    $update_stmt->close();

} else {
    echo json_encode(["success" => false, "message" => "Invalid request method"]);
}

// Close the database connection
$conn->close();
?>
