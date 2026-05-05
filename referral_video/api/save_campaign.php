<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST");

include_once 'db.php';

$data = json_decode(file_get_contents("php://input"));

if(!empty($data->name) && !empty($data->template_key)){
    try {
        $conn->beginTransaction();

        // 1. Get Template ID from Key
        $temp_query = "SELECT id FROM templates WHERE template_key = :key LIMIT 1";
        $temp_stmt = $conn->prepare($temp_query);
        $temp_stmt->bindParam(":key", $data->template_key);
        $temp_stmt->execute();
        $template = $temp_stmt->fetch(PDO::FETCH_ASSOC);
        $template_id = $template ? $template['id'] : 1; // Default to 1 if not found for safety

        // 2. Insert Campaign
        $query = "INSERT INTO campaigns (name, template_id, button_link, target_audience, schedule_type, status) 
                  VALUES (:name, :tid, :blink, :audience, :stype, :status)";
        
        $stmt = $conn->prepare($query);

        $stmt->bindParam(":name", $data->name);
        $stmt->bindParam(":tid", $template_id);
        $stmt->bindParam(":blink", $data->button_link);
        $stmt->bindParam(":audience", $data->target_audience);
        $stmt->bindParam(":stype", $data->schedule_type);
        $stmt->bindParam(":status", $data->status);

        $stmt->execute();
        $campaign_id = $conn->lastInsertId();

        // 3. Insert Deliveries if starting now
        if(!empty($data->client_ids)){
            $delivery_query = "INSERT INTO campaign_deliveries (campaign_id, client_id, status) VALUES (:cid, :clid, 'Pending')";
            $delivery_stmt = $conn->prepare($delivery_query);
            
            foreach($data->client_ids as $client_id){
                $delivery_stmt->bindParam(":cid", $campaign_id);
                $delivery_stmt->bindParam(":clid", $client_id);
                $delivery_stmt->execute();
            }
        }

        $conn->commit();
        echo json_encode(array("message" => "Campaign saved.", "id" => $campaign_id));

    } catch (Exception $e) {
        $conn->rollBack();
        echo json_encode(array("message" => "Error: " . $e->getMessage()));
    }
} else {
    echo json_encode(array("message" => "Incomplete data."));
}
?>
