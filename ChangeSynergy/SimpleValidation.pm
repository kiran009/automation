#!/usr/bin/perl

package ChangeSynergy::SimpleValidation;

my $data;

sub initPlugin
{
	$data = shift;
	return 1;
}

sub validateData
{
	print "The submitter is " . $data->{'submitter'} . "\n";
    
    if ($data->{'submitter'} =~ /ccm_root/)
	{
        return 0;
    }
	else
	{
        return 1;
    }
}

1;
