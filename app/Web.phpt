<?php

use Tester\Assert;

require __DIR__ . '/../vendor/autoload.php';
defined('DS') || define('DS', DIRECTORY_SEPARATOR);
Tester\Environment::setup();

$c = new \App\Web(['router' => '']);
Assert::type('object', $c);

Assert::same($c, $c->processRouting());
Assert::same($c, $c->run());
