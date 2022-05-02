<?php

use Tester\Assert;

require __DIR__ . '/../../vendor/autoload.php';
defined('DS') || define('DS', DIRECTORY_SEPARATOR);
Tester\Environment::setup();

$c1 = new \App\Cli\DemoController([]);
Assert::type('object', $c1);
Assert::same('this is just a simple demo', $c1->getInfoText());
Assert::same($c1, $c1->run());

$c2 = new \App\Cli\DemoController(['foo' => 'bar']);
Assert::type('object', $c2);
Assert::notsame($c1, $c2);
