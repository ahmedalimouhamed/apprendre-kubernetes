<?php
$host = getenv('MYSQL_HOST') ?: 'mysql-service';
$user = 'root';
$pass =getenv('MYSQL_ROOT_PASSWORD') ?: 'root';
$db = 'app_db';

$conn = new mysqli($host, $user, $pass, $db);

if ($conn->connect_error) { 
    http_response_code(500);
    die("MYSQL connection failed: " . $conn->connect_error);
}

echo json_encode([
    "status" => "ok",
    "message" => "Connected to MySQL",
    "timestamp" => date("Y-m-d H:i:s")
]);