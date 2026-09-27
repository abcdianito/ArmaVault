<?php
// PUT /api/update.php  -> update a firearm record
// Body (JSON) must include: id, plus any fields to update

include_once __DIR__ . '/../config/cors.php';
include_once __DIR__ . '/../config/database.php';

$database = new Database();
$db = $database->getConnection();

$data = json_decode(file_get_contents("php://input"));

if (empty($data->id)) {
    http_response_code(400);
    echo json_encode(["success" => false, "message" => "Missing id."]);
    exit();
}

$query = "UPDATE firearms SET
            name = :name,
            manufacturer = :manufacturer,
            country_of_origin = :country_of_origin,
            firearm_type = :firearm_type,
            caliber = :caliber,
            year_introduced = :year_introduced,
            weight_kg = :weight_kg,
            barrel_length_cm = :barrel_length_cm,
            magazine_capacity = :magazine_capacity,
            description = :description,
            image_url = :image_url
          WHERE id = :id";

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
$stmt->bindValue(':id', $data->id);

if ($stmt->execute()) {
    http_response_code(200);
    echo json_encode(["success" => true, "message" => "Firearm updated."]);
} else {
    http_response_code(500);
    echo json_encode(["success" => false, "message" => "Failed to update firearm."]);
}
