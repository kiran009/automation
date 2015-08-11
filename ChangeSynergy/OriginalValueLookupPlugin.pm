#!/usr/bin/perl

package ChangeSynergy::OriginalValueLookupPlugin;

## This package is used for looking up the original attribute value from the transition log
use ChangeSynergy::csapi;

my $message='';
my $local_dict;

sub initPlugin
{
	$args = shift;
    $local_dict = $$args[0];
    
	return 1;
}

sub Methods
{
	my @methods = ('originalValue', 'originalValueEmail');

	return @methods;
}

# Returns the original value of the given attribute from the transition log
# Not this currently only works for cvtype='problem' objects
# Inputs:
#	attr_name: The Name of the attribute to lookup
# 	no_match_val: The value to return if there is no matches
# Returns:
#	$value: The original value. This will contain the no_match_value if no matching records found

sub originalValue
{

	# Parse input parameters
	my $attr_name = shift;
	my $no_match_val  = shift;
	my $value = $no_match_val;

	# Load the current log
	my $currentLog = $local_dict->{"transition_log"};
	# Parse backwards in the log for the attribute

	my @log = split /\n/, $currentLog;

	for (my $i = (scalar(@log) - 1); $i >= 0; $i-- )
	{
        my $current = $log[$i];
        if ($current =~ m/$attr_name: (.*) --> (.*)/ )
		{
			$value = $1;
            last;
        }
	}

	return $value;
}

sub originalValueEmail
{
	# Parse input parameters
	my $attr_name = shift;
	my $no_match_val  = shift;
	my $value = &originalValue($attr_name, $no_match_val);
	my @addresses = &main::getEmailAddresses($value);
	my $address;

	if (scalar(@addresses) > 0)
	{
		$address = $addresses[0];
	}

	return $address;
}


1;
