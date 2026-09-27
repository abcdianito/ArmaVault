<?php
// ============================================================
// image_proxy.php
// Fetches an external image URL server-side and streams it back
// with permissive CORS headers, so Flutter Web (CanvasKit) can
// decode it. Needed because most image hosts do NOT send
// Access-Control-Allow-Origin, which silently breaks
// Image.network() in the browser even though the URL itself
// is perfectly valid.
// ============================================================

$url = $_GET['url'] ?? '';

if (!$url || !filter_var($url, FILTER_VALIDATE_URL) || !preg_match('/^https?:\/\//i', $url)) {
    http_response_code(400);
    header('Content-Type: application/json');
    echo json_encode(['success' => false, 'message' => 'Missing or invalid url parameter']);
    exit();
}

$ch = curl_init($url);
curl_setopt_array($ch, [
    CURLOPT_RETURNTRANSFER => true,
    CURLOPT_FOLLOWLOCATION => true,
    CURLOPT_MAXREDIRS      => 5,
    CURLOPT_TIMEOUT        => 10,
    CURLOPT_SSL_VERIFYPEER => true,
    CURLOPT_USERAGENT      => 'Mozilla/5.0 (FirearmsCatalogApp image proxy)',
]);

$data = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
$contentType = curl_getinfo($ch, CURLINFO_CONTENT_TYPE);
$error = curl_error($ch);
curl_close($ch);

if ($data === false || $httpCode >= 400) {
    http_response_code(502);
    header('Content-Type: application/json');
    echo json_encode(['success' => false, 'message' => 'Could not fetch image', 'detail' => $error, 'http_code' => $httpCode]);
    exit();
}

// Only allow actual images through
if (!$contentType || strpos($contentType, 'image/') !== 0) {
    http_response_code(415);
    header('Content-Type: application/json');
    echo json_encode(['success' => false, 'message' => 'URL did not return an image', 'content_type' => $contentType]);
    exit();
}

header('Access-Control-Allow-Origin: *');
header('Content-Type: ' . $contentType);
header('Cache-Control: public, max-age=86400'); // cache 1 day, avoids re-fetching every rebuild
echo $data;
