#!/usr/bin/perl
package ChangeSynergy::LogHandler;

my $logPath = '/tmp/csnoticelog.txt';

sub initPlugin
{
	return 1;
}

sub deliverTemplate
{
	my $message = shift;
	open (LOG, ">>$logPath") || print "Can't log to file $logPath\n";;
	print LOG $message . "\n";
	close(LOG);
	
	return 1;
}

1;




