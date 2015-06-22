###########################################################
## apiESignatures Class
###########################################################
package ChangeSynergy::apiESignatures;

use strict;
use warnings;
use ChangeSynergy::apiESignature;

sub new()
{
	shift; #take off the apiESignature which is passed in, this is the class name.

	# Initialize data as an empty hash
	my $self = {};

	# Initialize data for this object
	$self->{xmlData}          = undef;
	$self->{objDataSize}      = -1;
	$self->{objData}          = [];
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
		die "Invalid XML Data: apiESignatures: " . 	$self->{xmlData} . $@;
	}

	return $self;
}

sub getXmlData()
{
	my $self = shift;
	return $self->{xmlData};
}

sub getElectronicSignature()
{
	my $self = shift;
	my $iPos = shift;
	
	if($self->{objDataSize} <= 0)
	{
		die "List is empty";
	}
	
	if(($iPos < 0) || ($iPos >= $self->{objDataSize}))
	{
		die "Invalid index";
	}
	
	return $self->{objData}[$iPos];
}

sub getESignatureSize()
{
	my $self = shift;
	return $self->{objDataSize};
}

#
#	<e_signatures>
#		<e_signature>
#			<message>
#				<fullname>user's first and last name</fullname>
#				<username>operating system login name</username>
#				<date>the date when a signature was created</date>
#				<purpose>a definable enumerated list</purpose>
#				<comment>optional comment</comment>
#				<attribute>the signature attribute</attribute>
#				<cvid>CR's:cvid is required execpt on submit and copy operations</cvid>
#				<create_time>the time that the CR was created</create_time>
#			</message>
#			<digest>the encoded digital signature</digest>
#			<digest_algorithm>optionally specify the digest algorithm: [MD5|MD2|SHA]</digest_algorithm>
#		</e_signature>
#	</e_signatures>
#

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

	my $iStart = index($xmlData, $self->{globals}->{BGN_ESIG_E_SIGNATURES});
	my $iEnd   = index($xmlData, $self->{globals}->{END_ESIG_E_SIGNATURES});

	if(($iStart < 0) || ($iEnd < 0))
	{
		die "Cannot parse electronic signature data";
	}

	$iStart += length($self->{globals}->{BGN_ESIG_E_SIGNATURES});

	if(($iStart == $iEnd) || ($iStart > $iEnd))
	{
		die "Cannot parse electronic signature data";
	}
	
	eval
	{
		&xmlSetObjectSize($self);
	};

	if($@)
	{
		die "Cannot parse electronic signature data: xmlSetobjectSize() \n $@";
	}
	
	eval
	{
		&xmlSetObjectData($self);
	};

	if($@)
	{
		die "Cannot parse electronic signature data: xmlSetObjectData() \n $@";
	}
}

sub xmlSetObjectData
{
	my $self = shift;

	if($self->{objDataSize} < 0)
	{
		return;
	}

	if(!defined($self->{xmlData}))
	{
		die "Cannot parse elecetronic signature data, undef";
	}

	my $xmlData = $self->{xmlData};

	my $iStart = 0;
	my $iEnd   = -1;
	my $i;

	for($i = 0; $i < $self->{objDataSize}; $i++)
	{
		$iStart = index($xmlData, $self->{globals}->{BGN_ESIG_E_SIGNATURE}, $iStart);
		$iEnd   = index($xmlData, $self->{globals}->{END_ESIG_E_SIGNATURE}, $iStart);

		if(($iStart < 0) || ($iEnd < 0))
		{
			die "Cannot parse elecetronic signature data";
		}

		$iEnd += length($self->{globals}->{END_ESIG_E_SIGNATURE});

		if(($iStart == $iEnd) || ($iStart > $iEnd))
		{
			die "Cannot parse elecetronic signature data";
		}

		eval
		{
			push @{$self->{objData}}, new ChangeSynergy::apiESignature(substr($xmlData, $iStart, $iEnd - $iStart), $self);
		};

		if($@)
		{
			 die $@;
		}

		$iStart = $iEnd;
	}
}

sub xmlSetObjectSize
{
	my $self = shift;

	if(!defined($self->{xmlData}))
	{
		die "Cannot parse electronic signature size data, undef";
	}

	my $xmlData = $self->{xmlData};

	$self->{objDataSize} = 0;

	my $iStart = index($xmlData, $self->{globals}->{BGN_ESIG_E_SIGNATURE});
	my $iLen   = length($self->{globals}->{BGN_ESIG_E_SIGNATURE});

	while($iStart >= 0)
	{
		$self->{objDataSize} += 1;
		$iStart = index($xmlData, $self->{globals}->{BGN_ESIG_E_SIGNATURE}, $iStart + $iLen);
	}
}

1;

__END__

=head1 Name

ChangeSynergy::apiESignatures

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

Initialize a newly created ChangeSynergy::apiESignatures class so that it 
represents the xml data passed in.

 my $eSigs = new ChangeSynergy::apiESignatures(xmlData);
 
 Parameters:
	xmlData  - the XML data that needs to be parsed into a usable form.

 Throws:
	die - if unable to parse the xml data

=cut

##############################################################################

=item B<getElectronicSignature>

Get one electronic signature data object based upon a position in the object array.
The return result is an instance of the L<apiESignature> class.

my $eSig = $eSigs->getElectronicSignature();

 Parameters:
	iPos - the index position to retrieve the data.

 Returns: apiESignature
	one electronic signature object.

=cut

##############################################################################

=item B<getESignatureSize>

Get the quantity of electronic signature objects.

my $eSigSize = $eSigs->getESignatureSize();

 Returns: scalar
	the number of electronic signature objects in this eSignature.

=cut

##############################################################################

=item B<getXmlData>

Get the XML data used to constuct this apiESignature class. 

Note: This is intended for debugging only.

my $xmlData = $eSigs->getXmlData()

 Returns: scalar
	the XML data used to constuct this object, useful for debugging purposes. 

=cut

##############################################################################