package ChangeSynergy::EmailHelper;

# Use statements.
use Net::SMTP;
use MIME::Base64;
use strict;
use CGI;

# Declare some global variables.
my $email;
my $csapi;
my $user;
my $trigger;
my $sourceAttrs;

# Path starts from the triggers directory so we have to work back and then down. This is used
# to read in some HTML templates for the header and footer of our emails.
my $path = "../../perl/lib/perl5/site_perl/5.8.6/ChangeSynergy/";


# Verifies that the smtp_server and the from_email_address attributes are set from the trigger object. If
# these are not set then the Perl script will be aborted by the "die" command.
sub verifyMailData
{
	my $trigger = shift;

	my $smtp_server = $trigger->get_smtp_server();
	my $from_email_addr = $trigger->get_from_email_addr();

	if ((!defined($from_email_addr)) || (length($from_email_addr) == 0))
	{
		die "From Email Address is not defined in the 'pt.cfg' file.\nNo trigger emails can be sent until this is changed.";
	}

	if ((!defined($smtp_server)) || (length($smtp_server) == 0))
	{
		die "SMTP Server is not defined in the 'pt.cfg' file.\nNo trigger emails can be sent until this is changed.";
	}
}


# Stores a local copy of the csapi object, apiUser object and triggerParser objects. This allows for less
# variables to be passed in to each email helper function.
sub setup
{
	$csapi = shift;
	$user = shift;
	$trigger = shift;
}


# Method to get the details of a CR using the GetCRData method and a list of attributes to fetch.
# Just a helper method so users don't need to code the same stuff over and over again.
sub getCrDetails
{
	my $crid = shift;
	my $attribute_list = shift;
	
	my $cr;

	eval 
	{
		$cr = $csapi->GetCRData($user, $crid, $attribute_list);
    };

	if ($@)
	{
		print "Failed to show CR: $crid: $@";
		exit 0;
	}

	#returns the cr details.
	return $cr;
}


# Open a connection to the SMTP server to start an email that sends the email to a single user. This
# method sends a default IBM Rational Change style message with the IBM Rational Change image as an inline
# attachment.
sub openEmail
{
	my $to_addr = shift;
	my $cc_list = shift;
	my $bcc_list = shift;
	my $subject = shift;
	my $from_addr = shift;
	
	#Now we have determined that an email should be sent.
	#Create the mail object and pass it the smtp server name.
	$email = Net::SMTP->new($trigger->get_smtp_server());
	
	if ((!defined($from_addr)) || (length($from_addr) == 0))
	{
		$email->mail($trigger->get_from_email_addr());
	}
	else
	{
		$email->mail($from_addr);
	}

	my @to_addr_arr = split(',',$to_addr);
	my @cc_addr_arr = split(',',$cc_list);
	my @bcc_addr_arr = split(',',$bcc_list);
	
	if (scalar(@to_addr_arr) == 0 && scalar(@cc_addr_arr) == 0 && scalar(@bcc_addr_arr) == 0)
    {
		print "No email is sent as no email addresses are specified.";
        return 0;
    }
	foreach (<@to_addr_arr>)
	{
		$email->to($_);
	}
	
	foreach (<@cc_addr_arr>)
	{
		$email->cc($_);
	}
	
	foreach (<@bcc_addr_arr>)
	{
		$email->bcc($_);
	}
	$email->data();
	$email->datasend("Subject: $subject\r\n");
	$email->datasend("To: $to_addr\r\n");
	$email->datasend("Mime-Version: 1.0\r\n");
	$email->datasend("Content-type: multipart/related;\r\n\tboundary=\"==aboundary==\"\r\n");
	$email->datasend("--==aboundary==\r\n");
	$email->datasend("Content-transfer-encoding: 7bit\r\n");
	
	my $charset = getCharset();
	$email->datasend("Content-type: $charset\r\n");
	$email->datasend();
	$email->datasend("\r\n" . includeFileContents("emailHeader.html"));
}

# Send content to the email.
sub applyHtmlHeader
{
	my $header = shift;
	my $output;
	
	$output  = "<div align='center'>\n";
	$output .= "    <h2>$header</h2>\n";
	$output .= "</div>\n";
	
	$email->datasend(shift);
}

# Close the email, this includes the footer HTML document and the gif image used in the header document.
# cid:header in the header file matches the Content-ID added here.
sub closeEmail
{
	$email->datasend(includeFileContents("emailFooter.html"));
	$email->datasend("\r\n--==aboundary==\r\n");
	
	#send attachment, read file, convert to base64.
	$email->datasend("Content-type: image/gif; name=\"header.gif\"\r\n");
	$email->datasend("Content-ID: <header>\r\n");
	$email->datasend("Content-transfer-encoding: base64\r\n");
	$email->datasend();
	$email->datasend("\r\n" . getImageAsBase64String());
	$email->datasend("--==aboundary==--\r\n");
	$email->datasend();
	$email->quit;
}


# Opens a file and returns the contents of that file.
sub includeFileContents
{
	my $fileName = shift;
	my $contents;
	my $buf;
	
	open (INPUTFILE, $path . $fileName) || die ("Could not open file: $fileName");
	
	while ($buf = readline *INPUTFILE)
	{
		$contents .= $buf;
	}
	
	close(INPUTFILE);
	
	return $contents;
}


# Opens an the header image image file and encodes it as a base64 string and returns that string.
sub getImageAsBase64String
{
	my $encodedString;
	my $buf;
	
 	open(IMAGEFILE, "../../../trapeze/ptimages/header.gif") || die "Could not open image file: $!";
 	
 	while (read(IMAGEFILE, $buf, 60 * 57)) 
 	{
       $encodedString .= encode_base64($buf);
    }
    
    return $encodedString;
}

# Takes a string that contains the name to use for the table header and then an array of hashes containing
# the alias, the value and if the row should be zebra stripped or not.
sub sendStrippedTable
{
	my $tableHeader = shift;
	my $tableData = shift;

	$email->datasend("<br />\r\n");
	$email->datasend("<table class=\"attributes\" border=\"1\" cellpadding=\"0\" cellspacing=\"0\">\r\n");
	$email->datasend("<th colspan=\"2\">\r\n");
	$email->datasend("$tableHeader\r\n");
	$email->datasend("</th>\r\n");
	$email->datasend("<tbody>\r\n");
	$email->datasend();
	
	foreach my $row_data (@$tableData)
	{
		if ($row_data->{zebra} == 0)
		{
			$email->datasend("<tr>\r\n");
		}
		else
		{
			$email->datasend("<tr class=\"zebra\">\r\n");
		}
		
		$email->datasend("<td width=\"25%\" valign=\"top\" align=\"right\" NOWRAP>\r\n");
		$email->datasend("<b>" . $row_data->{alias} . ":</b>\r\n");
		$email->datasend("</td>\r\n");
		$email->datasend("<td width=\"75%\">\r\n");
		$email->datasend($row_data->{value} . "\r\n");
		$email->datasend("</td>\r\n");
		$email->datasend("</tr>\r\n");
	}
	
	$email->datasend("</tbody>\r\n");
	$email->datasend("</table>\r\n");
}

# Create the loop data for the hard coded change request table. This table holds the CR ID, CR status,
# problem synopsis, the user who caused the modification action to occur and the database where the
# change occured in. The CR ID has a link to the CR and the modifier has a link to their email address.
sub createCrInfoBlockData
{
	my $crInfo = shift;
	my $modifierTitle = shift;

	# initialize an array to hold your loop
	my @loop_data = (); 

	#Get the users name from the trigger.
	my $userName = $trigger->get_user();

	#Get the object id from the trigger.
	my $crid = $trigger->get_object_id();
	
	#If crid is not defined then this trigger is related to a relationship.
	if (!defined($crid))
	{
		$crid = $trigger->get_from_object();
	}

	#Create new hashes and add the attribute alias, attribute value and 1 for white and 0 for gray for a zebra stripped table.
	my %row_data0 = ();  
    $row_data0{alias} = "CR ID";
    $row_data0{value} = "<a href='" . getCrUrl($crid) . "'>" . $crid . "</a>";
	$row_data0{zebra} = 1;
	#push the newly created hash table onto the loop array.
	push(@loop_data, \%row_data0);

	my %row_data1 = ();
	$row_data1{alias} = ChangeSynergy::util::htmlEncode($crInfo->getDataObjectByName("crstatus")->getLabel());
    $row_data1{value} = ChangeSynergy::util::htmlEncode($crInfo->getDataObjectByName("crstatus")->getValue());
	$row_data1{zebra} = 0;
	push(@loop_data, \%row_data1);

	my %row_data2 = ();
	$row_data2{alias} = ChangeSynergy::util::htmlEncode($crInfo->getDataObjectByName("problem_synopsis")->getLabel());
    $row_data2{value} = ChangeSynergy::util::htmlEncode($crInfo->getDataObjectByName("problem_synopsis")->getValue());
	$row_data2{zebra} = 1;
	push(@loop_data, \%row_data2);

	my %row_data3 = ();
	$row_data3{alias} = $modifierTitle;
	my $tempEmail = getUserPreference($userName, "user_email");
	my $tempName = getUserPreference($userName, "user_name");

	#For _change_admin, $tempEmail and $tempName should be N/A
	if ($tempEmail eq "N/A" && $tempName eq "N/A")
	{
		$row_data3{value} = $userName;
	}
	elsif ($tempEmail eq "N/A")
	{
		$row_data3{value} = $tempName . "($userName)";
	}
	else
	{
	    $row_data3{value} = "<a href='mailto:" . $tempEmail . "'>".
		                   $tempName . "($userName) </a>";
	}
	$row_data3{zebra} = 0;
	push(@loop_data, \%row_data3);

	my %row_data4 = ();
	$row_data4{alias} = "Database";
    $row_data4{value} = ChangeSynergy::util::htmlEncode($trigger->get_database());
	$row_data4{zebra} = 1;
	push(@loop_data, \%row_data4);

	return \@loop_data;
}

# Local helper function to fetch user profile and preference values.
sub getUserPreference 
{
	my $userName = shift;
	my $preferenceName = shift;
	my $preferenceValue = "N/A";

	eval 
	{ 
		my $preference = $csapi->GetUserPreference($user, $userName, $preferenceName);
		$preferenceValue = $preference->getResponseData();	
	};

	if ($@) 
	{
		print "Failed to look up preference '$preferenceName' for user '$userName': $@";
	}

	return $preferenceValue;
}

#Convert an array of attribute names into a hash where the key is the attribute label and the value is the attribute name.
sub getAttributeLabels
{
	my @keys = @_;

	my %newKeys = ();

	foreach my $key (@keys)
	{
		$newKeys{getAttributeLabel($key)} = $key;
	}

	return %newKeys;
}

#Using the source attribute list look up the given attribute and return its label (alias).
sub getAttributeLabel
{
	my $attrName = shift;

	#lazy initialization
	if (!defined($sourceAttrs))
	{
		#This functionality to request SOURCE_ATTRIBUTES as a ValueListBox may not work in future releases of CS.
		$sourceAttrs = $csapi->GetValueListBox($user, "SOURCE_ATTRIBUTES");	
	}

	my $listSize = $sourceAttrs->getListSize();

	# Loop over all of the sourceAttributes, if the attrName is equal to one of the sourceAttributes
	# then we return its label.
	for(my $i = 0; $i < $listSize; $i++)
	{
		#Source attributes are a list of labels and values.  The value is the actual database name of the attribute.
		my $compare = $sourceAttrs->getValue($i) cmp $attrName;

		if ($compare == 0)
		{
			return $sourceAttrs->getLabel($i);
		}
	}

	return $attrName;
}

# Create the URL only to a change request.
sub getCrUrl 
{
	my $crid = shift;

	my $url = $trigger->get_base_url();
	$url .=  "/servlet/PTweb?ACTION_FLAG=frameset_form&TEMPLATE_FLAG=ProblemReportView";
	$url .= "&database=" . CGI::escape($trigger->get_database());
	$url .= "&role=". $trigger->get_role() . "&problem_number=" . CGI::escape($crid);
	
	return $url;
}

# Create an HTML link to a Change Request with the CR ID being the link.
sub getCRLink
{
	my $triggerInfo   = shift;
	my $problemNumber = shift;
	my $retVal       = "";
	
	$retVal .= "CR <a href=";
	$retVal .= $trigger->get_base_url();
	$retVal .= "/servlet/PTweb?ACTION_FLAG=frameset_form&TEMPLATE_FLAG=ProblemReportView";
	$retVal .= "&database=" . CGI::escape($triggerInfo->get_database());
	$retVal .= "&role=". $triggerInfo->get_role() . "&problem_number=" . CGI::escape($problemNumber);
	$retVal .= ">$problemNumber</A>";
	
	return $retVal;
}

# Create an HTML link to a task with the task number being the link.
sub getTaskLink
{
	my $triggerInfo = shift;
	my $taskNumber  = shift;
	my $retVal      = "";
	
	$retVal .= "Task <a href=";
	$retVal .= $trigger->get_base_url();
	$retVal .= "/servlet/PTweb?ACTION_FLAG=frameset_form&TEMPLATE_FLAG=TaskDetailsView";
	$retVal .= "&database=" . CGI::escape($triggerInfo->get_database());
	$retVal .= "&role=". $triggerInfo->get_role() . "&task_number=" . CGI::escape($taskNumber);
	$retVal .= ">$taskNumber</A>";
	
	return $retVal;
}

# Create a link to an object with the relation name as the link.
sub getObjectLink
{
	my $triggerInfo = shift;
	my $cvid        = shift;
	my $retVal      = "";
	
	$retVal .= "<a href=";
	$retVal .= $trigger->get_base_url();
	$retVal .= "/servlet/PTaction?ACTION_FLAG=objectreport&CHOSEN_REPORT=objectdetail";
	$retVal .= "&database=" . CGI::escape($triggerInfo->get_database());
	$retVal .= "&role=". $triggerInfo->get_role() . "&cvid=" . CGI::escape($cvid);
	$retVal .= ">" . $triggerInfo->get_relation_name() . "</A>";
	
	return $retVal;
}

sub getCharset
{
	my $retval = "text/html";
	my $charset = $ENV{SYNERGYChange_encoding};

	if (defined($charset))
	{
		if ((length($charset) != 0) && ($charset eq "UTF-8"))
		{
			$retval .= "; charset=" . $charset;
		}
	}

	return $retval;
}

sub writeData
{
	my $data = shift;
	if (!defined($email))
	{
		print "No email object to write to";
		exit 0;
	}
	$email->datasend($data);
}

1;
