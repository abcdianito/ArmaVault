<?php
// DELETE /api/delete.php?id=1  -> delete a firearm record

include_once __DIR__ . '/../config/cors.php';
include_once __DIR__ . '/../config/database.php';

$database = new Database();
$db = $database->getConnection();

$id = $_GET['id'] ?? null;

if (!$id) {
    $data = json_decode(file_get_contents("php://input"));
    $id = $data->id ?? null;
}

if (!$id) {
    http_response_code(400);
    echo json_encode(["success" => false, "message" => "Missing id."]);
    exit();
}

$query = "DELETE FROM firearms WHERE id = :id";
$stmt = $db->prepare($query);
$stmt->bindParam(':id', $id);

if ($stmt->execute()) {
    http_response_code(200);
    echo json_encode(["success" => true, "message" => "Firearm deleted."]);
} else {
    http_response_code(500);
    echo json_encode(["success" => false, "message" => "Failed to delete firearm."]);
}
