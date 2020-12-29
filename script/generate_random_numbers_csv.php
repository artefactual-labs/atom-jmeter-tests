#!/usr/bin/env php
<?php

if (count($argv) != 5)
{
  print "Usage: \n\n";
  print basename($argv[0]) ." <minimum number> <maximum number> <number of rows to create> <output CSV file>\n";

  exit();
}

// Set params from CLI
$min = $argv[1];
$max = $argv[2];
$numbers = $argv[3];
$filename = $argv[4];

if (!ctype_digit($min))
{
  print "Minimum must be an integer.\n";
  exit(1);
}

if (!ctype_digit($max))
{
  print "Maximum must be an integer.\n";
  exit(1);
}

if (!ctype_digit($numbers) || empty($numbers))
{
  print "Number of rows must be a positive integer.\n";
  exit(1);
}

if (file_exists($filename))
{
  print "File already exists.\n";
  exit(1);
}

// Describe behavior
print "Generating a CSV file with ". $numbers ." rows of one column containing a number ranging from ". $min ." to ". $max ."\n";

// Write CSV
$fp = fopen($filename, 'w');
fputcsv($fp, ['number']);

$count = 0;

while ($count < $numbers)
{
  fputcsv($fp, [rand($min, $max)]);
  $count++;
}

fclose($fp);

print "Done.\n";
