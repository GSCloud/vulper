<?php

namespace App\Cli;

use League\CLImate\CLImate;

class DemoController
{
    /**
     * @param array<mixed> $cfg
     */
    public function __construct(
        private array $cfg
    ) {
    }

    /**
     * CLI help information.
     *
     * @return string
     */
    public function getInfoText(): string
    {
        bdump($this->cfg); // do something meaningful with the configuration
        return 'this is just a simple demo';
    }

    /**
     * @return self
     */
    public function run(): object
    {
        $climate = new CLImate();
        $climate->out("Hello command line!");
        return $this;
    }
}
