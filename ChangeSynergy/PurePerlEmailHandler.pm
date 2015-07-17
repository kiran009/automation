#!/usr/bin/perl
#
# Version 2.0	19 July 2006 jcc
#    Updated to support CC and BCC
#    Conform to RFC 822's case insensitive requirement
# Version 1.0
#    Initial version
#    Does not support CC or BCC

package ChangeSynergy::PurePerlEmailHandler;

use Net::SMTP;

my $debug   = 0;
my $logging = 0;

sub initPlugin
{
	$logging = shift;
	$debugFlag = shift;
	
	if ($debugFlag)
	{
		$debug = $debugFlag;
	}

	return 1;
}

sub deliverTemplate
{
	my $message = shift;
	my $ServerName = $main::dict{'smtp_server'};
	my $MailFrom   = $MailTo = $main::dict{'from_email_addr'};

	if ((!defined($ServerName)) || (length($ServerName) == 0))
	{
		print "SMTP Server is not defined in the 'pt.cfg' file.  No trigger emails can be sent until this is changed.";
		return;
	}

	if ((!defined($MailFrom)) || (length($MailFrom) == 0))
	{
		print "From Email Address is not defined in the 'pt.cfg'.  No trigger emails can be sent until this is changed.";
		return;
	}

	print "PURE_PERL_EMAIL Handler to Server : $ServerName from $MailFrom\n";
	print "PURE_PERL_EMAIL_HANDLER: Starting Email Delivery...\n";
	my @to_addresses;
	my @cc_addresses;
	my @bcc_addresses;

	# Get the to line
	if ($message =~ /(^TO:\W*(.*)\n)/i)
	{
		$MailTo = $2;
		my $addressbuffer = $2;
		@to_addresses = split( / *\, */, $addressbuffer);
	}

	# Get the cc line
	if ($message =~ /(^CC:\W*(.*)\n)/i)
	{
		$ccMailTo = $2;
		my $addressbuffer = $2;
		@cc_addresses = split( / *\, */, $addressbuffer);
	}

	# Get the bcc line
	if ($message =~ /(^BCC:\W*(.*)\n)/i)
	{
		my $addressbuffer = $2;
		@bcc_addresses = split( / *\, */, $addressbuffer);
	}

	if ($debug)
	{
		print "To Recipents: " . @to_addresses . "\n";

		for my $address_name (@to_addresses)
		{
			print "ADDRESS: $address_name\n";
		}

		print "CC Recipents: " . @cc_addresses . "\n";

		for my $address_name (@cc_addresses)
		{
			print "ADDRESS: $address_name\n";
		}

		print "BCC Recipents: " . @bcc_addresses . "\n";

		for my $address_name (@bcc_addresses)
		{
			print "ADDRESS: $address_name\n";
		}
	}

	if ((scalar @to_addresses + scalar @cc_addresses + scalar @bcc_addresses) > 0)
	{
		# Create a new SMTP object
		$smtp = Net::SMTP->new( $ServerName, Debug => $debug );

		# If you can't connect, don't proceed with the rest of the script
		die "Couldn't connect to server" unless $smtp;

		# Initiate the mail transaction
		$smtp->mail($MailFrom);
		$smtp->to(@to_addresses, { SkipBad => 1 });
		$smtp->cc(@cc_addresses, { SkipBad => 1 });
		$smtp->bcc(@bcc_addresses, { SkipBad => 1 });

		# Start the mail
		$smtp->data();
		$smtp->datasend($message . "\n\n");

		# Send the termination string
		$smtp->dataend();

		# Close the connection
		$smtp->quit();

		print "PURE_PERL_EMAIL_HANDLER: Finished Email Delivery.\n";

	}
	else
	{
		print "PURE_PERL_EMAIL_HANDLER: Invalid email template ...\n$message\n";
	}


	if ($logging)
	{
		my $subjectLine = "Unknown Subject";

		if ($message =~ /.*(Subject:\W.*)\n/)
		{
			$subjectLine = $1;
		}

		$MailTo =~ s/\s*$//;
		
		my $note = "Email Sent to: $MailTo\n";
		
		if (scalar @cc_addresses > 0) 
		{
			$ccMailTo =~ s/\s*$//;
			$note .= "CCs Sent to: $ccMailTo \n";
		}
		
		if (scalar @bcc_addresses > 0)
		{
			$note .= "BCCs were also sent\n";
		}

		$note .= "$subjectLine";

		&main::addNoteToLog($note);
	}

	return 1;
}

1;
