#!/usr/bin/perl

package ChangeSynergy::reportPlugin;

use ChangeSynergy::csapi;

my $message='';

sub initPlugin
{
	
	print "Initializing the plugin ...\n";
	$args = shift;
	print $$args[0];
	$message = $$args[0];

	return 1;
}

sub Methods
{
	my @methods = ('report');
	
	return @methods;
}

sub report
{
	my $reportName = shift;
	my $query = shift;
    my $user;
    $user = $main::dict{'user'};
	$query =~ s/USER/$user/g;
	$query =~ s/&per;/%/g;
	my $retText="";
	
	eval 
	{
        my $arg;
        my $argNum = 1;
		
		foreach $arg (@_)
		{
           $query =~ s/ARG$argNum/$arg/g;
           $argNum++;
        }

		print "\nRunning report\n";
		print "Name  = $reportName\n";
		print "query = $query\n";

		my $results = $main::csapi->ImmediateQueryHtml($main::csuser, $reportName,$query, undef, "All your assigned CR's");
		$retText = $results->getResponseData();

		if ( $retText =~ /No matches were found/ )
		{
			print "\nReport returned no matches\n";
	 		$retText = "";
		}

		print "\nEmbedding report\n";
	};

	# Now all links call javascript to open a new window.  In Outlook express
	# this causes a new web window to open to evalate the javascript, which 
	# then opens yet another window.  The search/replace statement below changes
	# all these occurences to just a http reference.  This will still cause 
	# a window to open with the link.
	$retText =~ s/(^.*<A HREF=)"javascript:var w = window.open\(('[^']*').*"(>.*)$/$1$2$3/gim;
	
	return $retText;
}

1;

