#!/usr/bin/perl

package ChangeSynergy::DefaultHandler;

use Net::SMTP;  

my $debug = 0;

sub initPlugin
{
	$debugFlag = shift;
	
	if ($debugFlag)
	{
		$debug = $debugFlag;
	}

	return 1;
}

sub deliverTemplate
{
  my $ServerName = $main::dict{'smtp_server'};
  my $MailFrom = $MailTo = $main::dict{'from_email_addr'};

  if ((!defined($ServerName)) || (length($ServerName) == 0))
  {
	print "SMTP Server is not defined in the 'pt.cfg' file.  No trigger emails can be sent until this is changed.";
	return;
  }

  if ((!defined($MailFrom)) || (length($MailFrom) == 0))
  {
	print "From Email Address is not defined in the 'pt.cfg' file.  No trigger emails can be sent until this is changed.";
	return;
  }

  print "Default Handler to Server : $ServerName from $MailFrom\n";

  if (-x "/usr/lib/sendmail")
  {
	print "EMAIL_DELIVERY_PLUGIN: Sending Email (UNIX) ...\n";

	my $message_body = 'unknown';
	$message_body = shift;
        open EMAIL , "| /usr/lib/sendmail -t";
        print EMAIL $message_body;
        close EMAIL;
	print "EMAIL_DELIVERY_PLUGIN: Finished Sending Email ...\n";

   }
   else
   {
	print "PURE_PERL_EMAIL_HANDLER: Starting Email Delivery...\n";
	my $message = shift;
	my @addresses;

	# Get the to line
	if ($message =~ /(^To:\W*(.*)\n)/)
	{
		$MailTo = $2;
		my $ToLine = $2;
		@addresses = split(/ *\, */, $ToLine);

        if ($debug)
		{
			print "ADDRESSES: " . @addresses . "\n";
                    
			for my $address_name (@addresses)
			{
                print "ADDRESS: $address_name\n";
            }
        }
        	
        # Create a new SMTP object  
	    $smtp = Net::SMTP->new($ServerName, Debug => $debug); 

	    # If you can't connect, don't proceed with the rest of the script  
	    die "Couldn't connect to server" unless $smtp;

	    # Initiate the mail transaction 

	    $smtp->mail( $MailFrom );  
	    $smtp->to( @addresses, { SkipBad => 1 } ); 

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
    
	return 1;
  }
}

1;

