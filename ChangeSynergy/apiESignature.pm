###########################################################
## apiESignature Class
###########################################################
package ChangeSynergy::apiESignature;

use strict;
use warnings;
use ChangeSynergy::apiESignatureMessage;

sub new()
{
	shift; #take off the apiESignature which is passed in, this is the class name.

	# Initialize data as an empty hash
	my $self = {};

	# Initialize data for this object
	$self->{xmlData}          = undef;
	$self->{mDigest}          = undef;
	$self->{mDigestAlgorithm} = undef;
	$self->{mVersion}         = undef;
	$self->{eSigMessage}      = undef;
	$self->{globals}		  = new ChangeSynergy::Globals();

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
		die "Invalid XML Data: apiESignature: " . 	$self->{xmlData} . $@;
	}

	return $self;
}

sub getXmlData()
{
	my $self = shift;
	return $self->{xmlData};
}

sub getDigest()
{
	my $self = shift;
	return $self->{mDigest};
}

sub getDigestAlgorithm()
{
	my $self = shift;
	return $self->{mDigestAlgorithm};
}

sub getVersion()
{
	my $self = shift;
	return $self->{mVersion};
}

sub getMessage()
{
	my $self = shift;
	return $self->{eSigMessage};
}

#
#	<e_signature>
#		<message>
#			<fullname>user's first and last name</fullname>
#			<username>operating system login name</username>
#			<date>the date when a signature was created</date>
#			<purpose>a definable enumerated list</purpose>
#			<comment>optional comment</comment>
#			<attribute>the signature attribute</attribute>
#			<cvid>CR's:cvid is required execpt on submit and copy operations</cvid>
#			<create_time>the time that the CR was created</create_time>
#		</message>
#		<digest>the encoded digital signature</digest>
#		<digest_algorithm>optionally specify the digest algorithm: [MD5|MD2|SHA]</digest_algorithm>
#	</e_signature>

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

	my $iStart = index($xmlData, $self->{globals}->{BGN_ESIG_E_SIGNATURE});
	my $iEnd   = index($xmlData, $self->{globals}->{END_ESIG_E_SIGNATURE});
	
	if(($iStart < 0) || ($iEnd < 0))
	{
		die "Cannot parse electronic signature data";
	}

	$iStart += length($self->{globals}->{BGN_ESIG_E_SIGNATURE});

	if(($iStart == $iEnd) || ($iStart > $iEnd))
	{
		die "Cannot parse electronic signature data";
	}

	eval
	{		
		&xmlSetDigest($self);
	};

	if($@)
	{

		die "Cannot parse electronic signature data: xmlSetDigest() \n $@";
	}
	
	eval
	{
		&xmlSetDigestAlgorithm($self);
	};

	if($@)
	{

		die "Cannot parse electronic signature data: xmlSetDigestAlgorithm() \n $@";
	}
	
	eval
	{
		&xmlSetVersion($self);
	};

	if($@)
	{

		die "Cannot parse electronic signature data: xmlSetVersion() \n $@";
	}
	
	eval
	{
		&xmlSetMessage($self);
	};

	if($@)
	{
		die "Cannot parse electronic signature data: xmlSetMessage() \n $@";
	}
}

sub xmlSetDigest()
{
	my $self = shift;

	if(!defined($self->{xmlData}))
	{
		die "Cannot parse object data, undef";
	}

	my $xmlData = $self->{xmlData};

	my $iStart = index($xmlData, $self->{globals}->{BGN_ESIG_DIGEST});
	my $iEnd   = index($xmlData, $self->{globals}->{END_ESIG_DIGEST});

	if(($iStart < 0) || ($iEnd < 0))
	{
		die "Cannot parse electronic signature data";
	}

	$iStart += length($self->{globals}->{BGN_ESIG_DIGEST});

	if($iStart > $iEnd)
	{
		die "Cannot parse electronic signature data";
	}
			
	$self->{mDigest} = ChangeSynergy::util::xmlDecode(substr($xmlData, $iStart, $iEnd - $iStart));
}

sub xmlSetDigestAlgorithm()
{
	my $self = shift;

	if(!defined($self->{xmlData}))
	{
		die "Cannot parse object data, undef";
	}

	my $xmlData = $self->{xmlData};

	my $iStart = index($xmlData, $self->{globals}->{BGN_ESIG_DIGEST_ALGORITHM});
	my $iEnd   = index($xmlData, $self->{globals}->{END_ESIG_DIGEST_ALGORITHM});

	if(($iStart < 0) || ($iEnd < 0))
	{
		die "Cannot parse electronic signature data";
	}

	$iStart += length($self->{globals}->{BGN_ESIG_DIGEST_ALGORITHM});

	if($iStart > $iEnd)
	{
		die "Cannot parse electronic signature data";
	}

	$self->{mDigestAlgorithm} = ChangeSynergy::util::xmlDecode(substr($xmlData, $iStart, $iEnd - $iStart));
}

sub xmlSetVersion()
{
	my $self = shift;

	if(!defined($self->{xmlData}))
	{
		die "Cannot parse object data, undef";
	}

	my $xmlData = $self->{xmlData};

	my $iStart = index($xmlData, $self->{globals}->{BGN_ESIG_VERSION});
	my $iEnd   = index($xmlData, $self->{globals}->{END_ESIG_VERSION});

	if(($iStart < 0) || ($iEnd < 0))
	{
		die "Cannot parse electronic signature data";
	}

	$iStart += length($self->{globals}->{BGN_ESIG_VERSION});

	if($iStart > $iEnd)
	{
		die "Cannot parse electronic signature data";
	}

	$self->{mVersion} = substr($xmlData, $iStart, $iEnd - $iStart);
}

sub xmlSetMessage()
{
	my $self = shift;

	if(!defined($self->{xmlData}))
	{
		die "Cannot parse object data, undef";
	}

	my $xmlData = $self->{xmlData};

	my $iStart = index($xmlData, $self->{globals}->{BGN_ESIG_MESSAGE});
	my $iEnd   = index($xmlData, $self->{globals}->{END_ESIG_MESSAGE});

	if(($iStart < 0) || ($iEnd < 0))
	{
		die "Cannot parse electronic signature data";
	}

	$iEnd += length($self->{globals}->{END_ESIG_MESSAGE});

	if(($iStart == $iEnd) || ($iStart > $iEnd))
	{
		die "Cannot parse electronic signature data";
	}

	eval
	{
		$self->{eSigMessage} = new ChangeSynergy::apiESignatureMessage(substr($xmlData, $iStart, $iEnd - $iStart));
	};

	if($@)
	{
		die $@;
	}
}

1;

__END__

=head1 Name

ChangeSynergy::apiESignature

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

Initialize a newly created ChangeSynergy::apiESignature class so that it 
represents the xml data passed in.

 my $eSig = new ChangeSynergy::apiESignature(xmlData);
 
 Parameters:
	xmlData  - the XML data that needs to be parsed into a usable form.

 Throws:
	die - if unable to parse the xml data

=cut

##############################################################################

=item B<getDigest>

Get the electronic signature digest property.

my $digest = $eSig->getDigest()

 Returns: scalar
	the electronic signature digest property.

=cut

##############################################################################

=item B<getDigestAlgorithm>

Get the electronic signature digest algorithm property.

my $digestAlgorithm = $eSig->getDigestAlgorithm()

 Returns: scalar
	the electronic signature digest algorithm property.

=cut

##############################################################################

=item B<getMessage>

Get the electronic signature message property. The return result is an instance of
the L<apiESignatureMessage> class.

my $eSigMessage = $eSig->getMessage()

 Returns: apiESignatureMessage
	the electronic signature message property.

=cut

##############################################################################

=item B<getVersion>

Get the electronic signature version property.

my $version = $eSig->getVersion()

 Returns: scalar
	the electronic signature version property.

=cut

##############################################################################

=item B<getXmlData>

Get the XML data used to constuct this apiESignatureMessage class. 

Note: This is intended for debugging only.

my $xmlData = $eSig->getXmlData()

 Returns: scalar
	the XML data used to constuct this object, useful for debugging purposes. 

=cut

##############################################################################
