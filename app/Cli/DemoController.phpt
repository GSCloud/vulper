<?php

use Tester\Assert;

defined('DS') || define('DS', DIRECTORY_SEPARATOR);
require __DIR__ . '/../../vendor/autoload.php';
Tester\Environment::setup();

$c1 = new \App\Cli\DemoController([]);
Assert::type('object', $c1);
Assert::same('this is just a simple demo', $c1->getInfoText());
Assert::same($c1, $c1->run());

$c2 = new \App\Cli\DemoController(['foo' => 'bar']);
Assert::type('object', $c2);
Assert::notsame($c1, $c2);
Assert::same($c2, $c2->run());
Assert::same($c1->getInfoText(), $c2->getInfoText());
