<?php
/**
 * AUTOMATION ENGINE: process_sequence_queue.php
 * This script handles the chronological execution of drip sequences.
 * Should be triggered by a CRON JOB every hour.
 */
require_once 'db.php';

// Ensure script doesn't time out if queue is large
set_time_limit(300);

try {
    // 1. Fetch all 'Running' subscriptions that are due (next_send_at <= now)
    $stmt = $conn->prepare("
        SELECT 
            sub.id as sub_id, sub.client_id, sub.client_name, sub.client_phone, sub.sequence_id, sub.current_step_id,
            seq.name as sequence_name, seq.stop_on_reply,
            step.template_id, step.template_name, step.step_order, step.delay_value, step.delay_unit
        FROM sequence_subscriptions sub
        JOIN sequences seq ON sub.sequence_id = seq.id
        JOIN sequence_steps step ON sub.current_step_id = step.id
        WHERE sub.status = 'Running' AND sub.next_send_at <= NOW()
    ");
    $stmt->execute();
    $pending = $stmt->fetchAll(PDO::FETCH_ASSOC);

    $processed_count = 0;

    foreach ($pending as $item) {
        $sub_id = $item['sub_id'];
        
        // --- 2. WHATSAPP API INTEGRATION POINT ---
        // Here you would call your WhatsApp API (e.g., Meta Cloud API or Third Party)
        // For now, we simulate a successful send
        $send_status = true; 

        if ($send_status) {
            // 3. Log the successful delivery to History
            $log_data = [
                "client" => $item['client_name'],
                "phone" => $item['client_phone'],
                "template" => $item['template_name'],
                "sequence" => $item['sequence_name'],
                "step" => $item['step_order']
            ];
            
            $log_stmt = $conn->prepare("INSERT INTO user_activities 
                (activity_type, severity, page_name, field_name, resource_id, activity_data) 
                VALUES ('Sequence Delivery', 'info', 'automation', ?, ?, ?)");
            $log_stmt->execute([
                $item['client_name'],
                $item['sequence_id'],
                json_encode($log_data)
            ]);

            // 4. Find the NEXT step in the timeline
            $next_stmt = $conn->prepare("SELECT id, step_order, delay_value, delay_unit 
                                       FROM sequence_steps 
                                       WHERE sequence_id = ? AND step_order > ? 
                                       ORDER BY step_order ASC LIMIT 1");
            $next_stmt->execute([$item['sequence_id'], $item['step_order']]);
            $next_step = $next_stmt->fetch(PDO::FETCH_ASSOC);

            if ($next_step) {
                // Schedule the next message based on the delay
                $val = $next_step['delay_value'];
                $unit = $next_step['delay_unit']; // days, weeks, months
                $next_at = date('Y-m-d H:i:s', strtotime("+$val $unit"));

                $upd = $conn->prepare("UPDATE sequence_subscriptions SET 
                                      current_step_id = ?, 
                                      next_send_at = ?,
                                      last_sent_at = NOW() 
                                      WHERE id = ?");
                $upd->execute([$next_step['id'], $next_at, $sub_id]);
            } else {
                // End of the road - Mark loop as completed for this client
                $upd = $conn->prepare("UPDATE sequence_subscriptions SET 
                                      status = 'Completed', 
                                      last_sent_at = NOW(),
                                      next_send_at = NULL 
                                      WHERE id = ?");
                $upd->execute([$sub_id]);
            }
            $processed_count++;
        }
    }

    header("Content-Type: application/json");
    echo json_encode([
        "success" => true,
        "processed" => $processed_count,
        "message" => "Automation tick completed. $processed_count messages processed."
    ]);

} catch (PDOException $e) {
    header("Content-Type: application/json", true, 500);
    echo json_encode(["error" => $e->getMessage()]);
}
?>
