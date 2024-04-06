<?php
declare(strict_types=1);

$version = @file_get_contents(__DIR__ . '/VERSION');
$version = $version ? trim($version) : 'UNKNOWN';
echo "Hello World! ($version)<br />\n";

