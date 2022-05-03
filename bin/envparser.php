<?php
declare(strict_types=1);

// pass file to be parsed as first argument
if ($argc == 2) {
    $f = $argv[1];
    if (file_exists($f) && is_readable($f)) {
        $arr = file($f);
        $arr = array_map('trim', $arr);
        $arr = array_map(function ($s) {
            preg_match('/([a-zA-Z0-9_@$%^&* \-\.,:\/="\']+)/', $s, $matches);
            if ($matches && strpos($matches[1], '=') !== false) {
                return $matches[1];
            }
        }, $arr);
        $arr = array_map('trim', $arr);
        $arr = array_filter($arr);
        $res = [];
        foreach($arr as $s) {
            $x = explode('=', $s);
            $y = trim($x[1], '"\'');
            if (is_numeric($y)) {
                $y = (int) $y;
            }
            $res[$x[0]] = $y;
        }
        //echo json_encode($res);
        echo json_encode($res, JSON_PRETTY_PRINT);
    }
}
