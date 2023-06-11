#!/usr/bin/env perl

use strict;
use warnings;
use Term::ANSIColor;

$| = 1;

my @SERVERS = (
    ['Vite', 'yarn dev' , 'node_modules/vite'],
    ['Svelte', 'yarn dev' , 'node_modules/svelte'],
    ['Nestjs', 'yarn run start:dev' , 'node_modules/@nestjs'],
    ['Django', 'python3 manage.py runserver' , 'manage.py'],
    ['Nextjs', 'yarn dev' , 'node_modules/next'],
    ['React', 'yarn start' , 'node_modules/react'],
    );

sub error_exit {
    print colored("Could not determine the runserver command for project"
                  , "red") . "\n";
    exit(1);
}

sub main {
    foreach my $server (@SERVERS) {
        my ($name, $cmd, $file) = @$server;
        if (-d $file || -f $file) {
            print colored("Running $name server ...\n", "green");
            system($cmd);
            exit;
        }
    }
    error_exit();
}

main();
