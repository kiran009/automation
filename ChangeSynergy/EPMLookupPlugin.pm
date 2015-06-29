#!/usr/bin/perl

package ChangeSynergy::EPMLookupPlugin;

use ChangeSynergy::csapi;

my $message='';

sub initPlugin
{
	print "Initializing the EPM LookupPlugin ...\n";

	return 1;
}

sub Methods
{
	my @methods = ('determineEPM',);
	
	return @methods;
}

# This function looks up a project name and returns the corresponding EPM e-mail address
sub determineEPM
{
	# Parse input parameters
	my $lookup_file = shift;
	my $lookup_project = shift;
	my $lookup_phase = shift;
	
	if (($lookup_phase eq "Factory") || ($lookup_phase eq "Field"))
	{
		$lookup_project = $lookup_phase;
	}
	
	open (LOOKUP_FILE, $lookup_file) || die "ERROR -- Unable to open file $lookup_file \n\n";
	my $line; 
	
	while ($line = <LOOKUP_FILE>)
	{
		chomp $line;
		my ($project, $addresses) = split (/,/,$line,2);
		
		if ($project eq $lookup_project)
		{
			return ($addresses);
		}
	}

	return "ccm_root";
}

1;

