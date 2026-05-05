<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

include_once 'db.php';

$query = "SELECT template_key as `key`, label, category, body FROM templates WHERE status = 'Active'";
$stmt = $conn->prepare($query);
$stmt->execute();

$templates = array();

while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
    $templates[] = $row;
}

echo json_encode($templates);
?>
