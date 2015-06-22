###########################################################
## apiSubscriber Class
###########################################################
package ChangeSynergy::apiSubscriber;

use strict;
use warnings;

sub new()
{
	shift; #take off the apiSubscriber which is passed in, this is the class name.

	# Initialize data as an empty hash
	my $self = {};

	# Initialize data for this object
	$self->{xmlData}          = undef;
	$self->{mUserName}        = undef;
	$self->{mEmail}           = undef;
	$self->{mRealName}        = undef;
	$self->{globals}		  = new ChangeSynergy::Globals();
	$self->{mAction}          = $self->{globals}->{UNCHANGED}; #Used internally to represent added, deleted or modified.

	# If a parameter was passed in then set it as the xmlData
	if(@_ == 1)
	{
		$self->{xmlData}     = shift;
	}
	elsif(@_ == 4)
	{
		$self->{mUserName} = shift;
		$self->{mRealName} = shift;
		$self->{mEmail}    = shift;
		$self->{mAction}   = $self->{globals}->{ADDED};
		
		bless $self;
		return $self;
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
		die "Invalid XML Data: apiSubscriber: " . 	$self->{xmlData} . $@;
	}

	return $self;
}

sub getXmlData()
{
	my $self = shift;
	return $self->{xmlData};
}

sub getStatus()
{
	my $self = shift;
	return $self->{mAction};
}

sub getUserName()
{
	my $self = shift;
	return $self->{mUserName};
}

sub getEmailAddress()
{
	my $self = shift;
	return $self->{mEmail};
}

sub getRealName()
{
	my $self = shift;
	return $self->{mRealName};
}

sub setUserName()
{
	my $self  = shift;
	my $value = shift;
	
	$self->{mUserName} = $value;
	$self->{mAction}   = $self->{globals}->{MODIFIED};
}

sub setEmailAddress()
{
	my $self  = shift;
	my $value = shift;

	$self->{mEmail}  = $value;
	$self->{mAction} = $self->{globals}->{MODIFIED};
}

sub setRealName()
{
	my $self  = shift;
	my $value = shift;

	$self->{mRealName} = $value;
	$self->{mAction}   = $self->{globals}->{MODIFIED};
}

#Exists but is not documented, normal users do not need this.
sub setStatus()
{
	my $self  = shift;
	my $value = shift;
	
	$self->{mAction} = $value;
}

sub toSubmitXml()
{
	my $self	= shift;
	my $xmlData = "";
	
	if($self->{mAction} != $self->{globals}->{UNCHANGED})
	{
		$xmlData .= $self->{globals}->{BGN_SUBSCRIBER};
			
			$xmlData .= $self->{globals}->{BGN_SUB_USERNAME};
				$xmlData .= $self->{mUserName};
			$xmlData .= $self->{globals}->{END_SUB_USERNAME};
			
			$xmlData .= $self->{globals}->{BGN_SUB_REALNAME};
				$xmlData .= $self->{mRealName};
			$xmlData .= $self->{globals}->{END_SUB_REALNAME};
			
			$xmlData .= $self->{globals}->{BGN_SUB_EMAIL};
				$xmlData .= $self->{mEmail};
			$xmlData .= $self->{globals}->{END_SUB_EMAIL};
			
			$xmlData .= "<action>";
				$xmlData .= $self->{mAction};
			$xmlData .= "</action>";
		
		$xmlData .= $self->{globals}->{END_SUBSCRIBER};
	}
}

sub deleteSubscriber()
{
	my $self = shift;
	
	$self->{mAction} = $self->{globals}->{DELETED};
}

#	<subscriber>
#		<username>
#			user name
#		</username>
#		<email>
#			user email
#		</email>
#		<realname>
#			real name
#		</realname>
#	</subscriber>

sub parseXml()
{
	my $self = shift;

	if(!defined($self->{xmlData}))
	{
		die "Cannot parse subscription data, undef";
	}

	if(length($self->{xmlData}) == 0)
	{
		die "Cannot parse subscription data, 0 length";
	}

	my $xmlData = $self->{xmlData};

	my $iStart = index($xmlData, $self->{globals}->{BGN_SUBSCRIBER});
	my $iEnd   = index($xmlData, $self->{globals}->{END_SUBSCRIBER});
	
	if(($iStart < 0) || ($iEnd < 0))
	{
		die "Cannot parse subscription data";
	}

	$iStart += length($self->{globals}->{BGN_SUBSCRIBER});

	if(($iStart == $iEnd) || ($iStart > $iEnd))
	{
		die "Cannot parse subscription data";
	}

	eval
	{
		&xmlSetUserName($self);
	};

	if($@)
	{

		die "Cannot parse subscription data: xmlSetUserName() \n $@";
	}
	
	eval
	{
		&xmlSetRealName($self);
	};

	if($@)
	{

		die "Cannot parse subscription data: xmlSetRealName() \n $@";
	}
	
	eval
	{
		&xmlSetEmail($self);
	};

	if($@)
	{

		die "Cannot parse subscription data: xmlSetEmail() \n $@";
	}	
}

sub xmlSetUserName()
{
	my $self = shift;

	if(!defined($self->{xmlData}))
	{
		die "Cannot parse object data, undef";
	}

	my $xmlData = $self->{xmlData};

	my $iStart = index($xmlData, $self->{globals}->{BGN_SUB_USERNAME});
	my $iEnd   = index($xmlData, $self->{globals}->{END_SUB_USERNAME});

	if(($iStart < 0) || ($iEnd < 0))
	{
		die "Cannot parse subscription data";
	}

	$iStart += length($self->{globals}->{BGN_SUB_USERNAME});

	if($iStart > $iEnd)
	{
		die "Cannot parse subscription data";
	}

	$self->{mUserName} = ChangeSynergy::util::xmlDecode(substr($xmlData, $iStart, $iEnd - $iStart));
}

sub xmlSetRealName()
{
	my $self = shift;

	if(!defined($self->{xmlData}))
	{
		die "Cannot parse object data, undef";
	}

	my $xmlData = $self->{xmlData};

	my $iStart = index($xmlData, $self->{globals}->{BGN_SUB_REALNAME});
	my $iEnd   = index($xmlData, $self->{globals}->{END_SUB_REALNAME});

	if(($iStart < 0) || ($iEnd < 0))
	{
		die "Cannot parse subscription data";
	}

	$iStart += length($self->{globals}->{BGN_SUB_REALNAME});

	if($iStart > $iEnd)
	{
		die "Cannot parse subscription data";
	}

	$self->{mRealName} = ChangeSynergy::util::xmlDecode(substr($xmlData, $iStart, $iEnd - $iStart));
}

sub xmlSetEmail()
{
	my $self = shift;

	if(!defined($self->{xmlData}))
	{
		die "Cannot parse object data, undef";
	}

	my $xmlData = $self->{xmlData};

	my $iStart = index($xmlData, $self->{globals}->{BGN_SUB_EMAIL});
	my $iEnd   = index($xmlData, $self->{globals}->{END_SUB_EMAIL});

	if(($iStart < 0) || ($iEnd < 0))
	{
		die "Cannot parse subscription data";
	}

	$iStart += length($self->{globals}->{BGN_SUB_EMAIL});

	if($iStart > $iEnd)
	{
		die "Cannot parse subscription data";
	}

	$self->{mEmail} = ChangeSynergy::util::xmlDecode(substr($xmlData, $iStart, $iEnd - $iStart));
}

1;

__END__

=head1 Name

ChangeSynergy::apiSubscriber

=head1 Description

Subscription lists will allow users to mark themselves as a subscriber to a CR.  When
a user requests to become a subscriber of a CR they want to be notified any time the
CR changes.  This class allows operations on a single user of a subscription list.

=head1 Methods

The following methods are available:

=over 4

=cut

##############################################################################

=item B<new>

 sub new(xmlData)

Initialize a newly created ChangeSynergy::apiSubscriber class so that it 
represents the xml data passed in.

 my $subscriber = new ChangeSynergy::apiSubscriber(xmlData);
 
 Parameters:
	xmlData  - the XML data that needs to be parsed into a usable form.

 Throws:
	die - if unable to parse the xml data

=cut

##############################################################################

=item B<deleteSubscriber>

Mark the current subscriber as deleted from the subscription list.  

Note: This does not immediately remove the subscriber from the list.  The CR
must be updated with the new XML information before the subscriber is removed.
See the example in the L<apiObjectData> class under the getSubscription() method for
how to update the CR with the new XML.

$subscriber->deleteSubscriber();

=cut

##############################################################################

=item B<getEmailAddress>

Get the e-mail address property.

my $xmlData = $subscriber->getEmailAddress();

 Returns: scalar
	The e-mail address of the subscriber represented by this object.

=cut

##############################################################################


=item B<getRealName>

Get the real name property.

my $xmlData = $subscriber->getRealName();

 Returns: scalar
	The real name of the subscriber represented by this object.

=cut

##############################################################################

=item B<getStatus>

Get the current status of the subscriber object.  This can be any one of the following
values: globals->{UNCHANGED}, globals->{DELETED}, globals->{ADDED} or globals->{MODIFIED}.
This information is mainly used to update the XML structure on the server.

my $xmlData = $subscriber->getXmlData();

 Returns: scalar
	The status of the subscriber.

=cut

##############################################################################

=item B<getUserName>

Get the username property.

my $xmlData = $subscriber->getUserName();

 Returns: scalar
	The username of the subscriber represented by this object.

=cut

##############################################################################

=item B<getXmlData>

Get the XML data used to constuct this apiSubscriber object. 

Note: This is intended for debugging only.

my $xmlData = $subscriber->getXmlData();

 Returns: scalar
	the XML data used to constuct this object, useful for debugging purposes. 

=cut

##############################################################################

=item B<setEmailAddress>

Set the email address property for the subscriber. 

$subscriber->setEmailAddress("John.Smith@company.com");

=cut

##############################################################################

=item B<setRealName>

Set the real name property for the subscriber.

$subscriber->setRealName("John Smith");

=cut

##############################################################################

=item B<setUserName>

Set the username property for the subscriber.

$subscriber->setUserName("jsmith");

=cut

##############################################################################

=item B<toSubmitXml>

Get the XML data to send to the IBM Rational Change server to update the subscription list.
This method is called when the toSubmitXml method of the ChangeSynergy::apiSubscription
object is called.

my $xmlData = $subscriber->toSubmitXml();

 Returns: scalar
	the XML data to be sent to the IBM Rational Change server.

=cut

##############################################################################
