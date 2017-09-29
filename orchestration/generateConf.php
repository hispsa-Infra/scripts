<?php
 
require 'vendor/autoload.php';
 
require_once('Connection.php');

try {
    Connection::get()->connect();
    echo 'A connection to the PostgreSQL database sever has been established successfully.';
} catch (\PDOException $e) {
    echo $e->getMessage();
}