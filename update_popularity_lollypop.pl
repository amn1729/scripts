#!/usr/bin/env perl

use strict;
use warnings;
use Term::ANSIColor;

my $db = "$ENV{HOME}/.local/share/lollypop/lollypop.db";
my $log_file = "/mnt/projects/temp/popularity.txt";
# my $YELLOW = "yellow";
my $RED = "red";
my $GREEN = "green";

sub update_popularity {
    my ($search, $num) = @_;
    my $query = qq{SELECT id, name, popularity FROM tracks
                    WHERE NAME LIKE '%$search%';};
    # print colored("Getting info for '$search' ...\n", $YELLOW);
    my $result = `echo "$query" | sqlite3 $db`;
    unless ($result) {
        print colored("No data found", $RED) . "\n";
        return;
    }
    $result =~ s/\|/,/g;
    chomp $result;
    my @rows = split "\n", $result;
    my $row = $result;
    if (scalar @rows > 1) {
        $row = `echo "$result" | fzf`;
    }
    chomp $row;
    return unless($row);
    my ($id, $name, $popularity) = split ",", $row;
    if ($num eq "--get" || $num eq "-g") {
        print colored("$id. $name [$popularity]\n", $GREEN);
        exit;        
    }
    my $new_pop = $popularity;
    if ($num =~ m/^(\+|-)/) {
        $new_pop += int($num);
    } else {
        $new_pop = int($num);
    }
    my $update_query = qq{UPDATE tracks SET popularity = $new_pop
                                        WHERE id = $id;};
    my $status = system(qq{echo "$update_query" | sqlite3 $db});
    if ($status eq "0") {
        print colored("$id. $name [$popularity -> $new_pop]\n", $GREEN);
    } else {
        print colored("Failed to update : ($id, $name, $popularity)", $RED);
        exit(1);
    }
}

sub print_help_and_exit {
    print qq{usage:
    update_popularity_lollypop 'name' [num]
examples:
    update_popularity_lollypop 'some' +10
    update_popularity_lollypop 'some' -10
    update_popularity_lollypop 'some' 23
};
    exit()
}

sub main {
    print_help_and_exit() if (scalar @ARGV < 2);
    my ($search, $num) = @ARGV;
    update_popularity($search, $num);
}

main();
