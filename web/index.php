<?php

use Doctrine\DBAL\Configuration;
use Doctrine\DBAL\DriverManager;

use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;

#echo $request->getPathInfo();

require __DIR__ . '/../vendor/autoload.php';
require __DIR__ . '/../config/app/config.php';

// Get basic HTTP request information.
$request = Request::createFromGlobals();

// Create a connection to Postgres.
#$postgres = new PDO(DB_DSN);

// Create a connection to Redis.
$redis = new Redis;
$redis->connect(REDIS_HOST, REDIS_PORT);

// Create a Twig instance.
$loader = new Twig_Loader_Filesystem(TEMPLATE_PATH);
$twig = new Twig_Environment($loader);

// Get the total number of raw visitors to the page.
$totalVisitors = (int)$redis->get('totalVisitors');
$redis->incr('totalVisitors');

// Save the server details to the database.
/*$datetime = date('Y-m-d H:i:s');
$status = 1;
$query = "INSERT INTO visitor_detail (
        created_at, updated_at, status, ip_address,
        request_method, user_agent
    ) VALUES (
        ?, ?, ?, ?,
        ?, ?
    )";

$parameters = [
    1 => $datetime,
    2 => $datetime,
    3 => $status,
    4 => '',
    5 => '',
    6 => ''
];

$stmt = $postgres->prepare($query);
$stmt->execute($parameters);*/

$parameters = [
    'totalVisitors' => $totalVisitors
];

echo $twig->render('index.html', $parameters);
