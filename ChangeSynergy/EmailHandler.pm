#!/usr/bin/perl

package ChangeSynergy::DefaultHandler;

sub initPlugin
{
	return 1;
}

sub deliverTemplate
{
	print "EMAIL_DELIVERY_PLUGIN: Sending Email ...\n";

	my $message_body = 'unknown';
	$message_body = shift;
        open EMAIL , "| /usr/lib/sendmail -t";
        print EMAIL $message_body;
        close EMAIL;
	print "EMAIL_DELIVERY_PLUGIN: Finished Sending Email ...\n";

	return 0;
}

1;


