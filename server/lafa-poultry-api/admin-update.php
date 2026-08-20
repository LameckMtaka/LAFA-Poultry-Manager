<?php
/*
  Simple authenticated content updater for LAFA Poultry v5.5.
  IMPORTANT:
  1. Change LAFA_ADMIN_API_KEY below before uploading.
  2. Prefer placing this endpoint behind HTTPS.
  3. For production, move the key to an environment variable or config file outside public web root.
*/
header('Content-Type: application/json; charset=utf-8');

const LAFA_ADMIN_API_KEY = 'CHANGE_THIS_TO_A_LONG_RANDOM_SECRET';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['ok' => false, 'error' => 'POST required']);
    exit;
}

$key = $_SERVER['HTTP_X_LAFA_API_KEY'] ?? '';
if (!hash_equals(LAFA_ADMIN_API_KEY, $key)) {
    http_response_code(401);
    echo json_encode(['ok' => false, 'error' => 'unauthorized']);
    exit;
}

$raw = file_get_contents('php://input');
$incoming = json_decode($raw, true);
if (!is_array($incoming) || !isset($incoming['items']) || !is_array($incoming['items'])) {
    http_response_code(400);
    echo json_encode(['ok' => false, 'error' => 'invalid payload']);
    exit;
}

$dataFile = __DIR__ . '/data/content.json';
$current = file_exists($dataFile) ? json_decode(file_get_contents($dataFile), true) : [];
$currentVersion = intval($current['version'] ?? 0);

$payload = [
    'version' => $currentVersion + 1,
    'updated_at' => date(DATE_ATOM),
    'items' => $incoming['items']
];

if (!is_dir(dirname($dataFile))) {
    mkdir(dirname($dataFile), 0755, true);
}

$ok = file_put_contents(
    $dataFile,
    json_encode($payload, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES),
    LOCK_EX
);

if ($ok === false) {
    http_response_code(500);
    echo json_encode(['ok' => false, 'error' => 'write failed']);
    exit;
}

echo json_encode(['ok' => true, 'version' => $payload['version'], 'items' => count($payload['items'])]);
