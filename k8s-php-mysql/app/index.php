<?php
 $host = getenv('MYSQL_HOST') ?: 'mysql-service';
 $user = getenv('MYSQL_USER') ?: 'root';
 $pass = getenv('MYSQL_PASSWORD') ?: 'rootpassword';
 $db = getenv('MYSQL_DATABASE') ?: 'testdb';

 try{
    $conn = new PDO("mysql:host=$host;dbname=$db", $user, $pass);
    echo json_encode([
        "status" => "ok",
        "message" => "Connected to MySQL successfully!"
    ]);
 }catch(PDOException $e){
    echo json_encode([
        "status" => "error",
        "message" => $e->getMessage()
    ]);
 }