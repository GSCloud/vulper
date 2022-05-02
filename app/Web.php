<?php

namespace App;

use Tracy\Debugger;

class Web
{
    /**
     * @param array<mixed> $cfg
     */
    public function __construct(
        // PHPStan: make $cfg readonly - fails now!)
        // private readonly array $cfg
        private array $cfg
    ) {
    }

    /**
     * Run the app.
     *
     * @return self
     */
    public function run(): self
    {
        $this->processRouting();
        $this->finish();
        return $this;
    }

    /**
     * Process routing table.
     *
     * @return self
     */
    public function processRouting(): self
    {
        //dump($this->cfg['router']);
        return $this;
    }

    /**
     * Finish the runtime: send extra headers and debugging info.
     *
     * @return self
     */
    private function finish(): self
    {
        dump($this->cfg);

        // debugger timer in microseconds
        $runTime = round(Debugger::timer('APP_START') * 1000, 2);
        header('X-running-time: '. $runTime . ' ms');
        return $this;
    }
}
