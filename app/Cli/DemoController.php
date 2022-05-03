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
        return 'this is just a simple demo';
    }

    /**
     * @return self
     */
    public function run(): object
    {
        dump($this->cfg['site'] ?? []); // do something meaningful
        $climate = new CLImate();
        $climate->out("Hello command line!");
        return $this;
    }
}
