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

    // Validate input — email is required
    if (!isset($input['email']) || empty($input['email'])) {
        echo json_encode(["success" => false, "message" => "Email is required"]);
        exit();
    }

    $email = $conn->real_escape_string($input['email']);

    // Check if the email exists in the database
    $stmt = $conn->prepare("SELECT id FROM users WHERE email = ?");
    $stmt->bind_param("s", $email);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($result->num_rows === 0) {
        echo json_encode(["success" => false, "message" => "Email not found"]);
        $stmt->close();
        $conn->close();
        exit();
    }

    $user = $result->fetch_assoc();
    $stmt->close();

    // Default password set karo — 12345678
    $default_password = "12345678";
    $hashed_password = password_hash($default_password, PASSWORD_BCRYPT);

    // Update user's password to default
    $update_stmt = $conn->prepare("UPDATE users SET password = ? WHERE email = ?");
    $update_stmt->bind_param("ss", $hashed_password, $email);

    if ($update_stmt->execute()) {
        echo json_encode([
            "success" => true,
            "message" => "Password has been reset to default (12345678)"
        ]);
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
