<?php
// /var/www/html/api/whoami.php
header('Content-Type: application/json');
header("X-Served-By: " . trim(shell_exec('hostname')));

echo json_encode([
    'hostname' => trim(shell_exec('hostname')),
    'ip' => $_SERVER['SERVER_ADDR'] ?? 'unknown',
    'timestamp' => date('c')
]);
?>