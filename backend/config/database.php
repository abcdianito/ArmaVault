<?php
// ============================================================
// Database connection (PDO)
// Edit the credentials below to match your local MySQL setup
// ============================================================

class Database
{
    private $host = "localhost";
    private $db_name = "firearms_db";
    private $username = "root";
    private $password = "";      // set your MySQL root password here if you have one
    public $conn;

    public function getConnection()
    {
        $this->conn = null;

        try {
            $this->conn = new PDO(
                "mysql:host=" . $this->host . ";dbname=" . $this->db_name . ";charset=utf8mb4",
                $this->username,
                $this->password
            );
            $this->conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
        } catch (PDOException $e) {
            http_response_code(500);
            echo json_encode(["success" => false, "message" => "Connection error: " . $e->getMessage()]);
            exit();
        }

        return $this->conn;
    }
}
