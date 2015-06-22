###########################################################
## FolderSecurityRule Class
###########################################################

package ChangeSynergy::FolderSecurityRule;

use strict;
use warnings;
use ChangeSynergy::util;

sub new
{
	shift; #take off the FolderSecurityRule which is passed in, this is the class name.

	# Initialize data as an empty hash
	my $self = {};
	
	# Initialize data for this object
	$self->{name} = undef;
	$self->{readMembers} = [];
	$self->{readWriteMembers} = [];
	
	#XML Tags	
	$self->{CSAPI_FOLDER_NAME} = "csapi_folder_name";
	$self->{CSAPI_FOLDER_READERS} = "csapi_folder_readers";
	$self->{CSAPI_FOLDER_WRITERS} = "csapi_folder_writers";
	
	# If a parameter was passed in then set it as the configData
	if(@_ > 0)
	{
		$self->{xmlData} = shift;
	}
	else
	{
		$self->{xmlData} = undef;
		
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
		die "Invalid xml data: FolderSecurityRule: \n" .$self->{xmlData} . "\n$@";
	}

	return $self;
}

sub getFolderName
{
	my $self = shift;
	return $self->{name};
}

sub setFolderName
{
	my $self = shift;
	my $value = shift;
	
	$self->{name} = $value;
}

sub getReadMembers
{
	my $self = shift;
	my @readMembers = @{$self->{readMembers}};
	return @readMembers;
}

sub addReadMember
{
	my $self = shift;
	my $newMember = shift;
	
	my @readMembers = @{$self->{readMembers}};
	
	foreach my $member (@readMembers)
	{
		if ("/L$member" eq "/L$newMember")
		{
			return;
		}
	}
	
	push @{$self->{readMembers}}, $newMember;
}

sub deleteReadMember
{
	my $self = shift;
	my $deleteMember = shift;
	
	my @readMembers = @{$self->{readMembers}};
	my $index = 0;
	
	foreach my $member (@readMembers)
	{
		if ("/L$member" eq "/L$deleteMember")
		{
			splice(@{$self->{readMembers}}, $index, $index);
			return;
		}
		
		$index++;
	}
}

sub setReadMembers
{
	my ($self, $refValue) = @_;
	#get the real array back from the reference.
	
	my @value = @$refValue;
	@{$self->{readMembers}} = @value;
}

sub getWriteMembers
{
	my $self = shift;
	my @readWriteMembers = @{$self->{readWriteMembers}};
	return @readWriteMembers;
}

sub addWriteMember
{
	my $self = shift;
	my $newMember = shift;
	
	my @readWriteMembers = @{$self->{readWriteMembers}};
	
	foreach my $member (@readWriteMembers)
	{
		if ("/L$member" eq "/L$newMember")
		{
			return;
		}
	}
	
	push @{$self->{readWriteMembers}}, $newMember;
}

sub deleteWriteMember
{
	my $self = shift;
	my $deleteMember = shift;
	
	my @readWriteMembers = @{$self->{readWriteMembers}};
	my $index = 0;
	
	foreach my $member (@readWriteMembers)
	{
		if ("/L$member" eq "/L$deleteMember")
		{
			splice(@{$self->{readWriteMembers}}, $index, $index + 1);
			return;
		}
		
		$index++;
	}
}

sub setWriteMembers
{
	my ($self, $refValue) = @_;
	#get the real array back from the reference.
	
	my @value = @$refValue;
	@{$self->{readWriteMembers}} = @value;
}

sub parseXml
{
	my $self = shift;

	if(!defined($self->{xmlData}))
	{
		die "Cannot parse folder security rule data, undef";
	}

	if(length($self->{xmlData}) == 0)
	{
		die "Cannot parse folder security rule data, 0 length";
	}
	
	my $xmlData = $self->{xmlData};
	
	$self->{name} = ChangeSynergy::util::extractXmlValue($xmlData, $self->{CSAPI_FOLDER_NAME}, 1);
	
	my $readMembersList = ChangeSynergy::util::extractXmlValue($xmlData, $self->{CSAPI_FOLDER_READERS}, 1);
	my @readMembers = split(",", $readMembersList);
	
	foreach my $member (@readMembers)
	{
		push @{$self->{readMembers}}, &trim($self, $member);
	}
	
	my $readWriteMembersList = ChangeSynergy::util::extractXmlValue($xmlData, $self->{CSAPI_FOLDER_WRITERS}, 1);
	my @readWriteMembers = split(",", $readWriteMembersList);
	
	foreach my $member (@readWriteMembers)
	{
		push @{$self->{readWriteMembers}}, &trim($self, $member);
	}
}

sub toXml
{
	my $self = shift;

	my @readMembers = @{$self->{readMembers}};
	my @readWriteMembers = @{$self->{readWriteMembers}};
	
	my $xmlData = "<csapi_folder_name>" . ChangeSynergy::util::xmlEncode($self->{name}) . "</csapi_folder_name>";
	$xmlData .= "<csapi_folder_readers>" . ChangeSynergy::util::xmlEncode(join(', ', @readMembers)) . "</csapi_folder_readers>";
	$xmlData .= "<csapi_folder_writers>" . ChangeSynergy::util::xmlEncode(join(', ', @readWriteMembers)) . "</csapi_folder_writers>";
	
	return $xmlData;
}


sub trim
{
	my $self = shift;
	my $string = shift;
	$string =~ s/^\s+//;
	$string =~ s/\s+$//;
	
	return $string;
}

1;

__END__

=head1 Name

ChangeSynergy::FolderSecurityRule

=head1 Description

The ChangeSynergy::FolderSecurityRule class represents a folder rule. A folder rule consists of the name of the folder, a list of
users that have read access and a list of users that have write access. Users that have write access automatically have read
access. The security for the System and Shared folders for Queries, Report Formats and Reports for both change requests and tasks can
be modified using this class.

=head1 Method Summary

=begin html

<table border="1" cellpadding="2" cellspacing="0" width="100%">
	
	<tr>
		<td width="10%">
			void
		</td>
		<td>
			<code><a href="#addReadMember">addReadMember</a>(scalar readMember)</code><br />
			Adds a single user or group to the list of users that have read access to the folder.
		</td>
	</tr>
	<tr>
		<td width="10%">
			void
		</td>
		<td>
			<code><a href="#addWriteMember">addWriteMember</a>(scalar writeMember)</code><br />
			Adds a single user or group to the list of users that have write access to the folder.
		</td>
	</tr>
	<tr>
		<td width="10%">
			void
		</td>
		<td>
			<code><a href="#deleteReadMember">deleteReadMember</a>(scalar readMember)</code><br />
			Deletes a single user or group from the list of users and groups that have read access to the folder.
		</td>
	</tr>
	<tr>
		<td width="10%">
			void
		</td>
		<td>
			<code><a href="#deleteWriteMember">deleteWriteMember</a>(scalar writeMember)</code><br />
			Deletes a single user or group from the list of users and groups that have write access to the folder.
		</td>
	</tr>
	<tr>
		<td width="10%">
			scalar
		</td>
		<td>
			<code><a href="#getFolderName">getFolderName</a>()</code><br />
			Gets the name of the folder for this folder security rule. If the folder name is empty that means the folder security
			rule is for the "All" folder.
		</td>
	</tr>
	<tr>
		<td width="10%">
			array
		</td>
		<td>
			<code><a href="#getReadMembers">getReadMembers</a>()</code><br />
			Gets an array of the users and groups that have read access to the folder.
		</td>
	</tr>
	<tr>
		<td width="10%">
			array
		</td>
		<td>
			<code><a href="#getWriteMembers">getWriteMembers</a>()</code><br />
			Gets an array of the users and groups that have write access to the folder.
		</td>
	</tr>
	
	
	<tr>
		<td width="10%">
			void
		</td>
		<td>
			<code><a href="#setFolderName">setFolderName</a>(scalar folderName)</code><br />
			Sets the name of the folder for this folder security rule. Set the folder name to the empty string ("") if you want to
			set the folder security for the "All" folder.
		</td>
	</tr>
	<tr>
		<td width="10%">
			void
		</td>
		<td>
			<code><a href="#setReadMembers">setReadMembers</a>(array readMembers)</code><br />
			Sets the array of users and groups that have read access to the folder.
		</td>
	</tr>
	<tr>
		<td width="10%">
			void
		</td>
		<td>
			<code><a href="#setWriteMembers">setWriteMembers</a>(array writeMembers)</code><br />
			Sets the array of users and groups that have write access to the folder.
		</td>
	</tr>

</table>

=end html

=head1 Methods

=over 4

=cut

##############################################################################

=begin html

	<hr>
	<a href="addReadMember"></a>

=end html

=item B<addReadMember>

Adds a single user or group to the list of users and groups that have read access to the folder. If the user or group already exists in the list the
call is a no-op. 

 Parameters:
	scalar: The name of user or group.

 Example:
	
	my $folderRule = new ChangeSynergy::FolderSecurityRule();
	$folderRule->addReadMember("user1");

=cut

##############################################################################

=begin html

	<hr>
	<a href="addWriteMember"></a>

=end html

=item B<addWriteMember>

Adds a single user or group to the list of users and groups that have write access to the folder. If the user or group already exists in the list the
call is a no-op. 

 Parameters:
	scalar: The name of user or group.

 Example:
	
	my $folderRule = new ChangeSynergy::FolderSecurityRule();
	$folderRule->addWriteMember("user1");

=cut

##############################################################################

=begin html

	<hr>
	<a href="deleteReadMember"></a>

=end html

=item B<deleteReadMember>

Deletes a single user or group from the list of users and groups that have read access to the folder. If the user or group does not exist in the list the
call is a no-op. 

 Parameters:
	scalar: The name of user or group.

 Example:
	
	my $folderRule = new ChangeSynergy::FolderSecurityRule();
	$folderRule->deleteReadMember("user1");

=cut

##############################################################################

=begin html

	<hr>
	<a href="deleteWriteMember"></a>

=end html

=item B<deleteWriteMember>

Deletes a single user or group from the list of users that have write access to the folder. If the user or group does not exist in the list the
call is a no-op. 

 Parameters:
	scalar: The name of user or group.

 Example:
	
	my $folderRule = new ChangeSynergy::FolderSecurityRule();
	$folderRule->deleteWriteMember("user1");

=cut

##############################################################################

=begin html

	<hr>
	<a href="getFolderName"></a>

=end html

=item B<getFolderName>

Gets the name of the folder for this folder security rule. If the rule name is empty that means the folder security rule is for the "All" folder. 

 Returns: scalar
	The name of the folder.

=cut

##############################################################################

=begin html

	<hr>
	<a href="getReadMembers"></a>

=end html

=item B<getReadMembers>

Gets the array of users that have read access to the folder. That is the users who can view and run the queries, reports, etc in a given
folder.

 Returns: array
	The array of read members.

=cut

##############################################################################

=begin html

	<hr>
	<a href="getWriteMembers"></a>

=end html

=item B<getWriteMembers>

Gets the array of users that have write access to the folder. That is the users who can view, run and edit the queries, reports, etc in a given
folder.

 Returns: array
	The array of write members.

=cut

##############################################################################

=begin html

	<hr>
	<a href="setFolderName"></a>

=end html

=item B<setFolderName>

Sets the name of the folder for this folder security rule. Set the folder name to the empty string ("") if you want to set the folder 
security for the "All" folder.

 Parameters:
	scalar: The name of the folder.

 Example:
	
	my $folderRule = new ChangeSynergy::FolderSecurityRule();
	$folderRule->setFolderName("My folder");

=cut

##############################################################################

=begin html

	<hr>
	<a href="setReadMembers"></a>

=end html

=item B<setReadMembers>

Sets the array of users that have read access to the folder. That is the users who can view and run the queries, reports, etc in a given
folder.

 Parameters:
	array: The list of users with read access. 

 Example:
	
	my $folderRule = new ChangeSynergy::FolderSecurityRule();
	my @readers = ("Jane", "John", "Doe");
	$folderRule->setReadMembers(\@readers);

=cut

##############################################################################

=begin html

	<hr>
	<a href="setWriteMembers"></a>

=end html

=item B<setWriteMembers>

Sets the array of users that have write access to the folder. That is the users who can view, run and edit the queries, reports, etc in a given
folder.

 Parameters:
	array: The list of users with write access. 

 Example:
	
	my $folderRule = new ChangeSynergy::FolderSecurityRule();
	my @readers = ("Jane", "John", "Doe");
	$folderRule->setWriteMembers(\@readers);

=cut
