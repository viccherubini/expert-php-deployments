<?php

require __DIR__ . '/../vendor/autoload.php';
require __DIR__ . '/../config/config.php';

// Create a connection to Postgres.
$postgres = new PDO(DB_DSN);

// Create a connection to Redis.
$redis = new Redis;
$redis->connect(REDIS_HOST, REDIS_PORT);

?>
<!doctype html>
<html>
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
    <meta name="viewport" content="width=device-width">

    <title>Expert PHP Deployments Sample Application</title>

    <link rel="stylesheet" href="/assets/css/expertphpdeployments.css">
</head>
<body>
    <?php
    // Get the total number of raw visitors to the page.
    $totalVisitors = (int)$redis->get('totalVisitors');
    $redis->incr('totalVisitors');

    // Save the server details to the database.
    $query = "INSERT INTO visitor_detail (
            created_at, updated_at, status, ip_address,
            request_method, user_agent
        ) VALUES (
            CURRENT_TIMESTAMP(0), CURRENT_TIMESTAMP(0), 1, ?,
            ?, ?
        )";

    $stmt = $postgres->prepare($query);
    $stmt->bindValue(1, $_SERVER['REMOTE_ADDR']);
    $stmt->bindValue(2, $_SERVER['REQUEST_METHOD']);
    $stmt->bindValue(3, $_SERVER['HTTP_USER_AGENT']);
    $stmt->execute();
    ?>

    <div id="wrapper">
        <h1>Welcome to the <em>Expert PHP Deployments</em> Sample Application</h1>
        <p>
            There have been <strong><?php echo($totalVisitors); ?></strong> visitors here before you.
        </p>

        <h2>Your Details</h2>
        <ul>
            <li>
                <strong>IP Address</strong>: <?php echo($_SERVER['REMOTE_ADDR']); ?>
            </li>
            <li>
                <strong>Request Method</strong>: <?php echo($_SERVER['REQUEST_METHOD']); ?>
            </li>
            <li>
                <strong>User Agent</strong>: <?php echo($_SERVER['HTTP_USER_AGENT']); ?>
            </li>
        </ul>

        <p class="no-margin" align="center">
            <a href="http://brightmarch.com/expert-php-deployments/">Purchase the <em><strong>Expert PHP Deployments</strong></em> Book</a>
        </p>
    </div>

</body>
</html>
