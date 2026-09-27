<?php
// GET /api/read_single.php?id=1  -> single firearm

include_once __DIR__ . '/../config/cors.php';
include_once __DIR__ . '/../config/database.php';

$database = new Database();
$db = $database->getConnection();

if (!isset($_GET['id'])) {
    http_response_code(400);
    echo json_encode(["success" => false, "message" => "Missing id parameter."]);
    exit();
}

$query = "SELECT * FROM firearms WHERE id = :id LIMIT 1";
$stmt = $db->prepare($query);
$stmt->bindParam(':id', $_GET['id']);
$stmt->execute();

$firearm = $stmt->fetch(PDO::FETCH_ASSOC);

if ($firearm) {
    http_response_code(200);
    echo json_encode(["success" => true, "data" => $firearm]);
} else {
    http_response_code(404);
    echo json_encode(["success" => false, "message" => "Firearm not found."]);
}
