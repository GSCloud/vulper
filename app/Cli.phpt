<?php

use Tester\Assert;

defined('DS') || define('DS', DIRECTORY_SEPARATOR);
require __DIR__ . '/../vendor/autoload.php';
Tester\Environment::setup();

$c = new \App\Cli([], []);
Assert::type('object', $c);
Assert::same($c, $c->processRouting());
