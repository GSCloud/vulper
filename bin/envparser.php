<?php
declare (strict_types = 1);

// pass the file resource to be parsed as the first and only parameter
if ($argc == 2) {
    $f = $argv[1];
    if (file_exists($f) && is_readable($f)) {
        $arr = file($f);
        $arr = array_map(function ($s) {
            preg_match('/([a-zA-Z0-9_@$%^&* \-\.,:\/="\']+)/', $s, $matches, PREG_UNMATCHED_AS_NULL);
            if ($matches && array_key_exists(1, $matches) && strpos($matches[1], '=') !== false) {
                return $matches[1];
            }
        }, $arr);
        $arr = array_map('trim', $arr);
        $arr = array_filter($arr);
        sort($arr);

        $res = [];
        foreach ($arr as $s) {
            $x = explode('=', $s, 2);
            $key = $x[0];
            $val = trim($x[1], '"\'');
            if (is_numeric($val)) {
                $val = (int) $val;
            }
            $res[$key] = $val;
        }
        echo json_encode($res, JSON_PRETTY_PRINT);
    }
}
