<?php
header("Content-Type: application/json");
require_once 'db.php';

$data = json_decode(file_get_contents("php://input"), true);

if (!$data || !isset($data['title'])) {
    http_response_code(400);
    echo json_encode(["error" => "Invalid input data"]);
    exit;
}

try {
    $conn->beginTransaction();

    // 1. Resolve ID (handle new vs existing)
    $id = isset($data['id']) && (int)$data['id'] > 1000000000 ? NULL : (isset($data['id']) ? (int)$data['id'] : NULL);
    $title = $data['title'];
    $desc = isset($data['desc']) ? $data['desc'] : '';
    $persist = isset($data['persistOnReply']) ? ($data['persistOnReply'] ? 1 : 0) : 1;
    $stop_on_reply = isset($data['stopOnReply']) ? ($data['stopOnReply'] ? 1 : 0) : 1;

    // Check if column exists to prevent crash (robustness)
    $check_col = $conn->query("SHOW COLUMNS FROM sequences LIKE 'stop_on_reply'")->fetch();
    
    if ($id) {
        if ($check_col) {
            $stmt = $conn->prepare("UPDATE sequences SET name = ?, description = ?, is_persistent = ?, stop_on_reply = ? WHERE id = ?");
            $stmt->execute([$title, $desc, $persist, $stop_on_reply, $id]);
        } else {
            $stmt = $conn->prepare("UPDATE sequences SET name = ?, description = ?, is_persistent = ? WHERE id = ?");
            $stmt->execute([$title, $desc, $persist, $id]);
        }
    } else {
        if ($check_col) {
            $stmt = $conn->prepare("INSERT INTO sequences (name, description, is_persistent, stop_on_reply) VALUES (?, ?, ?, ?)");
            $stmt->execute([$title, $desc, $persist, $stop_on_reply]);
        } else {
            $stmt = $conn->prepare("INSERT INTO sequences (name, description, is_persistent) VALUES (?, ?, ?)");
            $stmt->execute([$title, $desc, $persist]);
        }
        $id = $conn->lastInsertId();
    }

    // 2. Handle Steps
    if (isset($data['steps']) && is_array($data['steps'])) {
        // Delete existing steps
        $stmt_del = $conn->prepare("DELETE FROM sequence_steps WHERE sequence_id = ?");
        $stmt_del->execute([$id]);

        $stmt_ins = $conn->prepare("INSERT INTO sequence_steps (sequence_id, template_id, template_name, step_order, delay_value, delay_unit) VALUES (?, ?, ?, ?, ?, ?)");
        
        foreach ($data['steps'] as $index => $step) {
            // Find template_id
            $stmt_t = $conn->prepare("SELECT id, label FROM templates WHERE template_key = ?");
            $stmt_t->execute([$step['templateKey']]);
            $tmpl = $stmt_t->fetch(PDO::FETCH_ASSOC);
            
            if ($tmpl) {
                $stmt_ins->execute([
                    $id,
                    $tmpl['id'],
                    $tmpl['label'],
                    $index + 1,
                    isset($step['delay_value']) ? $step['delay_value'] : 0,
                    isset($step['delay_unit']) ? $step['delay_unit'] : 'days'
                ]);
            }
        }
    }

    $conn->commit();
    echo json_encode(["success" => true, "id" => $id]);

} catch (Exception $e) {
    if ($conn->inTransaction()) {
        $conn->rollBack();
    }
    http_response_code(500);
    echo json_encode(["error" => $e->getMessage()]);
}
?>
