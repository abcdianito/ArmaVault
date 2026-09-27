<?php
// GET /api/read.php  -> list all firearms

include_once __DIR__ . '/../config/cors.php';
include_once __DIR__ . '/../config/database.php';

$database = new Database();
$db = $database->getConnection();

$query = "SELECT id,
       name,
       manufacturer,
       country_of_origin,
       firearm_type,
       caliber,
       year_introduced,
       weight_kg,
       barrel_length_cm,
       magazine_capacity,
       description,
       image_url,
       created_at,
       updated_at
FROM firearms
          ORDER BY id DESC";

$stmt = $db->prepare($query);
$stmt->execute();

$firearms = $stmt->fetchAll(PDO::FETCH_ASSOC);

http_response_code(200);
echo json_encode([
    "success" => true,
    "count" => count($firearms),
    "data" => $firearms
]);
