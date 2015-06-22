###########################################################
## apiData Class
###########################################################
package ChangeSynergy::apiData;

use strict;
use warnings;

sub new
{
	shift;

	# Initialize data as an empty hash
	my $self = {};

	# If a parameter was passed in then set the response data
	if(@_ == 1)
	{
		$self->{strResponseData}		= shift;
		$self->{byteResponseData}		= undef;
		$self->{byteResponseDataSize}	= 0;
	}
	elsif(@_ == 2)
	{
		$self->{strResponseData}		= undef;
		$self->{byteResponseData}		= shift;
		$self->{byteResponseDataSize}	= shift;
	}
	else
	{
		die "Cannot set response data, undef";
	}
	
	bless $self;

	return $self;
}

sub getResponseByteData
{
	my $self = shift;

	if(!defined($self->{byteResponseData}))
	{
		die "Cannot get byte response data, undef";
	}

	return $self->{byteResponseData};	
}

sub getResponseByteDataSize
{
	my $self = shift;

	if(!defined($self->{byteResponseDataSize}))
	{
		die "Cannot get response byte data size, undef";
	}

	return $self->{byteResponseDataSize};

}

sub getResponseData
{
	my $self = shift;

	if(!defined($self->{strResponseData}))
	{
		die "Cannot get response data, undef";
	}

	return $self->{strResponseData};
}

1;

__END__

=head1 Name

ChangeSynergy::apiData

=head1 Description

ChangeSynergy::apiData holds the response data.

=head1 Methods

The following methods are available:

=over 4

=cut

##############################################################################

=item B<new>

 sub new(responseData)
 sub new(byteResponseData, byteResponseDataSize)

Initializes a newly created ChangeSynergy::apiData class so that it 
represents the response data from the server.

 my $data = new ChangeSynergy::apiData(responseData);
 my $data = new ChangeSynergy::apiData(byteResponseData, byteResponseDataSize);

 Parameters:
	responseData         - the ascii response from the server
	byteResponseData     - the binary response from the server
	byteResponseDataSize - the size of the binary response

 Throws:
	die - if no parameters are sent to the constructor.

=cut

##############################################################################

=item B<getResponseByteData>

Get the response byte data.

This method is used when the server returns binary data information such as when
retrieving files.

my $responseData = $data->getResponseByteData()

 Returns: scalar
	the response byte data specified in the creation of this apiData object.

 Throws:
	die - if the byte response data is undef.

=cut

##############################################################################

=item B<getResponseByteDataSize>

Gets the response byte data size. 

This method is used when the server returns binary data information such as when
retrieving files.

my $dataSize = $data->getResponseByteDataSize()

 Returns: scalar
	the response byte data size specified in the creation of this apiData object.

 Throws:
	die - if the byte response data size is undef.


=cut

##############################################################################

=item B<getResponseData>

Gets the response data.

my $responseData = $data->getResponseData()

 Returns: scalar
	the response data specified in the creation of this apiData object.

 Throws:
	die - if the response data is undef.

=cut
