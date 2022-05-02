<?php

namespace App;

use League\CLImate\CLImate;
use Tracy\Debugger;

class Cli
{
    /**
     * @param array<mixed> $cfg
     * @param array<string> $argv
     */
    public function __construct(
        // PHPStan - make $cfg readonly (now fails!)
        private array $cfg,
        private array $argv
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
     * Process the routing table.
     *
     * @return self
     */
    public function processRouting()
    {
        // NO ARGUMENTS
        // => display getInfoText() for all controllers in Cli/ folder
        if (count($this->argv) === 1) {
            $climate = new CLImate();
            $climate->out("<green><bold>CLI parameters</bold></green>\n");
            $reflector = new \ReflectionClass('\App\Cli');
            $filename = $reflector->getFileName();
            if ($filename) {
                $filedir = dirname($filename);
                if (strlen($filedir)) {
                    $searchdir = $filedir . DS . 'Cli' . DS;
                    $results = glob("${searchdir}*Controller.php");
                    if (is_array($results)) {
                        foreach ($results as $f) {
                            $class = str_replace('.php', '', basename($f));
                            $param = strtolower(str_replace('Controller', '', $class));
                            $controller = '\App\Cli\\' . $class;
                            if (class_exists($controller)) {
                                if (method_exists($controller, 'getInfoText')) {
                                    /** @phpstan-ignore-next-line */
                                    $climate->out("<bold>$param</bold>\t- " . (new $controller($this->cfg))->getInfoText());
                                }
                            }
                        }
                    }
                }
            }
        }

        // AT LEAST 1 ARGUMENT
        if (count($this->argv) > 1) {
            $controller = '\App\Cli\\' . ucfirst(strtolower($this->argv[1])) . 'Controller';
            if (class_exists($controller)) {
                /** @phpstan-ignore-next-line */
                (new $controller($this->cfg))->run();
            }
        }
        bdump($this->cfg);
        return $this;
    }

    /**
     * Finish the runtime.
     *
     * @return void
     */
    private function finish()
    {
        $climate = new CLImate();
        // timer in microseconds
        $runTime = round(Debugger::timer('APP_START') * 1000, 2);
        $climate->out("\nRunning time: <bold>$runTime ms</bold>");
    }
}
