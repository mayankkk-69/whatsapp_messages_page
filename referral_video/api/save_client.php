<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST");

include_once 'db.php';

$data = json_decode(file_get_contents("php://input"));

if(!empty($data->name) && !empty($data->phone)){
    $query = "INSERT INTO clients (name, phone, email, notes) VALUES (:name, :phone, :email, :notes)";
    $stmt = $conn->prepare($query);

    $stmt->bindParam(":name", $data->name);
    $stmt->bindParam(":phone", $data->phone);
    $stmt->bindParam(":email", $data->email);
    $stmt->bindParam(":notes", $data->notes);

    if($stmt->execute()){
        $new_id = $conn->lastInsertId();
        
        // Handle tags if provided
        if(!empty($data->tags)){
            foreach($data->tags as $tag_name){
                // Find tag id
                $tag_query = "SELECT id FROM tags WHERE name = :tag_name";
                $tag_stmt = $conn->prepare($tag_query);
                $tag_stmt->bindParam(":tag_name", $tag_name);
                $tag_stmt->execute();
                $tag_row = $tag_stmt->fetch(PDO::FETCH_ASSOC);
                
                if($tag_row){
                    $link_query = "INSERT INTO client_tags (client_id, tag_id) VALUES (:client_id, :tag_id)";
                    $link_stmt = $conn->prepare($link_query);
                    $link_stmt->bindParam(":client_id", $new_id);
                    $link_stmt->bindParam(":tag_id", $tag_row['id']);
                    $link_stmt->execute();
                }
            }
        }

        echo json_encode(array("message" => "Client was created.", "id" => $new_id));
    } else {
        echo json_encode(array("message" => "Unable to create client."));
    }
} else {
    echo json_encode(array("message" => "Incomplete data."));
}
?>
