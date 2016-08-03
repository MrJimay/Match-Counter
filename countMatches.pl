#!/usr/bin/perl
use strict;
use warnings;
use Term::ANSIColor qw(:constants);

my $output_file = "output.txt";
my $argument_error_message = "Expecting at least 2 arguments. Correct usage is ./countMatches.pl <csv file> <regex pattern> [column #] [flag] where [] arguments are optional.\n Type ./countMatches.pl help for help\n";
my $col_num = 0;
my $flag;
# whether to read a file or a single regex pattern
# 0 - regex pattern
# 1 - file
my $read_file = 0;
open(my $output, '>', $output_file);

my $input_file = $ARGV[0] or die $argument_error_message;

if ($input_file eq "help") {
	print_help();
} else {
	my $pattern = $ARGV[1] or die $argument_error_message;

	# Check whether a file or a single pattern was inputted
	if (-f $pattern) {
		$read_file = 1;
	}
	
	my $optional_arg = $ARGV[2];
	my $optional_arg_two = $ARGV[3];

	read_optional_args($optional_arg, $optional_arg_two);

	if ($read_file == 1) {
		open(my $regex, '<', $pattern) or die "Failed to read regex file. Please see help for more info.\n";
		print $output "Total: ", match_regex(".*"), "\n";
		while (my $line = <$regex>) {
			chomp $line;
			print $output "$line: ", match_regex($line), "\n";
		}
		print GREEN, "Success! Check your output.txt file\n", RESET;
	} else {
		my $sum = match_regex($pattern);
		print_result($sum);	
	}

	# Open the output file if -o flag was set
	if (defined $flag) {
		if ($flag eq '-o') {
			system("open", $output_file);
		}
	}	
}

sub match_regex {
	open(my $data, '<', $input_file) or die "Could not open '$input_file' $!\n";
	my $sum = 0;
	# read csv file
	while (my $line = <$data>) {
	  chomp $line;
	  # get the columns of the csv into an array
	  my @fields = split "," , $line;
	  my $field_num = @fields;
	  # kill the script if invalid column number
	  if ($col_num > $field_num - 1) {
	  	die "Column number $col_num not found.\n";
	  }
	  if($fields[$col_num] =~ $_[0]) {
	  	if ($read_file == 0) {
	  	  	print $output "$fields[$col_num] \n";
	  	}
	  	$sum += 1;
	  }
	}	
	close($data);
	return $sum;
}

# Reads in the optional args 
# and sets the global variables $col_num and $flag
sub read_optional_args {
	foreach my $a (@_) {
		if (defined $a) {
			if ($a =~ '[0-9]+') {
				$col_num = $a;
			} else {
				$flag = $a;
			}			
		}
	}
}

sub print_help {
	print "===================================\n";
	print "Jimmy's pattern matching script!\n";
	print "===================================\n";
	print "Note: This script only works for files with columns separated by commas ','.\n";
	print "\n";
	print "First argument:\n";
	print " -> ", CYAN, "help\n", RESET, "Displays this help screen\n";
	print " -> ", CYAN, "<csv file name>\n", RESET, "Search through this csv file\n";
	print "\n";
	print "Second argument:\n";
	print " -> ", CYAN, "<regex pattern\n", RESET, "Find matches for this regex pattern. Use '^.*$' to count everything.\n";
	print " -> ", CYAN, "<txt file name>\n", RESET, "Matches regex patterns inside this txt file. Each regex pattern must be separated with a new line.\n";
	print "\n";
	print "Optional arguments:\n";
	print " -> ", CYAN, "-o\n", RESET, "Open a .txt file after the search with a list of results that matches the input pattern\n";
	print " -> ", CYAN, "<column #>\n", RESET, "Specify a column number to search through, otherwise searches through the first column.\n";
	print "\n";
}

# Takes the number of matches and prints out a colourful result
sub print_result {
	if ($_[0] eq '0') {
		print RED, "No matches!\n", RESET;
	} else {
		print GREEN, "$_[0] matches!\n", RESET;
	}
}