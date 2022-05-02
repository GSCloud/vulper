<?php
/**
 * Vulper Bootstrap
 *
 * @author   Fred Brooker <git@gscloud.cz>
 * @license  MIT https://gscloud.cz/LICENSE
 */

use Nette\Neon\Neon;
use Tracy\Debugger;

// external include for CLI
if ('cli' === PHP_SAPI) {
    $req = getenv('CLI_REQ');
    if ($req && file_exists($req) && is_readable($req)) {
        require_once $req;
    }
}

defined('DS') || define('DS', DIRECTORY_SEPARATOR);
defined('ROOT') || define('ROOT', __DIR__ . DS . '..');
defined('WWW') || define('WWW', ROOT . DS . 'www');

// default configuration
@ini_set('auto_detect_line_endings', defined('AUTO_DETECT_LINE_ENDINGS') ? AUTO_DETECT_LINE_ENDINGS : true);
@ini_set('default_socket_timeout', defined('DEFAULT_SOCKET_TIMEOUT') ? DEFAULT_SOCKET_TIMEOUT : 30);
@ini_set('display_errors', defined('DISPLAY_ERRORS') ? DISPLAY_ERRORS : true);
@ini_set('register_argc_argv', defined('REGISTER_ARGC_ARGV') ? REGISTER_ARGC_ARGV : true);

ob_start();
error_reporting(E_ALL);

// DEFAULT TIME ZONE
date_default_timezone_set((string) ($cfg['date_default_timezone'] ?? 'Europe/Prague'));

// although not exhaustive, the possible PHP_SAPI values include: apache, apache2handler, cgi, cgi-fcgi, cli, cli-server, embed, fpm-fcgi, litespeed, phpdbg
/** @const TRUE if command line interface */
defined('CLI') || define('CLI', (bool) ('cli' === PHP_SAPI));

/** @const TRUE if running server locally */
defined('LOCALHOST') || define('LOCALHOST', (bool) ('localhost' == ($_SERVER['SERVER_NAME'] ?? '')) || CLI);

/** @const ROOT folder path */
defined('ROOT') || define('ROOT', __DIR__);

/** @const APP folder path */
defined('APP') || define('APP', ROOT . DS . 'app');

// load COMPOSER
$autoload_file = ROOT . DS . 'vendor' . DS . 'autoload.php';
if (file_exists($autoload_file) && is_readable($autoload_file)) {
    require_once $autoload_file;
} else {
    die("Missing Composer autoloader!\n");
}

// import CONFIGURATION
$cfg = null;
$config_file = APP . DS. 'config.neon';
if (file_exists($config_file) && is_readable($config_file)) {
    $cfg = Neon::decode((string) file_get_contents($config_file));
}

// import ROUTING table
$router = null;
$router_file = APP . DS . 'router.neon';
if (file_exists($router_file) && is_readable($router_file)) {
    $router = Neon::decode((string) file_get_contents($router_file));
}

if (!is_array($cfg)) {
    die("FATAL ERROR: Invalid CONFIGURATION!\n");
}
$cfg['router'] = array_merge_recursive((array) $router);

// import APP JSON CONFIGURATION
$json = null;
$json_file = APP . DS. 'env.json';
if (file_exists($json_file) && is_readable($json_file)) {
    $json = json_decode((string) file_get_contents($json_file), true);
}
$cfg['appcfg'] = $json;


// ***** TRACY DEBUGGER

// debugging OFF for CLI
if (CLI) {
    defined('DEBUG') || define('DEBUG', false);
}
// debugging options for localhost
if (LOCALHOST) {
    if (false === ($cfg['debug'] ?? null)) {
        defined('DEBUG') || define('DEBUG', false); // DISABLED via configuration
    }
    defined('DEBUG') || define('DEBUG', true); // always ENABLED for localhost
}
// disable debugger for curl connections
if (isset($_SERVER['HTTP_USER_AGENT']) && strpos($_SERVER['HTTP_USER_AGENT'], 'curl') !== false) {
    defined('DEBUG') || define('DEBUG', false);
}
// disable debugger for CLI
if (true === CLI) {
    defined('DEBUG') || define('DEBUG', false);
}

/** @const Tracy debugger on/off */
defined('DEBUG') || define('DEBUG', (bool) ($cfg['debug'] ?? false));
if (true === DEBUG) {
    // get correct remote IP address
    $address = $_SERVER['HTTP_CF_CONNECTING_IP'] ?? $_SERVER['HTTP_X_FORWARDED_FOR'] ?? $_SERVER['REMOTE_ADDR'];
    // debugging options
    $debug_cookie = (string) ($cfg['debug_cookie'] ?? '');
    $debug_email = (string) ($cfg['debug_email'] ?? '');
    // this path should be mapped to local filesystem
    $logs = (string) ($cfg['debug_logs'] ?? '/tmp/logs');

    // https://api.nette.org/tracy/master/Tracy/Debugger.html
    foreach ($cfg['tracy'] ?? null as $k => $v) {
        if (isset(Debugger::$$k)) {
            Debugger::$$k = $v;
        }
    }
    if ($debug_cookie && $debug_email && $address && $logs) {
        Debugger::enable("${debug_cookie}@${address}", $logs, $debug_email);
    } else {
        $mode = (string) ($cfg['debug_mode'] ?? '');
        switch ($mode) {
            case "dev":
                Debugger::enable(Debugger::DEVELOPMENT, $logs);
                break;
            case "prod":
                Debugger::enable(Debugger::PRODUCTION, $logs);
                break;
            default:
                Debugger::enable(Debugger::DETECT, $logs);
        }
    }
}

// measure performance
Debugger::timer('APP_START');

// app flow
if (CLI) {
    (new App\Cli($cfg, $argv ?? []))->run();
} else {
    (new App\Web($cfg))->run();
}
