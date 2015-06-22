#!/usr/bin/perl

package ChangeSynergy::standardPlugin;

my $message='';

sub initPlugin
{
	print "Initializing the standardPlugin ...\n";
	
	return 1;
}

sub Methods
{
	my @methods = ('expandUsers',);
	
	return @methods;
}

#
# This is a quick function to take a space delimited list of users 
# and return a formatted email address list for them.
# 
sub expandUsers
{
	my $userlist = shift;
	# drop leading spaces
	$userlist =~ s/^ +//;
	my @users = split(/ +/, $userlist);
	my $addressList = '';
	print $addressList;

	for my $user (@users)
	{
		my $address = &main::getEmailAddress($user);
		$addressList = $addressList . $address . ",";
	}
	
	# Strip trailing comma
	$addressList =~ s/\,$//;

	return $addressList;
}

1;

