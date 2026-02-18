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

    // Check if the input data is valid
    if (isset($input['name']) && isset($input['email']) && isset($input['password'])) {
        $name = $conn->real_escape_string($input['name']);
        $email = $conn->real_escape_string($input['email']);
        $password = $conn->real_escape_string($input['password']);

        // Hash the password before storing
        $hashed_password = password_hash($password, PASSWORD_BCRYPT);

        // Check if the email is already taken
        $email_check = $conn->query("SELECT * FROM users WHERE email = '$email'");
        if ($email_check->num_rows > 0) {
            echo json_encode(["success" => false, "message" => "Email already registered"]);
            exit();
        }

        // Prepare SQL query to insert new user data into the database
        $stmt = $conn->prepare("INSERT INTO users (name, email, password) VALUES (?, ?, ?)");
        $stmt->bind_param("sss", $name, $email, $hashed_password);

        // Execute the query
        if ($stmt->execute()) {
            echo json_encode(["success" => true, "message" => "User registered successfully"]);
        } else {
            echo json_encode(["success" => false, "message" => "Error registering user"]);
        }

        // Close the statement
        $stmt->close();
    } else {
        echo json_encode(["success" => false, "message" => "Invalid input"]);
    }
} else {
    echo json_encode(["success" => false, "message" => "Invalid request method"]);
}

// Close the database connection
$conn->close();
?>
