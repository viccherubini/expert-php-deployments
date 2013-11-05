<?php

use Doctrine\DBAL\Configuration;
use Doctrine\DBAL\DriverManager;

use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;

require __DIR__ . '/../vendor/autoload.php';

// Include all of the configuration files into PHP array.s
$configApp = require __DIR__ . '/../app/config/config-app.php';
$configPostgres = require __DIR__ . '/../app/config/config-postgres.php';
$configRedis = require __DIR__ . '/../app/config/config-redis.php';

// Get basic HTTP request information.
$request = Request::createFromGlobals();

// Create a connection to Postgres.
$postgres = DriverManager::getConnection($configPostgres, new Configuration);

// Create a connection to Redis.
$redis = new Redis;
$redis->connect($configRedis['host'], $configRedis['port']);

// Create a Twig instance.
$loader = new Twig_Loader_Filesystem($configApp['template_path']);
$twig = new Twig_Environment($loader);

// Get the total number of raw visitors to the page.
$totalVisitors = (int)$redis->get('totalVisitors');
$redis->incr('totalVisitors');

// Save the server details to the database.
$postgres->insert('visitor_detail', [
    'created_at' => date('Y-m-d H:i:s'),
    'ip_address' => $request->getClientIp(),
    'request_method' => $request->getMethod(),
    'user_agent' => $request->server->get('HTTP_USER_AGENT')
]);

$parameters = [
    'buildDate' => $configApp['build_date']
];

echo($twig->render('index.html', $parameters));
