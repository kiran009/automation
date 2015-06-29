#!/usr/bin/perl

package ChangeSynergy::dcmPlugin;

# This is a set of functions that are useful for DCM Initialized sites doing email notifications.

my $message='';

sub initPlugin
{	
	print "Initializing the dcmPlugin ...\n";
	return 1;
}

sub Methods
{
	my @methods = ('stripCRID',);
	return @methods;
}

#
# This is a quick function to remove the DCM ID and delimiter
# from the CRID for use in email notification templates
# Use it in templates like this:
#    %&stripCRID($CRID, '#')%
sub stripCRID
{

    my $crID = shift;
    my $dcmDelim = shift;
    my $strippedID = '';
    
    if ($crID =~ /.*\#(\d+)$/) 
	{
        $strippedID = $1;
    }
	else 
	{
        $strippedID =  $crID;
    }

	return $strippedID;
}

1;

