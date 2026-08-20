<?php
header('Content-Type: application/json; charset=utf-8');
header('Cache-Control: no-store, no-cache, must-revalidate, max-age=0');

$file = __DIR__ . '/data/content.json';
if (!file_exists($file)) {
    http_response_code(500);
    echo json_encode(['error' => 'content file missing']);
    exit;
}

$data = json_decode(file_get_contents($file), true);
$version = isset($data['version']) ? intval($data['version']) : 0;

echo json_encode([
    'ok' => true,
    'version' => $version,
    'updated_at' => $data['updated_at'] ?? null
], JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
