package ChangeSynergy::TriggerParser;

use strict;
use warnings;

use vars qw(); #this is the globals section
use ChangeSynergy::util; #The xmlDecode method exists in this class.
use XML::Lite; #We need this to actually do the XML parsing for us.

sub new 
{
	shift;

	# Initialize data as an empty hash.
	my $self    = {};

	# Bless reference into class;
	bless $self;

	# Get the xml file and create the XML parsing object.
	my $xmlFile = shift;

	if($xmlFile =~ /"(.*?)"/gs)
	{
		$xmlFile = $1;
	}

	if(defined($xmlFile))
	{
		my $xml      = new XML::Lite($xmlFile);
		$self->{xml} = $xml;
	}
	else
	{
		$self->{xml} = undef;
	}

	#setup the attributes
	$self->{trigger_host}          = undef;	
	$self->{trigger_port}          = undef;
	$self->{trigger_protocol}      = undef;
	$self->{trigger_token}         = undef;
	$self->{trigger_admin_token}   = undef;
	$self->{trigger_user}          = undef;
	$self->{trigger_admin_user}    = undef;
	$self->{trigger_role}          = undef;
	$self->{trigger_host}          = undef;
	$self->{trigger_database}      = undef;
	$self->{trigger_object_type}   = undef;
	$self->{trigger_object_id}     = undef;
	$self->{trigger_relation_type} = undef;
	$self->{trigger_relation_name} = undef;
	$self->{trigger_to_state}      = undef;
	$self->{trigger_from_state}    = undef;
	$self->{trigger_to_object}     = undef;
	$self->{trigger_from_object}   = undef;
	$self->{trigger_database_uid}  = undef;
	$self->{trigger_dcm_delimiter} = undef;
	$self->{trigger_sub_emails}    = undef;
	$self->{trigger_from_email_addr} = undef;
	$self->{trigger_smtp_server}   = undef;
	$self->{trigger_relation_action} = undef;
	$self->{trigger_base_url} = undef;

	if(defined($self->{xml}))
	{
		&parseXml($self);
	}

	return $self;
}

sub get_attributes()
{
	my $self    = shift;
	my $child;
	my %values;
	my @elm = $self->{xml}->elements_by_name("trigger_attribute"); 

	foreach $child (@elm)
	{
		my $kids  = new XML::Lite($child->get_content());

		my $name  = $kids->elements_by_name("trigger_attr_name"); 
		my $value = $kids->elements_by_name("trigger_attr_value");
		my $type  = $kids->elements_by_name("trigger_attr_type");

		if (defined($type))
		{
			$type = $type->get_content();
		}
		else
		{
			$type = "";
		}

		#It doesn't make sense to display these anyways since they will be raw XML.
		if (($type ne "CCM_SUBSCRIPTION") && ($type ne "CCM_E_SIGNATURE"))
		{
			if(defined($name) && defined($value))
			{
				$values{$name->get_content()} = ChangeSynergy::util::xmlDecode($value->get_content());
			}
		}
	}

	return %values;
}

sub get_requested_attributes()
{
	my $self    = shift;
	my $child;
	my %values;
	my @elm = $self->{xml}->elements_by_name("trigger_requested_attribute"); 

	foreach $child (@elm)
	{
		my $kids  = new XML::Lite($child->get_content());

		my $name  = $kids->elements_by_name("trigger_attr_name"); 
		my $value = $kids->elements_by_name("trigger_attr_value"); 

		if(defined($name) && defined($value))
		{
			$values{$name->get_content()} = ChangeSynergy::util::xmlDecode($value->get_content());
		}
	}

	return %values;
}

sub get_base_url()
{
	my $self = shift;
	return $self->{trigger_base_url};
}

sub get_database()
{
	my $self    = shift;
	return $self->{trigger_database};
}

sub get_database_uid()
{
	my $self    = shift;
	return $self->{trigger_database_uid};
}

sub get_dcm_delimiter()
{
	my $self    = shift;
	return $self->{trigger_dcm_delimiter};
}

sub get_from_email_addr()
{
	my $self = shift;
	
	return $self->{trigger_from_email_addr};
}

sub get_from_object()
{
	my $self    = shift;
	return $self->{trigger_from_object};
}

sub get_from_state()
{
	my $self    = shift;
	return $self->{trigger_from_state};
}

sub get_host()
{
	my $self = shift;

	return $self->{trigger_host};
}

sub get_object_id()
{
	my $self    = shift;
	return $self->{trigger_object_id};
}

sub get_object_type()
{
	my $self    = shift;
	return $self->{trigger_object_type};
}

sub get_port()
{
	my $self    = shift;

	return $self->{trigger_port};
}

sub get_protocol()
{
	my $self    = shift;

	return $self->{trigger_protocol};
}

sub get_relation_action()
{
	my $self = shift;
	return $self->{trigger_relation_action};
}

sub get_relation_name()
{
	my $self    = shift;
	return $self->{trigger_relation_name};
}

sub get_relation_type()
{
	my $self    = shift;
	return $self->{trigger_relation_type};
}

sub get_role()
{
	my $self    = shift;
	return $self->{trigger_role};
}

sub get_smtp_server()
{
	my $self = shift;
	
	return $self->{trigger_smtp_server};
}

sub get_to_object()
{
	my $self    = shift;
	return $self->{trigger_to_object};
}

sub get_to_state()
{
	my $self    = shift;
	return $self->{trigger_to_state};
}

sub get_token()
{
	my $self    = shift;
	return $self->{trigger_token};
}

sub get_admin_token()
{
	my $self    = shift;
	return $self->{trigger_admin_token};
}

sub get_user()
{
	my $self    = shift;
	return $self->{trigger_user};
}

sub get_admin_user()
{
	my $self    = shift;
	return $self->{trigger_admin_user};
}

sub get_subscriber_email_addresses()
{
	my $self = shift;
	return $self->{trigger_sub_emails};
}

sub set_base_url
{
	my $self    = shift;
	my $val     = shift;

	$self->{trigger_base_url} = $val;
}

sub set_database
{
	my $self    = shift;
	my $val     = shift;

	$self->{trigger_database} = $val;
}

sub set_database_uid
{
	my $self    = shift;
	my $val     = shift;

	$self->{trigger_database_uid} = $val;
}

sub set_dcm_delimiter
{
	my $self    = shift;
	my $val     = shift;

	if($val ne "#DCM_NOT_ENABLED#")
	{
		$self->{trigger_dcm_delimiter} = $val;
	}
}

sub set_from_email_addr
{
	my $self = shift;
	my $val = shift;

	$self->{trigger_from_email_addr} = $val;
}

sub set_from_object
{
	my $self    = shift;
	my $val     = shift;

	$self->{trigger_from_object} = $val;
}

sub set_from_state
{
	my $self    = shift;
	my $val     = shift;

	$self->{trigger_from_state} = $val;
}

sub set_host
{
	my $self    = shift;
	my $val     = shift;

	$self->{trigger_host} = $val;
}

sub set_object_id
{
	my $self    = shift;
	my $val     = shift;

	$self->{trigger_object_id} = $val;
}

sub set_object_type
{
	my $self    = shift;
	my $val     = shift;

	$self->{trigger_object_type} = $val;
}

sub set_port
{
	my $self    = shift;
	my $val     = shift;

	$self->{trigger_port} = $val;
}

sub set_protocol
{
	my $self    = shift;
	my $val     = shift;

	$self->{trigger_protocol} = $val;
}

sub set_relation_action
{
	my $self    = shift;
	my $val     = shift;

	$self->{trigger_relation_action} = $val;
}

sub set_relation_name
{
	my $self    = shift;
	my $val     = shift;

	$self->{trigger_relation_name} = $val;
}

sub set_relation_type
{
	my $self    = shift;
	my $val     = shift;

	$self->{trigger_relation_type} = $val;
}

sub set_role
{
	my $self    = shift;
	my $val     = shift;

	$self->{trigger_role} = $val;
}

sub set_smtp_server
{
	my $self = shift;
	my $val = shift;

	$self->{trigger_smtp_server} = $val;
}

sub set_to_object
{
	my $self    = shift;
	my $val     = shift;

	$self->{trigger_to_object} = $val;
}

sub set_to_state
{
	my $self    = shift;
	my $val     = shift;

	$self->{trigger_to_state} = $val;
}

sub set_token
{
	my $self    = shift;
	my $val     = shift;

	$self->{trigger_token} = $val;
}

sub set_admin_token
{
	my $self    = shift;
	my $val     = shift;

	$self->{trigger_admin_token} = $val;
}

sub set_user
{
	my $self    = shift;
	my $val     = shift;

	$self->{trigger_user} = $val;
}

sub set_admin_user
{
	my $self    = shift;
	my $val     = shift;

	$self->{trigger_admin_user} = $val;
}

sub set_subscriber_email_addresses
{
	my $self = shift;
	my $val  = shift;
	
	$self->{trigger_sub_emails} = $val;
}

#
# Private Methods
#
sub parseXml
{
	my $self = shift;

	my $element = $self->{xml}->elements_by_name("trigger_host"); 
	if(defined($element))
	{
		set_host($self, $element->get_content());
	}
	$element = undef;

	$element = $self->{xml}->elements_by_name("trigger_port"); 
	if(defined($element))
	{
		set_port($self, $element->get_content());
	}
	$element = undef;

	$element = $self->{xml}->elements_by_name("trigger_protocol"); 
	if(defined($element))
	{
		set_protocol($self, $element->get_content());
	}
	$element = undef;

	$element = $self->{xml}->elements_by_name("trigger_database"); 
	if(defined($element))
	{
		set_database($self, $element->get_content());
	}
	$element = undef;

	$element = $self->{xml}->elements_by_name("trigger_database_uid"); 
	if(defined($element))
	{
		set_database_uid($self, $element->get_content());
	}
	$element = undef;
	
	$element = $self->{xml}->elements_by_name("trigger_dcm_delimiter"); 
	if(defined($element))
	{
		set_dcm_delimiter($self, $element->get_content());
	}
	$element = undef;

	$element = $self->{xml}->elements_by_name("trigger_token"); 
	if(defined($element))
	{
		set_token($self, $element->get_content());
	}
	$element = undef;

	$element = $self->{xml}->elements_by_name("trigger_admin_token"); 
	if(defined($element))
	{
		set_admin_token($self, $element->get_content());
	}
	$element = undef;

	$element = $self->{xml}->elements_by_name("trigger_user"); 
	if(defined($element))
	{
		set_user($self, ChangeSynergy::util::xmlDecode($element->get_content()));
	}
	$element = undef;

	$element = $self->{xml}->elements_by_name("trigger_admin_user"); 
	if(defined($element))
	{
		set_admin_user($self, ChangeSynergy::util::xmlDecode($element->get_content()));
	}
	$element = undef;

	$element = $self->{xml}->elements_by_name("trigger_role"); 
	if(defined($element))
	{
		set_role($self, $element->get_content());
	}
	$element = undef;

	$element = $self->{xml}->elements_by_name("trigger_from_object"); 
	if(defined($element))
	{
		set_from_object($self, ChangeSynergy::util::xmlDecode($element->get_content()));
	}
	$element = undef;

	$element = $self->{xml}->elements_by_name("trigger_from_state"); 
	if(defined($element))
	{
		set_from_state($self, ChangeSynergy::util::xmlDecode($element->get_content()));
	}
	$element = undef;

	$element = $self->{xml}->elements_by_name("trigger_to_state"); 
	if(defined($element))
	{
		set_to_state($self, ChangeSynergy::util::xmlDecode($element->get_content()));
	}
	$element = undef;

	$element = $self->{xml}->elements_by_name("trigger_to_object"); 
	if(defined($element))
	{
		set_to_object($self, ChangeSynergy::util::xmlDecode($element->get_content()));
	}
	$element = undef;

	$element = $self->{xml}->elements_by_name("trigger_object_id"); 
	if(defined($element))
	{
		set_object_id($self, $element->get_content());
	}
	$element = undef;

	$element = $self->{xml}->elements_by_name("trigger_object_type"); 
	if(defined($element))
	{
		set_object_type($self, $element->get_content());
	}
	$element = undef;
	
	$element = $self->{xml}->elements_by_name("trigger_relation_action"); 
	if(defined($element))
	{
		set_relation_action($self, $element->get_content());
	}
	$element = undef;

	$element = $self->{xml}->elements_by_name("trigger_relation_name"); 
	if(defined($element))
	{
		set_relation_name($self, ChangeSynergy::util::xmlDecode($element->get_content()));
	}
	$element = undef;

	$element = $self->{xml}->elements_by_name("trigger_relation_type"); 

	if(defined($element))
	{
		set_relation_type($self, $element->get_content());
	}
	$element = undef;
	
	$element = $self->{xml}->elements_by_name("trigger_subscriber_email_list"); 

	if(defined($element))
	{
		set_subscriber_email_addresses($self, $element->get_content());
	}
	$element = undef;
	
	$element = $self->{xml}->elements_by_name("trigger_from_email_addr"); 

	if(defined($element))
	{
		set_from_email_addr($self, $element->get_content());
	}
	$element = undef;
	
	$element = $self->{xml}->elements_by_name("trigger_smtp_server"); 

	if(defined($element))
	{
		set_smtp_server($self, $element->get_content());
	}
	$element = undef;
	
	$element = $self->{xml}->elements_by_name("trigger_base_url");
	 
	if(defined($element))
	{
		set_base_url($self, $element->get_content());
	}
	$element = undef;
}

1;
__END__


=head1 Name

ChangeSynergy::TriggerParser

=head1 Description

ChangeSynergy::TriggerParser is an XML parser for IBM Rational Change's input trigger files.
When a trigger is fired, IBM Rational Change generates an XML file with useful information
about the server and object which caused the trigger to fire.  This class makes it
easy to retrieve the information from the XML file, such as the server's protocol, 
hostname and port, as well as a list of all of the attributes that changed.

=head1 Methods

The following methods are available:

=over 4

=cut

##############################################################################

=item B<new>

sub new(xmlFile)

Initialize a newly created ChangeSynergy::TriggerParser class so that it
represents the passed-in xml data in an accessible data structure.

my $trigger = new ChangeSynergy::TriggerParser( 'file.xml' );

 Parameters:
	xmlFile - The trigger xml file to be parsed or a scalar containing the xml data
		      which needs to be parsed.

=cut

##############################################################################

=item B<get_admin_token>

Get the admin token.

my $token = $trigger->get_admin_token()

 Returns: scalar
	the token of the admin user.
	or undef if no admin token was supplied in the trigger

=cut

##############################################################################

=item B<get_admin_user>

Get the admin user name.

my $user = $trigger->get_admin_user()

 Returns: scalar
	the username of the admin user 
	or undef if no admin username was supplied in the trigger.

=cut

##############################################################################

=item B<get_attributes>

Gather all of the attributes that were in the xml data and place them into a 
hash. The attributes will be the attrs that were modified when the trigger fired.

my %trigger_attributes = $trigger->get_attributes()

 Returns: hash
	all of the trigger attributes that were set or modified
	during this action, or undef if no trigger attributes were defined
	in the xml file.

=cut

##############################################################################

=item B<get_database>

Get the IBM Rational Synergy database to which the user was connected when the trigger fired.
This is useful when creating a new connection to the IBM Rational Change server.

my $database = $trigger->get_database()

 Returns: scalar
	the database the user was connected to when the trigger fired,
	or undef if no database was supplied.

=cut

##############################################################################

=item B<get_database_uid>

Get the IBM Rational Synergy database uid to which the user was connected when the trigger fired.
This is the IBM Rational Change unique ID of the database.

my $database = $trigger->get_database_uid()

 Returns: scalar
	the database uid to which the user was connected when the trigger fired,
	or undef if no database uid was supplied.

=cut

##############################################################################

=item B<get_dcm_delimiter>

Get the DCM delimiter for the database to which the user was connected when the
trigger fired.

my $dcm_delimiter = $trigger->get_dcm_delimiter()

 Returns: scalar
	the DCM delimiter for the database that the user was connected to when the
	trigger fired, or undef if no dcm delimiter was supplied.

=cut

##############################################################################

=item B<get_from_email_addr>

Get the e-mail address that is defined in the pt.cfg file to be used
when sending e-mails from triggers.

my $from_email = $trigger->get_from_email_addr();

 Returns: scalar
 	the e-mail address to be used for the from portion of e-mails
 	sent via PERL script or undef if no from object was supplied
 	in the trigger.

=cut

##############################################################################

=item B<get_from_object>

When performing a transition the from state will be the state the object was
in before being transitioned.

my $from_object = $trigger->get_from_object()

 Returns: scalar
	the object which the relationship was coming from or
	undef if no from object was supplied in the trigger.

=cut

##############################################################################

=item B<get_from_state>

When performing a transition the from state will be the state the object was
in before being transitioned.

my $from_state = $trigger->get_from_state()

 Returns: scalar
	the state from which the object was coming from or
	undef if no from state was supplied in the trigger.

=cut

##############################################################################

=item B<get_host>

Get the hostname of the IBM Rational Change installation to which the user was connected when 
the trigger fired. This is useful when creating a new connection to the IBM Rational Change 
server.

my $host = $trigger->get_host()

 Returns: scalar
	the hostname of the IBM Rational Change installation which
	fired the trigger or undef if no hostname was supplied.

=cut

##############################################################################

=item B<get_object_id>

Get the id number of the object which caused the trigger to fire.

 Object id is of one of the following types: 
	problem_number
	task_number
	cvid

my $object_id = $trigger->get_object_id()

 Returns: scalar
	the object id of the object which caused the trigger to fire
	or undef if no object id was supplied in the trigger.

=cut

##############################################################################

=item B<get_object_type>

Get the type of the object which caused the trigger to fire.

 Object type is of one of the following types:
	CCM_PROBLEM
	CCM_TASK
	CCM_OBJECT.

my $object_type = $trigger->get_object_type()

 Returns: scalar
	the object type that the trigger is acting upon 
	or undef if no object type was supplied in the trigger.

=cut


##############################################################################

=item B<get_port>

Get the port of the IBM Rational Change installation to which the user was connected when the
trigger fired. This is useful when creating a new connection to the CS
server.

my $port = $trigger->get_port()

 Returns: scalar
	the port of the IBM Rational Change installation which
	fired the trigger or undef if no port was supplied.

=cut

##############################################################################

=item B<get_protocol>

Get the protocol of the IBM Rational Change installation to which the user was connected when the
trigger fired. The protocol is of type http or https, depending upon how 
the server is set up. This is useful when creating a new connection to the CS
server.

my $protocol = $trigger->get_protocol()

 Returns: scalar
	the protocol type of the IBM Rational Change installation which
	fired the trigger or undef if no protocol was supplied.

=cut

##############################################################################

=item B<get_relation_action>

Get the action that the relation is acting upon.  This will either be CREATE_RELATION
or DELETE_RELATION.

my $relation_action = $trigger->get_relation_action()

 Returns: scalar
	the relation action that the trigger is acting upon
	or undef if no object type was supplied in the trigger.

=cut

##############################################################################

=item B<get_relation_name>

Get the name of the relation for which the trigger is acting upon.

my $relation_name = $trigger->get_relation_name()

 Returns: scalar
	the relation name that the trigger is acting upon
	or undef if no object type was supplied in the trigger.

=cut

##############################################################################

=item B<get_relation_type>

Get the relation type for which the trigger is acting upon.

 Relation types:

	CCM_PROBLEM_PROBLEM: A problem --> problem relationship.
	CCM_PROBLEM_TASK:    A problem --> task relationship.
	CCM_PROBLEM_OBJECT:  A problem --> object relationship.

	CCM_TASK_PROBLEM:    A task    --> problem relationship.
	CCM_TASK_TASK:       A task    --> task relationship.
	CCM_TASK_OBJECT:     A task    --> object relationship.

	CCM_OBJECT_PROBLEM:  A object  --> problem relationship.
	CCM_OBJECT_TASK:     A object  --> task relationship.
	CCM_OBJECT_OBJECT:   A object  --> object relationship.

my $relation_type = $trigger->get_relation_type()

 Returns: scalar
	the relation type that the trigger is acting upon
	or undef if no object type was supplied in the trigger.

=cut

##############################################################################

=item B<get_requested_attributes>

Gather all of the requested trigger attributes that were in the xml data and place them into a 
hash. The requested attributes will be the attributes that were specifically requested to be
sent to triggers from the lifecycle editor.  If the trigger is a pre transition trigger
then the requested attributes values will be the values before any modifications are made.  If the
trigger is a post trigger (post modify, post transition or post submit), the requested attributes 
values will be the values after modification.

my %trigger_attributes = $trigger->get_requested_attributes();

 Returns: hash
	all of the attributes that were requested to be sent to triggers via the lifecycle
	editor, or undef if no requested trigger attributes were defined in the xml file.

=cut

##############################################################################

=item B<get_role>

Get the role of the user which caused the trigger to fire.

my $role = $trigger->get_role()

 Returns: scalar
	the role of the user which caused the trigger to fire.
	or undef if no role was supplied in the trigger.

=cut

##############################################################################

=item B<get_smtp_server>

Get the SMTP server that is defined in the pt.cfg file to be used
when sending e-mails from triggers.

my $smtp_server = $trigger->get_smtp_server();

 Returns: scalar
 	the SMTP server to be used to send e-mails via PERL scripts
 	or undef if no from object was supplied in the trigger.

=cut

##############################################################################

=item B<get_subscriber_email_addresses>

If this trigger fired for a subscription trigger then get the list of subscribers
email address that subscribed to the modified CR.  This field will be undef for
all non-subscription triggers.

my $token = $trigger->get_subscriber_email_addresses()

 Returns: scalar
	the list of email address for the subscribers of this CR.
	or undef if no token was supplied in the trigger

=cut

##############################################################################

=item B<get_to_object>

When performing a relationship create, this is the object that the relation is
pointing to.

my $to_object = $trigger->get_to_object()

 Returns: scalar
	the object to which the relationt is going to or undef if 
	no to object was supplied in the trigger.

=cut

##############################################################################

=item B<get_to_state>

When performing a transition the to state will be the state the object
is going to end up in.

my $to_state = $trigger->get_to_state()

 Returns: scalar
	the state to which the object is going to or undef if 
	no to state was supplied in the trigger.

=cut

##############################################################################

=item B<get_token>

Get the token of the user which caused the trigger to fire.

my $token = $trigger->get_token()

 Returns: scalar
	the token of the user which caused the trigger to fire.
	or undef if no token was supplied in the trigger

=cut

##############################################################################

=item B<get_user>

Get the user name of the user which caused the trigger to fire.

my $user = $trigger->get_user()

 Returns: scalar
	the username of the user which caused the trigger to fire 
	or undef if no username was supplied in the trigger.

=cut

##############################################################################

=item B<set_admin_token>

Set the "admin token" property for the class instance.

$trigger->set_admin_token($value);

 Parameters:
	value - the new value for the admin token.	

=cut

##############################################################################

=item B<set_admin_user>

Set the "admin username" property for the class instance.

$trigger->set_admin_user($value);

 Parameters:
	value - the new value for the admin username.

=cut

##############################################################################


=item B<set_database>

Set the "database" property for this class instance.

$trigger->set_database($value);

 Parameters: 
	value - the new value for the database.

=cut

##############################################################################

=item B<set_database_uid>

Set the "database uid" property for this class instance.

$trigger->set_database_uid($value);

 Parameters: 
	value - the new value for the database uid.

=cut

##############################################################################

=item B<set_dcm_delimiter>

Set the "DCM delimiter" property for this class instance.

$trigger->set_dcm_delimiter($value);

 Parameters: 
	value - the new value for the DCM delimiter.

=cut

##############################################################################

=item B<set_from_email_addr>

Set the "from email addr" property for the class instance. This 
will be set when the trigger XML file is parsed but can be over
written if needed.

$trigger->set_from_email_addr($value);

 Parameters:
	value - the new value for the from object.

=cut

##############################################################################

=item B<set_from_object>

Set the "from_object" property for the class instance.

$trigger->set_from_object($value);

 Parameters:
	value - the new value for the from object.

=cut

##############################################################################

=item B<set_from_state>

Set the "from_state" property for the class instance.

$trigger->set_from_state($value);

 Parameters:
	value - the new value for the from state.

=cut

##############################################################################

=item B<set_host>

Set the "hostname" property for the class instance.

$trigger->set_host($value);

 Parameters:
	value - the new value for the host.

=cut

##############################################################################

=item B<set_object_id>

Set the "object_id" property for the class instance.

$trigger->set_object_id($value);

 Parameters:
	value - the new value for the object ID.

=cut

##############################################################################

=item B<set_object_type>

Set the "object_type" property for the class instance.

$trigger->set_object_type($value);

 Parameters:
	value - the new value for the object type.

=cut

##############################################################################

=item B<set_port>

Set the "port" property for the class instance.

$trigger->set_port($value);

 Parameters:
	value - the new value for the port.

=cut

##############################################################################

=item B<set_protocol>

Set the "protocol" property for the class instance.

$trigger->set_protocol($value);

 Parameters:
	value - the new value for the protocol.

=cut

##############################################################################

=item B<set_relation_action>

Set the "relation_action" property for the class instance.

$trigger->set_relation_action($value);

 Parameters:
	value - the new value for the relation action.

=cut

##############################################################################

=item B<set_relation_name>

Set the "relation_name" property for the class instance.

$trigger->set_relation_name($value);

 Parameters:
	value - the new value for the relation name.

=cut

##############################################################################

=item B<set_relation_type>

Set the "relation_type" property for the class instance.
   
$trigger->set_relation_type($value);

 Parameters:
	value - the new value for the relation type.

=cut

##############################################################################

=item B<set_role>

Set the "role" property for the class instance.

$trigger->set_role($value);

 Parameters:
	value - the new value for the users role.

=cut

##############################################################################

=item B<set_smtp_server>

Set the "SMTP server" property for the class instance. This 
will be set when the trigger XML file is parsed but can be over
written if needed.

$trigger->set_smtp_server($value);

 Parameters:
	value - the new value for the from object.

=cut

##############################################################################

=item B<set_subscriber_email_addresses>

Set the "subscriber email addresses" property for the class instance.

$trigger->set_subscriber_email_addresses($value);

 Parameters:
	value - the new value for the subscriber email addresses.	

=cut

##############################################################################

=item B<set_to_object>

Set the "to_object" property for the class instance.

$trigger->set_to_object($value);

 Parameters:
	value - the new value for the to object.

=cut

##############################################################################

=item B<set_to_state>

Set the "to_state" property for the class instance.

$trigger->set_to_state($value);

 Parameters:
	value - the new value for the to state.

=cut

##############################################################################

=item B<set_token>

Set the "token" property for the class instance.

$trigger->set_token($value);

 Parameters:
	value - the new value for the token.	

=cut

##############################################################################

=item B<set_user>

Set the "username" property for the class instance.

$trigger->set_user($value);

 Parameters:
	value - the new value for the username.

=cut

##############################################################################
