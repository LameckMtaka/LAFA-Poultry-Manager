<?php
/*
 Basic single-file Cloud Content Admin.
 Change the password and API key before production use.
*/
session_start();

const ADMIN_PASSWORD = 'CHANGE_THIS_ADMIN_PASSWORD';
const API_KEY = 'CHANGE_THIS_TO_THE_SAME_KEY_AS_ADMIN_UPDATE';

if (isset($_POST['logout'])) {
    session_destroy();
    header('Location: admin-panel.php');
    exit;
}

if (!isset($_SESSION['lafa_admin'])) {
    if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['password'])) {
        if (hash_equals(ADMIN_PASSWORD, $_POST['password'])) {
            $_SESSION['lafa_admin'] = true;
            header('Location: admin-panel.php');
            exit;
        }
        $error = 'Invalid password';
    }
    ?>
    <!doctype html><html><head><meta charset="utf-8"><title>LAFA Poultry Cloud Admin</title>
    <style>body{font-family:Arial;background:#eef5f0;display:grid;place-items:center;height:100vh}.box{background:#fff;padding:30px;border-radius:18px;box-shadow:0 12px 35px #0002;width:min(420px,90vw)}input,button{width:100%;padding:12px;margin-top:10px;box-sizing:border-box}button{background:#176b43;color:#fff;border:0;border-radius:10px;font-weight:bold}</style></head>
    <body><form class="box" method="post"><h2>LAFA Poultry Cloud Admin</h2><?php if(!empty($error)) echo "<p style='color:red'>$error</p>"; ?><input type="password" name="password" placeholder="Admin password" required><button>Login</button></form></body></html>
    <?php exit;
}

$dataFile = __DIR__ . '/data/content.json';
$data = file_exists($dataFile) ? json_decode(file_get_contents($dataFile), true) : ['version'=>0,'items'=>[]];

if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['save_json'])) {
    $decoded = json_decode($_POST['content_json'], true);
    if (!is_array($decoded)) {
        $message = 'Invalid JSON';
    } else {
        $payload = ['items' => $decoded['items'] ?? $decoded];
        $ch = curl_init();
        $url = (isset($_SERVER['HTTPS']) ? 'https' : 'http') . '://' . $_SERVER['HTTP_HOST'] . dirname($_SERVER['REQUEST_URI']) . '/admin-update.php';
        curl_setopt_array($ch, [
            CURLOPT_URL => $url,
            CURLOPT_POST => true,
            CURLOPT_POSTFIELDS => json_encode($payload),
            CURLOPT_HTTPHEADER => ['Content-Type: application/json','X-LAFA-API-KEY: '.API_KEY],
            CURLOPT_RETURNTRANSFER => true
        ]);
        $resp = curl_exec($ch);
        curl_close($ch);
        $message = $resp ?: 'No response';
        $data = json_decode(file_get_contents($dataFile), true);
    }
}
?>
<!doctype html>
<html>
<head>
<meta charset="utf-8">
<title>LAFA Poultry Cloud Admin</title>
<style>
body{font-family:Arial;margin:0;background:#f3f7f4;color:#163329}
header{background:linear-gradient(135deg,#073b2a,#218b59);color:#fff;padding:22px}
main{max-width:1100px;margin:auto;padding:20px}
.card{background:#fff;border-radius:18px;padding:18px;box-shadow:0 8px 25px #00000012}
textarea{width:100%;height:520px;padding:12px;box-sizing:border-box;font-family:monospace;border:1px solid #ccd9d0;border-radius:12px}
button{padding:12px 18px;background:#176b43;color:#fff;border:0;border-radius:10px;font-weight:bold}
.top{display:flex;justify-content:space-between;align-items:center;gap:12px}
small{opacity:.8}
</style>
</head>
<body>
<header><div class="top"><div><h2>LAFA Poultry Cloud Admin</h2><small>Content version <?=htmlspecialchars($data['version'] ?? 0)?></small></div><form method="post"><button name="logout">Logout</button></form></div></header>
<main>
<?php if(!empty($message)) echo "<div class='card' style='margin-bottom:12px'><pre>".htmlspecialchars($message)."</pre></div>"; ?>
<form class="card" method="post">
<h3>Cloud Content JSON</h3>
<p>Edit content and save. The version increments automatically, and mobile apps can sync the new content.</p>
<textarea name="content_json"><?=htmlspecialchars(json_encode(['items'=>$data['items'] ?? []], JSON_PRETTY_PRINT|JSON_UNESCAPED_UNICODE|JSON_UNESCAPED_SLASHES))?></textarea>
<br><br><button name="save_json">Publish Cloud Update</button>
</form>
</main>
</body>
</html>
