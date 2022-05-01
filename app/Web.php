<?php

namespace App;

use Tracy\Debugger;

class Web
{
    /**
     * @param array<mixed> $cfg
     */
    public function __construct(
        // PHPStan - make $cfg readonly (now fails!)
        private array $cfg
    ) {
    }

    /**
     * Run the app.
     *
     * @return void
     */
    public function run()
    {
        $this->processRouting();
        $this->finish();
    }

    /**
     * Process routing table.
     *
     * @return self
     */
    public function processRouting()
    {
        dump($this->cfg['router']);
        return $this;
    }

    /**
     * Finish the runtime: send extra headers and debugging info.
     *
     * @return void
     */
    private function finish()
    {
        bdump($this->cfg);

        // debugger timer in microseconds
        $runTime = round(Debugger::timer('APP_START') * 1000, 2);
        header('X-running-time: '. $runTime . ' ms');
    }
}
