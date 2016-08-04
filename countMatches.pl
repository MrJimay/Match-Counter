#!/usr/bin/perl
use strict;
use warnings;
use Term::ANSIColor qw(:constants);

# Name of the file we write the results to
my $output_file = "output.txt";

# Used for formatting and storing results if a file is passed in instead of a single regex
my @output_array;

my $argument_error_message = "Expecting at least 2 arguments. Correct usage is ./countMatches.pl <csv file> <regex pattern> [column #] [flag] where [] arguments are optional.\n Type ./countMatches.pl help for help\n";

# Store info passed in from optional command line arguments
my $col_num = 0; # default column to search through is the first column
my $flag;

# Store whether to read a file or a single regex pattern
# 0 - regex pattern
# 1 - file
my $is_file_read = 0;

# Take in the first argument as the name of the csv file to process
my $input_file = $ARGV[0] or die $argument_error_message;

# Open the output file. Needs global scope so subroutines can access it
open(my $output, '>', $output_file);

if ($input_file eq "help") {
	print_help();
} else {
	process_optional_args();

	my $pattern = $ARGV[1] or die $argument_error_message;

	# Check whether a file or a single pattern was inputted
	if (-f $pattern) {
		$is_file_read = 1;
	}

	if ($is_file_read == 1) {
		process_regex_file($pattern);
	} else {
		my $sum = match_regex($pattern);
		print_result($sum);	
	}

	open_output_if_flag_set($output_file);
}

# Takes in a file name and treats each line in the file as regex to match against the input file
sub process_regex_file {
	open(my $regex, '<', $_[0]) or die "Failed to read regex file. Please see help for more info.\n";
	print "Counting total...\n";
	print $output "Total: ", match_regex(""), "\n";
	while (my $line = <$regex>) {
		chomp $line;
		print "Counting matches for $line...\n";
		push(@output_array, "\n");
		push(@output_array, "=== Results matching $line ===\n");
		print $output "$line: ", match_regex($line), "\n";	
	}
	print $output "\n@output_array";
	print GREEN, "Success! Check your output.txt file\n", RESET;
}

# Takes in regex and returns the number of matches in the input file
sub match_regex {
	open(my $data, '<', $input_file) or die "Could not open '$input_file' $!\n";
	my $sum = 0;
	# read csv file line by line
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
	  	if ($is_file_read == 0) {
	  		# if we're reading single regex, just print to the file
	  	  	print $output "$fields[$col_num] \n";
	  	} else {
	  		# otherwise if we're reading multiple regex, store results in an array for processing
	  		# this allows us to put the important counts at the top of the output file
	  		if (!$_[0] eq "") {
	  			push(@output_array, $fields[$col_num]);
	  		}
	  	}
	  	$sum += 1;
	  }
	}
	close($data);
	return $sum;
}

# Reads in the optional args
# then sets the global variables $col_num and $flag
sub process_optional_args {
	my $optional_arg = $ARGV[2];
	my $optional_arg_two = $ARGV[3];
	set_optional_args($optional_arg, $optional_arg_two);
}

# Opens the file passed in if -o flag was set
sub open_output_if_flag_set {
	if (defined $flag) {
		if ($flag eq '-o') {
			system("open", $_[0]);
		}
	}
} 

# Sets the global variables $col_num and $flag
sub set_optional_args {
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

# Print out a cool looking help screen
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
	print " -> ", CYAN, "-o\n", RESET, "Open a .txt file after the search with a list of results that matches the input pattern.\n";
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
