###########################################################
## apiSubscription Class
###########################################################
package ChangeSynergy::apiSubscription;

use strict;
use warnings;
use ChangeSynergy::apiSubscriber;

sub new()
{
	shift; #take off the apiSubscription which is passed in, this is the class name.

	# Initialize data as an empty hash
	my $self = {};

	# Initialize data for this object
	$self->{xmlData}          = undef;
	$self->{objDataSize}      = 0;
	$self->{objData}          = [];
	$self->{globals}		  = new ChangeSynergy::Globals();
	$self->{addIncrementer}   = 101; #used to get time into a millisecond time form.

	# If a parameter was passed in then set it as the xmlData
	if(@_ == 1)
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
		die "Invalid XML Data: apiSubscription: " . 	$self->{xmlData} . $@;
	}

	return $self;
}

sub getXmlData()
{
	my $self = shift;
	return $self->{xmlData};
}

sub getSubscriber()
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

sub getSubscriberByUserName()
{
	my $self	    = shift;
	my $searchValue = shift;
	 
	for(my $i = 0; $i < &getSubscriberSize($self); $i++)
	{
		my $value = $self->{objData}[$i]->getUserName() cmp $searchValue;

		if($value == 0)
		{
			return $self->{objData}[$i];
		}
	}
	
	die "Could not find subscriber '" . $searchValue ."' in list.";
}

sub getSubscriberByEmailAddress()
{
	my $self	    = shift;
	my $searchValue = shift;
	 
	for(my $i = 0; $i < &getSubscriberSize($self); $i++)
	{
		my $value = $self->{objData}[$i]->getEmailAddress() cmp $searchValue;

		if($value == 0)
		{
			return $self->{objData}[$i];
		}
	}
	
	die "Could not find email address '" . $searchValue ."' in list.";
}

sub getSubscriberByRealName()
{
	my $self	    = shift;
	my $searchValue = shift;
	 
	for(my $i = 0; $i < &getSubscriberSize($self); $i++)
	{
		my $value = $self->{objData}[$i]->getRealName() cmp $searchValue;

		if($value == 0)
		{
			return $self->{objData}[$i];
		}
	}
	
	die "Could not find subscriber '" . $searchValue ."' in list.";
}

sub getSubscriberSize()
{
	my $self = shift;
	return $self->{objDataSize};
}

sub addSubscriber()
{
	my $self     = shift;
	my $userName = shift;
	my $realName = shift;
	my $email    = shift;
	
	if(length($userName) == 0)
	{
		die "Username is required to add a user.";
	}
	
	if(length($realName) == 0)
	{
		die "Real name is required to add a user.";
	}
	
	if(length($email) == 0)
	{
		die "Email address is required to add a user.";
	}
	
	my $foundIndex = -1;
	
	for(my $i = 0; $i < $self->{objDataSize}; $i++)
	{
		if($self->{objData}[$i]->getStatus() != $self->{globals}->{DELETED})
		{
			if($self->{objData}[$i]->getUserName() eq $userName)
			{
				die "Username '" . $userName . "' already exists in the subscribers list.";	
			}
		}
		else
		{
			if($self->{objData}[$i]->getRealName() eq $realName)
			{
				$foundIndex = $i;
			}
		}
	}	
	
	if($foundIndex == -1)
	{
		my $sec;
		my $min;
		my $hour;
		my $mday;
		my $mon;
		my $year;
		
		($sec, $min, $hour, $mday, $mon, $year) = localtime(time);
		
		$self->{addIncrementer} = $self->{addIncrementer} + 1;
		$self->{objDataSize}    = $self->{objDataSize} + 1;
			
		push @{$self->{objData}}, new ChangeSynergy::apiSubscriber($userName, $realName, $email);
	}
	else
	{
		my $subscriber = $self->{objData}[$foundIndex];

		$subscriber->setUserName($userName);
		$subscriber->setRealName($realName);
		$subscriber->setEmailAddress($email);
		$subscriber->setStatus($self->{globals}->{ADDED});
	}	
}

sub toSubmitXml()
{
	my $self	= shift;
	my $xmlData = "";
	
	for(my $i = 0; $i < $self->{objDataSize}; $i++)
	{
		$xmlData .= $self->{objData}[$i]->toSubmitXml();
	}
	
	if(length($xmlData) != 0)
	{
		$xmlData = "<?xml version=\'1.0\' encoding=\'US-ASCII\'?>" . $self->{globals}->{BGN_SUBSCRIPTION} . $xmlData;
		$xmlData .= $self->{globals}->{END_SUBSCRIPTION};
	}
	
	return $xmlData;
}


#
# <subscription>
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
#	.
#	.
#	.
# </subscription>
#

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

	my $iStart = index($xmlData, $self->{globals}->{BGN_SUBSCRIPTION});
	my $iEnd   = index($xmlData, $self->{globals}->{END_SUBSCRIPTION});

	if(($iStart < 0) || ($iEnd < 0))
	{
		die "Cannot parse subscription data";
	}

	$iStart += length($self->{globals}->{BGN_SUBSCRIPTION});

	#if(($iStart == $iEnd) || ($iStart > $iEnd))
	#{
	#	die "Cannot parse subscription data";
	#}
	
	eval
	{
		&xmlSetObjectSize($self);
	};

	if($@)
	{
		die "Cannot parse subscription data: xmlSetobjectSize() \n $@";
	}
	
	eval
	{
		&xmlSetObjectData($self);
	};

	if($@)
	{
		die "Cannot parse subscription data: xmlSetObjectData() \n $@";
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
		die "Cannot parse subscription data, undef";
	}

	my $xmlData = $self->{xmlData};

	my $iStart = 0;
	my $iEnd   = -1;
	my $i;

	for($i = 0; $i < $self->{objDataSize}; $i++)
	{
		$iStart = index($xmlData, $self->{globals}->{BGN_SUBSCRIBER}, $iStart);
		$iEnd   = index($xmlData, $self->{globals}->{END_SUBSCRIBER}, $iStart);

		if(($iStart < 0) || ($iEnd < 0))
		{
			die "Cannot parse subscription data";
		}

		$iEnd += length($self->{globals}->{END_SUBSCRIBER});

		if(($iStart == $iEnd) || ($iStart > $iEnd))
		{
			die "Cannot parse subscription data";
		}

		eval
		{
			push @{$self->{objData}}, new ChangeSynergy::apiSubscriber(substr($xmlData, $iStart, $iEnd - $iStart));
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
		die "Cannot parse subscription size data, undef";
	}

	my $xmlData = $self->{xmlData};

	$self->{objDataSize} = 0;

	my $iStart = index($xmlData, $self->{globals}->{BGN_SUBSCRIBER});
	my $iLen   = length($self->{globals}->{BGN_SUBSCRIBER});

	while($iStart >= 0)
	{
		$self->{objDataSize} += 1;
		$iStart = index($xmlData, $self->{globals}->{BGN_SUBSCRIBER}, $iStart + $iLen);
	}
}

1;

__END__

=head1 Name

ChangeSynergy::apiSubscription

=head1 Description

Subscription lists will allow users to mark themselves as a subscriber to a CR.  When
a user requests to become a subscriber of a CR they want to be notified any time the
CR changes.  This class allows the API to get and modify the users subscribed to
a particular list. The XML format used to construct an instance of this class is
as follows:

 <subscription>
	<subscriber>
		<username>
			user name
		</username>
		<email>
			user email
		</email>
		<realname>
			real name
		</realname>
	</subscriber>
	.
	.
	.
 </subscription>

=head1 Methods

The following methods are available:

=over 4

=cut

##############################################################################

=item B<new>

 sub new(xmlData)

Initialize a newly created ChangeSynergy::apiSubscription class so that it 
represents the xml data passed in.

 my $subscription = new ChangeSynergy::apiSubscription(xmlData);
 
 Parameters:
	xmlData  - the XML data that needs to be parsed into a usable form.

 Throws:
	die - if unable to parse the xml data

=cut

##############################################################################

=item B<addSubscriber>

Add a new subscriber to the subscription list.  All parameters are required.

Note: This does not immediately add the subscriber to the list.  The CR
must be updated with the new XML information before the subscriber is added.
See the example in the L<apiObjectData> class under the getSubscription() method.

$subscription->addSubscriber("jsmith", "John Smith", "John.Smith@company.com");

 Parameters:
	userName - The username of the user to add to the subscription list.
	realName - The real name of the user to add to the subscription list.
	eMail    - The email address of the usr to add to the subscription list.

 Throws:
 	die - If the supplied username is already in use by another user in the list..

=cut

##############################################################################

=item B<getSubscriber>

Get one subscriber data object based upon a position in the object array.
The return result is an instance of the L<apiSubscriber> class.

my $subscriber = $subscription->getSubscriber($iPos);

 Parameters:
	iPos - the index position to retrieve the data.

 Returns: apiSubscriber
	one subscriber object.

=cut

##############################################################################

=item B<getSubscriberByEmailAddress>

Get one subscriber data object based upon the subscribers e-mail address.
The return result is an instance of the L<apiSubscriber> class.

Note: The backslash character ("\") must be used to escape the at sign ("@").

my $subscriber = $subscription->getSubscriberByEmailAddress("John.Smith\@company.com");

 Parameters:
	email - the email address of the user object to retrieve.

 Returns: apiSubscriber
	one subscriber object.
	
 Throws:
	die - if the users e-mail address does not exist in the subscriber list.

=cut

##############################################################################


=item B<getSubscriberByRealName>

Get one subscriber data object based upon the subscribers real name.
The return result is an instance of the L<apiSubscriber> class.

my $subscriber = $subscription->getSubscriberByRealName("John Smith");

 Parameters:
	realName - the real name of the user object to retrieve.

 Returns: apiSubscriber
	one subscriber object.
	
 Throws:
	die - if the users real name does not exist in the subscriber list.

=cut

##############################################################################

=item B<getSubscriberByUserName>

Get one subscriber data object based upon the subscribers username.
The return result is an instance of the L<apiSubscriber> class.

my $subscriber = $subscription->getSubscriberByUserName("u00001");

 Parameters:
	username - the username of the user object to retrieve.

 Returns: apiSubscriber
	one subscriber object.
	
 Throws:
	die - if username does not exist in the subscriber list.

=cut

##############################################################################

=item B<getSubscriberSize>

Get the quantity of subscriber objects.

my $subSize = $subscription->getSubscriberSize();

 Returns: scalar
	the number of subscriber objects in this subscription.

=cut

##############################################################################

=item B<getXmlData>

Get the XML data used to constuct this apiSubscription object. 

Note: This is intended for debugging only.

my $xmlData = $subscription->getXmlData();

 Returns: scalar
	the XML data used to constuct this object, useful for debugging purposes. 

=cut

##############################################################################

=item B<toSubmitXml>

Get the XML data to send to the IBM Rational Change server to update the subscription list.

my $xmlData = $subscription->toSubmitXml();

 Returns: scalar
	the XML data to be sent to the IBM Rational Change server.

=cut

##############################################################################