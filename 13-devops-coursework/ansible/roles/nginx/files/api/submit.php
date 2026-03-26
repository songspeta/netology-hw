<?php
// /var/www/html/api/submit.php
header('Content-Type: application/json');
header("X-Served-By: " . trim(shell_exec('hostname')));

// Лог файл
$logFile = '/var/log/submissions.log';

// Получаем данные
$input = json_decode(file_get_contents('php://input'), true);
$event = $input['event'] ?? 'form_submit';
$timestamp = date('Y-m-d H:i:s');
$hostname = trim(shell_exec('hostname'));
$ip = $_SERVER['REMOTE_ADDR'] ?? 'unknown';

// Пишем в лог
$logEntry = sprintf("%s | %s | %s | %s\n", $timestamp, $hostname, $ip, $event);
file_put_contents($logFile, $logEntry, FILE_APPEND | LOCK_EX);

// Ответ
http_response_code(200);
echo json_encode(['status' => 'ok', 'message' => 'Logged']);
?>