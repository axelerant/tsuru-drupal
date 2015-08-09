<?php
$databases = array (
  'default' =>
  array (
    'default' =>
    array (
      'driver' => 'mysql',
      'username' => getenv('MYSQL_USER'),
      'password' => getenv('MYSQL_PASSWORD'),
      'port' => '',
      'host' => getenv('MYSQL_HOST'),
      'database' => getenv('MYSQL_DATABASE_NAME'),
    ),
  ),
);
