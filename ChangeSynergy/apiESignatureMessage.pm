###########################################################
## apiESignatureMessage Class
###########################################################
package ChangeSynergy::apiESignatureMessage;

use strict;
use warnings;
use POSIX;

sub new()
{
	shift; #take off the apiESignatureMessage which is passed in, this is the class name.

	# Initialize data as an empty hash
	my $self = {};

	# Initialize data for this object
	$self->{xmlData}          = undef;
	$self->{mFullname}        = undef;
	$self->{mUsername}        = undef;
	$self->{mDate}            = undef;
	$self->{strDate}          = undef;
	$self->{mPurpose}         = undef;
	$self->{mComment}         = undef;
	$self->{mAttribute}       = undef;
	$self->{mCvid}            = undef;
	$self->{mCreateTime}      = undef;
	$self->{globals}		  = new ChangeSynergy::Globals();
	
	$self->{mUnencodedComment} = undef;

	# If a parameter was passed in then set it as the xmlData
	if(@_ > 0)
	{
		$self->{xmlData}     = shift;
	}
	else
	{
		$self->{xmlData}     = undef;
	
		bless $self;
		return $self;
	}

	bless $self;

	eval
	{
		&parseXml($self);
	};

	if($@)
	{
		die "Invalid XML Data: apiESignatureMessage: " . 	$self->{xmlData} . $@;
	}

	return $self;
}

sub getXmlData()
{
	my $self = shift;
	return $self->{xmlData};
}

sub getFullname()
{
	my $self = shift;
	return $self->{mFullname};
}

sub getUsername()
{
	my $self = shift;
	return $self->{mUsername};
}

sub getDate()
{
	my $self = shift;
	return $self->{mDate};
}

sub getDateString()
{
	my $self = shift;
	my $format = shift;
	
	if(defined($self->{strDate}))
	{
		$self->{strDate} = undef;
	}
	
	if($self->{mDate} < 0)
	{
		$self->{strDate} = "";
		return $self->{strDate};
	}
	
	my $tmpFormat = "%Y/%m/%d %I:%M:%S %p";
	
	if(!defined($format))
	{
		$format = $tmpFormat;
	}
	
	$self->{strDate} = &POSIX::strftime($format, localtime($self->{mDate}));
	
	return $self->{strDate};
}

sub getPurpose()
{
	my $self = shift;
	return $self->{mPurpose};
}

sub getComment()
{
	my $self = shift;
	return $self->{mComment};
}

sub getUnencodedComment()
{
	my $self = shift;
	
	if(defined($self->{mUnencodedComment}))
	{
		$self->{mUnencodedComment} = undef;
	}
	
	$self->{mUnencodedComment} = ChangeSynergy::util::xmlDecode($self->{mComment});
	
	return $self->{mUnencodedComment};
}

sub getAttribute()
{
	my $self = shift;
	return $self->{mAttribute};
}

sub getCvid()
{
	my $self = shift;
	return $self->{mCvid};
}

sub getCreateTime()
{
	my $self = shift;
	return $self->{mCreateTime};
}

#	<message>
#		<fullname>user's first and last name</fullname>
#		<username>operating system login name</username>
#		<date>the date when a signature was created</date>
#		<purpose>a definable enumerated list</purpose>
#		<comment>optional comment</comment>
#		<attribute>the signature attribute</attribute>
#		<cvid>CR's:cvid is required execpt on submit and copy operations</cvid>
#		<create_time>the time that the CR was created</create_time>
#	</message>

sub parseXml()
{
	my $self = shift;

	if(!defined($self->{xmlData}))
	{
		die "Cannot parse electronic signature data, undef";
	}

	if(length($self->{xmlData}) == 0)
	{
		die "Cannot parse electronic signature data, 0 length";
	}

	my $xmlData = $self->{xmlData};

	my $iStart = index($xmlData, $self->{globals}->{BGN_ESIG_MESSAGE});
	my $iEnd   = index($xmlData, $self->{globals}->{END_ESIG_MESSAGE});

	if(($iStart < 0) || ($iEnd < 0))
	{
		die "Cannot parse electronic signature data";
	}

	$iStart += length($self->{globals}->{BGN_ESIG_MESSAGE});

	if(($iStart == $iEnd) || ($iStart > $iEnd))
	{
		die "Cannot parse electronic signature data";
	}

	eval
	{
		&xmlSetFullname($self);
	};

	if($@)
	{

		die "Cannot parse electronic signature data: xmlSetFullname() \n $@";
	}
	
	eval
	{
		&xmlSetUsername($self);
	};

	if($@)
	{

		die "Cannot parse electronic signature data: xmlSetUsername() \n $@";
	}
	
	eval
	{
		&xmlSetDate($self);
	};

	if($@)
	{

		die "Cannot parse electronic signature data: xmlSetDate() \n $@";
	}
	
	eval
	{
		&xmlSetPurpose($self);
	};

	if($@)
	{

		die "Cannot parse electronic signature data: xmlSetPurpose() \n $@";
	}
	
	eval
	{
		&xmlSetComment($self);
	};

	if($@)
	{

		die "Cannot parse electronic signature data: xmlSetComment() \n $@";
	}
	
	eval
	{
		&xmlSetAttribute($self);
	};

	if($@)
	{

		die "Cannot parse electronic signature data: xmlSetAttribute() \n $@";
	}
	
	eval
	{
		&xmlSetCvid($self);
	};

	if($@)
	{

		die "Cannot parse electronic signature data: xmlSetCvid() \n $@";
	}
	
	eval
	{
		&xmlSetCreateTime($self);
	};

	if($@)
	{

		die "Cannot parse electronic signature data: xmlSetCreateTime() \n $@";
	}
}

sub xmlSetFullname()
{
	my $self = shift;

	if(!defined($self->{xmlData}))
	{
		die "Cannot parse electronic signature data, undef";
	}

	my $xmlData = $self->{xmlData};

	my $iStart = index($xmlData, $self->{globals}->{BGN_ESIG_FULLNAME});
	my $iEnd   = index($xmlData, $self->{globals}->{END_ESIG_FULLNAME});

	if(($iStart < 0) || ($iEnd < 0))
	{
		die "Cannot parse electronic signature data";
	}

	$iStart += length($self->{globals}->{BGN_ESIG_FULLNAME});

	if($iStart > $iEnd)
	{
		die "Cannot parse electronic signature data";
	}

	$self->{mFullname} = ChangeSynergy::util::xmlDecode(substr($xmlData, $iStart, $iEnd - $iStart));
}

sub xmlSetUsername()
{
	my $self = shift;

	if(!defined($self->{xmlData}))
	{
		die "Cannot parse electronic signature data, undef";
	}

	my $xmlData = $self->{xmlData};

	my $iStart = index($xmlData, $self->{globals}->{BGN_ESIG_USERNAME});
	my $iEnd   = index($xmlData, $self->{globals}->{END_ESIG_USERNAME});

	if(($iStart < 0) || ($iEnd < 0))
	{
		die "Cannot parse electronic signature data";
	}

	$iStart += length($self->{globals}->{BGN_ESIG_USERNAME});

	if($iStart > $iEnd)
	{
		die "Cannot parse electronic signature data";
	}

	$self->{mUsername} = ChangeSynergy::util::xmlDecode(substr($xmlData, $iStart, $iEnd - $iStart));
}

sub xmlSetDate()
{
	my $self = shift;

	if(!defined($self->{xmlData}))
	{
		die "Cannot parse electronic signature data, undef";
	}

	my $xmlData = $self->{xmlData};

	my $iStart = index($xmlData, $self->{globals}->{BGN_ESIG_DATE});
	my $iEnd   = index($xmlData, $self->{globals}->{END_ESIG_DATE});

	if(($iStart < 0) || ($iEnd < 0))
	{
		die "Cannot parse electronic signature data";
	}

	$iStart += length($self->{globals}->{BGN_ESIG_DATE});

	if($iStart > $iEnd)
	{
		die "Cannot parse electronic signature data";
	}

	my $length     = length(substr($xmlData, $iStart, $iEnd - $iStart));
	$self->{mDate} = substr(substr($xmlData, $iStart, $iEnd - $iStart), 0, ($length -3));
}

sub xmlSetPurpose()
{
	my $self = shift;

	if(!defined($self->{xmlData}))
	{
		die "Cannot parse electronic signature data, undef";
	}

	my $xmlData = $self->{xmlData};

	my $iStart = index($xmlData, $self->{globals}->{BGN_ESIG_PURPOSE});
	my $iEnd   = index($xmlData, $self->{globals}->{END_ESIG_PURPOSE});

	if(($iStart < 0) || ($iEnd < 0))
	{
		die "Cannot parse electronic signature data";
	}

	$iStart += length($self->{globals}->{BGN_ESIG_PURPOSE});

	if($iStart > $iEnd)
	{
		die "Cannot parse electronic signature data";
	}

	$self->{mPurpose} = ChangeSynergy::util::xmlDecode(substr($xmlData, $iStart, $iEnd - $iStart));
}

sub xmlSetComment()
{
	my $self = shift;

	if(!defined($self->{xmlData}))
	{
		die "Cannot parse electronic signature data, undef";
	}

	my $xmlData = $self->{xmlData};

	my $iStart = index($xmlData, $self->{globals}->{BGN_ESIG_COMMENT});
	my $iEnd   = index($xmlData, $self->{globals}->{END_ESIG_COMMENT});

	if(($iStart < 0) || ($iEnd < 0))
	{
		$iStart = index($xmlData, $self->{globals}->{BGN_END_ESIG_COMMENT});

		if ($iStart < 0)
		{
			die "Cannot parse electronic signature data";
		}
		else
		{
			$self->{mComment} = "";
			return;
		}
	}

	$iStart += length($self->{globals}->{BGN_ESIG_COMMENT});

	if($iStart > $iEnd)
	{
		die "Cannot parse electronic signature data";
	}

	$self->{mComment} = ChangeSynergy::util::xmlDecode(substr($xmlData, $iStart, $iEnd - $iStart));
}

sub xmlSetAttribute()
{
	my $self = shift;

	if(!defined($self->{xmlData}))
	{
		die "Cannot parse electronic signature data, undef";
	}

	my $xmlData = $self->{xmlData};

	my $iStart = index($xmlData, $self->{globals}->{BGN_ESIG_ATTRIBUTE});
	my $iEnd   = index($xmlData, $self->{globals}->{END_ESIG_ATTRIBUTE});

	if(($iStart < 0) || ($iEnd < 0))
	{
		die "Cannot parse electronic signature data";
	}

	$iStart += length($self->{globals}->{BGN_ESIG_ATTRIBUTE});

	if($iStart > $iEnd)
	{
		die "Cannot parse electronic signature data";
	}

	$self->{mAttribute} = ChangeSynergy::util::xmlDecode(substr($xmlData, $iStart, $iEnd - $iStart));
}

sub xmlSetCvid()
{
	my $self = shift;

	if(!defined($self->{xmlData}))
	{
		die "Cannot parse electronic signature data, undef";
	}

	my $xmlData = $self->{xmlData};

	my $iStart = index($xmlData, $self->{globals}->{BGN_ESIG_CVID});
	my $iEnd   = index($xmlData, $self->{globals}->{END_ESIG_CVID});

	if(($iStart < 0) || ($iEnd < 0))
	{
		die "Cannot parse electronic signature data";
	}

	$iStart += length($self->{globals}->{BGN_ESIG_CVID});

	if($iStart > $iEnd)
	{
		die "Cannot parse electronic signature data";
	}

	$self->{mCvid} = substr($xmlData, $iStart, $iEnd - $iStart);
}

sub xmlSetCreateTime()
{
	my $self = shift;

	if(!defined($self->{xmlData}))
	{
		die "Cannot parse electronic signature data, undef";
	}

	my $xmlData = $self->{xmlData};

	my $iStart = index($xmlData, $self->{globals}->{BGN_ESIG_CREATE_TIME});
	my $iEnd   = index($xmlData, $self->{globals}->{END_ESIG_CREATE_TIME});

	if(($iStart < 0) || ($iEnd < 0))
	{
		die "Cannot parse electronic signature data";
	}

	$iStart += length($self->{globals}->{BGN_ESIG_CREATE_TIME});

	if($iStart > $iEnd)
	{
		die "Cannot parse electronic signature data";
	}

	$self->{mCreateTime} = substr($xmlData, $iStart, $iEnd - $iStart);
}

1;

__END__

=head1 Name

ChangeSynergy::apiESignatureMessage

=head1 Description

Electronic signatures will allow IBM Rational Change users to sign change requests
at key stages for accountibility purposes.  This feature is desired in the Enterprise
Change Proposal System (ECPS) integration to compliment electronic signatures in DOORS,
but is also applicable to IBM Rational Change proper.

=head1 Methods

The following methods are available:

=over 4

=cut

##############################################################################

=item B<new>

 sub new(xmlData)

Initialize a newly created ChangeSynergy::apiESignatureMessage class so that it 
represents the xml data passed in.

 my $eSigMessage = new ChangeSynergy::apiESignatureMessage(xmlData);
 
 Parameters:
	xmlData  - the XML data that needs to be parsed into a usable form.

 Throws:
	die - if unable to parse the xml data

=cut

##############################################################################

=item B<getAttribute>

Get the electronic signature attribute property.

my $attribtue = $eSigMessage->getAttribute()

 Returns: scalar
	the electronic signature attribute property.

=cut

##############################################################################

=item B<getComment>

Get the electronic signature comment property, this is the comment for the signature.

my $comment = $eSigMessage->getComment()

 Returns: scalar
	the electronic signature comment property.

=cut

##############################################################################

=item B<getCreateTime>

Get the electronic signature create time property, the time when the signature
was created.

my $createTime = $eSigMessage->getCreateTime()

 Returns: scalar
	the electronic signature create time property.

=cut

##############################################################################

=item B<getCvid>

Get the electronic signature cvid property, the problem number.

my $cvid = $eSigMessage->getCvid()

 Returns: scalar
	the electronic signature cvid property.

=cut

##############################################################################

=item B<getDate>

Get the electronic signature date property, this is the date when the signature
was made.

my $date = $eSigMessage->getDate()

 Returns: scalar
	the electronic signature date property.

=cut

##############################################################################

=item B<getDateString>

Get the electronic signature date property, this is the date when the signature
was made.  

my $date = $eSigMessage->getDate()

 Parameters:
	format  - The format string, if undef the default is "%Y/%m/%d %I:%M:%S %p".

	A formatting string similar to the printf formatting string.  Formatting codes,
	precded by a percent (%) sign, are replaced by the corresponding POSIX component.	
	Other characters in the formatting string are copied unchanged to the returned
	string.  See the function strftime for details.  The value and meaning of the 
	formatting codes for format are listed below:
	
	%a: Abbreviated weekday name
	%A: Full weekday name
	%b: Abbreviated month name
	%B: Full month name
	%c: Date and time representation appropriate for local
	%d: Day of month as decimal number (0-31)
	%D: Total days in this CTime.
	%H: Hour in 24-hour format (0-23)
	%I: Hour in 12-hour format (0-12)
	%j: Day of year as decimal number (001 - 336)
	%m: Month as decimal number (0-12)
	%M: Minute as decimal number (0-59)
	%p: current locale's A.M./P.M. indicator for 12-hour clock
	%S: Second as decimal number (00-59)
	%U: Week of year as decimal number, with Sunday as firsrt day of week (00-53)
	%w: Weekday as decimal number (0-6; Sunday is 0)
	%W: Week of year as decimal number, with Monday as first day of week (00-53)
	%x: Date representation for current locale
	%X: Time representation for current locale
	%y: Year without century, as decimal number (00-99)
	%Y: Year with century, as decimal
	%z, %Z: Time-zone name or abbreviation, no characters if time-zone is unknown
	%%: Percent sign 
		
 Returns: scalar
	the electronic signature date property.

=cut

##############################################################################

=item B<getFullname>

Get the electronic signature fullname property, this is the fullname of the user
which made the signature.

my $fullname = $eSigMessage->getFullname()

 Returns: scalar
	the electronic signature fullname property.

=cut

##############################################################################

=item B<getPurpose>

Get the electronic signature purpose property, this is the purpose for the signature.

my $purpose = $eSigMessage->getPurpose()

 Returns: scalar
	the electronic signature purpose property.

=cut

##############################################################################

=item B<getUnencodedComment>

Get the electronic signature comment property, this is the comment for the signature.
The text value will be xml unencoded.

my $comment = $eSigMessage->getUnencodedComment()

 Returns: scalar
	the electronic signature comment property.

=cut

##############################################################################

=item B<getUsername>

Get the electronic signature username property, this is the username of the user
which made the signature.

my $username = $eSigMessage->getUsername()

 Returns: scalar
	the electronic signature username property.

=cut

##############################################################################

=item B<getXmlData>

Get the XML data used to constuct this apiESignatureMessage class. 

Note: This is intended for debugging only.

my $xmlData = $eSigMessage->getXmlData()

 Returns: scalar
	the XML data used to constuct this object, useful for debugging purposes. 

=cut

##############################################################################
