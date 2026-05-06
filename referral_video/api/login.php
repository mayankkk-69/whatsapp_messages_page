<?php
session_start();
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST");

include_once 'db.php';

$data = json_decode(file_get_contents("php://input"));

if (empty($data->email) || empty($data->password)) {
    echo json_encode(["success" => false, "message" => "Email and password are required."]);
    exit;
}

try {
    $query = "SELECT id, name, email, password, role FROM users WHERE email = :email AND is_active = 1";
    $stmt  = $conn->prepare($query);
    $stmt->bindParam(":email", $data->email);
    $stmt->execute();
    $user  = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($user && password_verify($data->password, $user['password'])) {
        // Store in session
        $_SESSION['user_id']   = $user['id'];
        $_SESSION['user_name'] = $user['name'];
        $_SESSION['user_email']= $user['email'];
        $_SESSION['user_role'] = $user['role'];

        // Update last_login timestamp
        $upd = $conn->prepare("UPDATE users SET last_login = NOW() WHERE id = :id");
        $upd->bindParam(":id", $user['id']);
        $upd->execute();

        // Log the activity
        $act = $conn->prepare("INSERT INTO user_activities (activity_type, page_name, activity_data, ip_address, user_agent) VALUES ('Login', 'login', :data, :ip, :ua)");
        $act_data = json_encode(["name" => $user['name'], "email" => $user['email']]);
        $ip = $_SERVER['REMOTE_ADDR'];
        $ua = $_SERVER['HTTP_USER_AGENT'];
        $act->bindParam(":data", $act_data);
        $act->bindParam(":ip", $ip);
        $act->bindParam(":ua", $ua);
        $act->execute();

        echo json_encode([
            "success" => true,
            "message" => "Login successful.",
            "user" => [
                "id"    => $user['id'],
                "name"  => $user['name'],
                "email" => $user['email'],
                "role"  => $user['role']
            ]
        ]);
    } else {
        echo json_encode(["success" => false, "message" => "Invalid email or password."]);
    }
} catch (Exception $e) {
    echo json_encode(["success" => false, "message" => "Server error: " . $e->getMessage()]);
}
?>
