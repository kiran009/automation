###########################################################
## apiUser Class
###########################################################

package ChangeSynergy::apiUser;

sub new
{
	shift; 

	# Initialize data as an empty hash
	my $self = {};

	$self->{strUserName}		= undef;
	$self->{strUserPassword}	= undef;
	$self->{strUserRole}		= undef;
	$self->{strUserToken}		= undef;
	$self->{strUserDatabase}	= undef;

	if(@_ == 4)
	{
		$self->{strUserName}		= ChangeSynergy::util::xmlEncode(shift);
		$self->{strUserPassword}	= shift;
		$self->{strUserRole}		= ChangeSynergy::util::xmlEncode(shift);
		$self->{strUserDatabase}	= ChangeSynergy::util::xmlEncode(shift);

		if(!defined($self->{strUserName}))
		{
			die "User name cannot be undef";
		}

		if(!defined($self->{strUserPassword}))
		{
			die "User Password cannot be undef";
		}

		if(!defined($self->{strUserRole}))
		{
			die "User role list cannot be undef";
		}

		if(!defined($self->{strUserDatabase}))
		{
			die "User database cannot be undef";
		}
	}
	elsif(@_ == 5)
	{
		$self->{strUserName}		= ChangeSynergy::util::xmlEncode(shift);
		$self->{strUserPassword}	= shift;
		$self->{strUserRole}		= ChangeSynergy::util::xmlEncode(shift);
		$self->{strUserToken}		= ChangeSynergy::util::xmlEncode(shift);
		$self->{strUserDatabase}	= ChangeSynergy::util::xmlEncode(shift);

		if(!defined($self->{strUserName}))
		{
			die "User name cannot be undef";
		}

		if(!defined($self->{strUserPassword}))
		{
			die "User Password cannot be undef";
		}

		if(!defined($self->{strUserRole}))
		{
			die "User role list cannot be undef";
		}

		if(!defined($self->{strUserToken}))
		{
			die "User token cannot be undef";
		}

		if(!defined($self->{strUserDatabase}))
		{
			die "User database cannot be undef";
		}
	}

	bless $self;

	return $self;
}

sub getUserDatabase
{
	my $self = shift;
	return $self->{strUserDatabase};
}

sub getUserName
{
	my $self = shift;
	return $self->{strUserName};
}

sub getUserPassword
{
	my $self = shift;
	return $self->{strUserPassword};
}

sub getUserPasswordEncoded
{
	my $self = shift;
	my $seed = (int(rand 1000) + 1);	
	my $theEncodedPassword = $seed . ":";
	my $length = length($self->{strUserPassword});	
	
	for (my $i = 0; $i < $length; $i++)
	{
		my $aChar = ord (substr($self->{strUserPassword}, $i, 1));
		$theEncodedPassword .= $aChar * $seed;

		if ($i < ($length - 1))
		{
			$theEncodedPassword .= ",";
		}
	}
	
	return $theEncodedPassword;
}

sub getUserRole
{
	my $self = shift;
	return $self->{strUserRole};
}

sub getUserRoleList
{
	my $self = shift;
	return $self->{strUserRole};
}

sub getUserToken
{
	my $self = shift;
	return $self->{strUserToken};
}

sub setUserToken
{
	my $self	= shift;
	my $value	= shift;

	$self->{strUserToken} = $value;
}

1;
__END__

=head1 Name

ChangeSynergy::apiUser

=head1 Description

A instance of ChangeSynergy::apiUser is created by logging into IBM Rational Change.
A instance of this class is needed to call any of the api functions.

The token property is automatically set when logging in.

The object is also used for creating new users.

=head1 Methods

The following methods are available:

=over 4

=cut

##############################################################################

=item B<new>

 Default constructor used when creating new users.
 sub new(username, password, role, database)

 Default constructor used by the Login() function.
 sub new(username, password, role, token, database)

Initializes a newly created ChangeSynergy::apiUser class so that it 
represents all of the needed information about a user.

 my $user = new ChangeSynergy::apiUser(username, password, role, database);
 my $user = new ChangeSynergy::apiUser(username, password, role, token, database);

 Parameters:
	username - the name of the user
	password - the password of the user
	role	 - the role of the user or a list of roles. (developer|ccm_admin|pt_admin)
	token	 - the token for the user
	database - the database the user is logged into

 Throws:
	die - user name cannot be undefined
	die - password cannot be undefined
	die - user role cannot be undefined
	die - database cannot be undefined
	die - token cannot be undefined

=cut

##############################################################################

=item B<getUserDatabase>

Get the user IBM Rational Synergy database path property.

my $database= $user->getUserDatabase()

 Returns: scalar
	the IBM Rational Synergy database specified in the creation of this apiUser object.

=cut

##############################################################################

=item B<getUserName>

Get the users name property.

my $username = $user->getUserName()

 Returns: scalar
	the username specified in the creation of this apiUser object.

=cut

##############################################################################

=item B<getUserPassword>

Get the users password property

my $password = $user->getUserPassword()

 Returns: scalar
	the password specified in the creation of this apiUser object.

=cut

##############################################################################

=item B<getUserPasswordEncoded>

Get the users password property in an encoded format.

my $password = $user->getUserPasswordEncoded()

 Returns: scalar
	the encoded password specified in the creation of this apiUser object.

=cut

##############################################################################


=item B<getUserRole>

Get the users role property.  Will return the role used when the object was 
created in PERL. Note, this method will not get any role information from
the database.

my $user = $csapi->Login("u00001", "u00001", "User", "\\\\your_hostname\\ccmdb\\cm_database");
my $role = $user->getUserRole();

The role in this case will be the "User" role.

 Returns: scalar
	the role specified in the creation of this apiUser object.

=cut

##############################################################################

=item B<getUserRoleList>

Get the users rolelist property. The delimiter is the '|' character.
This method will return the role or roles used when the object was created in PERL.
Note, this method will not get any role information from the database.

Ex 1:
my $user = $csapi->Login("u00001", "u00001", "User", "\\\\your_hostname\\ccmdb\\cm_database");
my $rolelist = $user->getUserRoleList();

The rolelist will contain one role, the role the user logged in with. In this case the 
"User" role.

Ex 2:
my $aNewUser = new ChangeSynergy::apiUser("jsmith", "4.jsmith", "developer|ccm_admin|pt_admin",
                                          "\\\\your_hostname\\ccmdb\\cm_database");
my $rolelist = $user->getUserRoleList();

The role list will contain the three roles defined in the creation of the object: developer, 
ccm_admin and pt_admin.

 Returns: scalar
	the rolelist specified in the creation of this apiUser object.

=cut

##############################################################################

=item B<getUserToken>

Get the users token property.

my $token = $user->getUserToken()

 Returns: scalar
	the token specified in the creation of this apiUser object, or the token
	which was set after calling one of the Login methods.

=cut

##############################################################################

=item B<setUserToken>

Sets the "token" property for the class instance.

$user->setUserToken($token)

 Parameters:
	token - the token for the user specified in this apiUser object.

=cut

##############################################################################
