<?php
// POST /api/create.php  -> create a firearm record
// Body (JSON): name, manufacturer, country_of_origin, firearm_type, caliber,
//              year_introduced, weight_kg, barrel_length_cm, magazine_capacity,
//              description, image_url

include_once __DIR__ . '/../config/cors.php';
include_once __DIR__ . '/../config/database.php';

$database = new Database();
$db = $database->getConnection();

$data = json_decode(file_get_contents("php://input"));

// Basic server-side validation
if (empty($data->name) || empty($data->manufacturer) || empty($data->country_of_origin)
    || empty($data->firearm_type) || empty($data->caliber)) {
    http_response_code(400);
    echo json_encode(["success" => false, "message" => "Missing required fields."]);
    exit();
}

$query = "INSERT INTO firearms
            (name, manufacturer, country_of_origin, firearm_type, caliber,
             year_introduced, weight_kg, barrel_length_cm, magazine_capacity,
             description, image_url)
          VALUES
            (:name, :manufacturer, :country_of_origin, :firearm_type, :caliber,
             :year_introduced, :weight_kg, :barrel_length_cm, :magazine_capacity,
             :description, :image_url)";

$stmt = $db->prepare($query);

$stmt->bindValue(':name', $data->name);
$stmt->bindValue(':manufacturer', $data->manufacturer);
$stmt->bindValue(':country_of_origin', $data->country_of_origin);
$stmt->bindValue(':firearm_type', $data->firearm_type);
$stmt->bindValue(':caliber', $data->caliber);
$stmt->bindValue(':year_introduced', $data->year_introduced ?? null);
$stmt->bindValue(':weight_kg', $data->weight_kg ?? null);
$stmt->bindValue(':barrel_length_cm', $data->barrel_length_cm ?? null);
$stmt->bindValue(':magazine_capacity', $data->magazine_capacity ?? null);
$stmt->bindValue(':description', $data->description ?? null);
$stmt->bindValue(':image_url', $data->image_url ?? null);

if ($stmt->execute()) {
    http_response_code(201);
    echo json_encode([
        "success" => true,
        "message" => "Firearm created.",
        "id" => $db->lastInsertId()
    ]);
} else {
    http_response_code(500);
    echo json_encode(["success" => false, "message" => "Failed to create firearm."]);
}
