<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

include_once 'db.php';

$query = "SELECT id, name, phone, email, notes, status, DATE_FORMAT(created_at, '%b %d, %Y') as added_date FROM clients ORDER BY created_at DESC";
$stmt = $conn->prepare($query);
$stmt->execute();

$clients = array();

while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
    // Generate initials for the frontend
    $words = explode(" ", $row['name']);
    $initials = "";
    foreach ($words as $w) {
        $initials .= strtoupper($w[0]);
    }
    $row['initials'] = substr($initials, 0, 2);
    
    $clients[] = $row;
}

echo json_encode($clients);
?>
