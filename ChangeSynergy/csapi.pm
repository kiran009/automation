###########################################################
## csapi Class
###########################################################

package ChangeSynergy::csapi;

$VERSION = "1.0";

use strict;
use warnings;
use ChangeSynergy::apiObjectData;
use ChangeSynergy::apiObjectVector;
use ChangeSynergy::apiQueryData;
use ChangeSynergy::apiListObject;
use ChangeSynergy::apiUser;
use ChangeSynergy::apiData;
use ChangeSynergy::util;
use ChangeSynergy::Globals;
use ChangeSynergy::ReportEntryFactory;
use ChangeSynergy::FolderSecurityRule;
use LWP::UserAgent;
use XML::Lite;

sub setConnectionUrl
{
	my $self = shift;
	$self->{url_to_connect} = shift;
}

sub getConnectionUrl
{
	my $self = shift;
	return $self->{url_to_connect};
}

sub getReportConfigType
{
	my $self = shift;
	return $self->{reportConfigType};
}

sub getQueryConfigType
{
	my $self = shift;
	return $self->{queryConfigType};
}

sub new
{
	# Initialize data as an empty hash
	my $self = {};

	$self->{globals} = new ChangeSynergy::Globals();
	
	$self->{url_to_connect} = undef;
	$self->{queryConfigType} = undef;
	$self->{reportConfigType} = undef;
	
	bless $self;

	return $self;
}

###########################################################
## User Preference Methods
###########################################################
sub GetUserPreference
{
	my $self		= shift;
	my $aUser		= shift;
	my $userName    = shift;
	my $prefName    = shift;
	
	if(!defined($aUser))
	{
		die "User information object is undef";
	}

	return(ChangeSynergy::util::getUserPreference($aUser, "getUserPreference", $userName, $prefName, $self->getConnectionUrl()));
}

sub DumpAUsersPreferences
{
	my $self		= shift;
	my $aUser		= shift;
	my $username	= shift;
	
	if(!defined($aUser))
	{
		die "User information object is undef";
	}
	
	return(ChangeSynergy::util::modifyUserPreferences($aUser,$username,"",$self->{globals}->{DUMPPROFILE},"","","","", $self->getConnectionUrl()));
}

sub AddAPreferenceForAllUsers
{
	my $self		= shift;
	my $aUser		= shift;
	my $keyname		= shift;
	my $keyvalue	= shift;
	my $allDBs      = shift;
	
	if(!defined($aUser))
	{
		die "User information object is undef";
	}
	
	return(ChangeSynergy::util::modifyUserPreferences($aUser,"",$allDBs,$self->{globals}->{ADD},$keyname,$keyvalue,"","", $self->getConnectionUrl()));
}

sub AddAPreferenceForAUser
{
	my $self		= shift;
	my $aUser		= shift;
	my $username    = shift;
	my $keyname		= shift;
	my $keyvalue	= shift;
	my $allDBs      = shift;
	
	if(!defined($aUser))
	{
		die "User information object is undef";
	}
	
	return(ChangeSynergy::util::modifyUserPreferences($aUser,$username,$allDBs,$self->{globals}->{ADD},$keyname,$keyvalue,"","", $self->getConnectionUrl()));
}

sub DeleteAllUserPreferences
{
	my $self		= shift;
	my $aUser		= shift;
	
	if(!defined($aUser))
	{
		die "User information object is undef";
	}
	
	return(ChangeSynergy::util::modifyUserPreferences($aUser,"","",$self->{globals}->{DELETE},"","","","", $self->getConnectionUrl()));
}

sub DeleteAUsersPreferences
{
	my $self		= shift;
	my $aUser		= shift;
	my $username    = shift;
	
	if(!defined($aUser))
	{
		die "User information object is undef";
	}
	
	return(ChangeSynergy::util::modifyUserPreferences($aUser,$username,"",$self->{globals}->{DELETE},"","","","", $self->getConnectionUrl()));
}

sub DeleteAPreferenceForAllUsers
{
	my $self		= shift;
	my $aUser		= shift;
	my $keyname		= shift;
	my $allDBs      = shift;
	
	if(!defined($aUser))
	{
		die "User information object is undef";
	}
	
	return(ChangeSynergy::util::modifyUserPreferences($aUser,"",$allDBs,$self->{globals}->{DELETE},$keyname,"","","", $self->getConnectionUrl()));	
}

sub DeleteAPreferenceForAUser
{
	my $self		= shift;
	my $aUser		= shift;
	my $username    = shift;
	my $keyname		= shift;
	my $allDBs      = shift;
	
	if(!defined($aUser))
	{
		die "User information object is undef";
	}
	
	return(ChangeSynergy::util::modifyUserPreferences($aUser,$username,$allDBs,$self->{globals}->{DELETE},$keyname,"","","", $self->getConnectionUrl()));	
}

sub PreferenceNameSubstitutionForAUser
{
	my $self		    = shift;
	my $aUser		    = shift;
	my $username        = shift;
	my $searchValue	    = shift;
	my $replacmentValue = shift;
	
	if(!defined($aUser))
	{
		die "User information object is undef";
	}
	
	return(ChangeSynergy::util::modifyUserPreferences($aUser,$username,"",$self->{globals}->{EDIT},"substitute",$searchValue,$self->{globals}->{NAMESUBSTITUTION},$replacmentValue, $self->getConnectionUrl()));	
}

sub PreferenceNameSubstitutionForAllUsers
{
	my $self		    = shift;
	my $aUser		    = shift;
	my $searchValue	    = shift;
	my $replacmentValue = shift;
	
	if(!defined($aUser))
	{
		die "User information object is undef";
	}
	
	return(ChangeSynergy::util::modifyUserPreferences($aUser,"","",$self->{globals}->{EDIT},"substitute",$searchValue, $self->{globals}->{NAMESUBSTITUTION},$replacmentValue, $self->getConnectionUrl()));	
}

sub ChangePreferenceNameForAUser
{
	my $self		= shift;
	my $aUser		= shift;
	my $username    = shift;
	my $keyname		= shift;
	my $keyvalue    = shift;
	my $allDBs      = shift;
	
	if(!defined($aUser))
	{
		die "User information object is undef";
	}
	
	return(ChangeSynergy::util::modifyUserPreferences($aUser,$username,$allDBs,$self->{globals}->{EDIT},$keyname,$keyvalue,$self->{globals}->{NAMECHANGE},"", $self->getConnectionUrl()));	
}

sub ChangePreferenceNameForAllUsers
{
	my $self		= shift;
	my $aUser		= shift;
	my $keyname		= shift;
	my $keyvalue    = shift;
	my $allDBs      = shift;
	
	if(!defined($aUser))
	{
		die "User information object is undef";
	}
	
	return(ChangeSynergy::util::modifyUserPreferences($aUser,"",$allDBs,$self->{globals}->{EDIT},$keyname,$keyvalue,$self->{globals}->{NAMECHANGE},"", , $self->getConnectionUrl()));	
}

sub PreferenceSubstitutionForAUser
{
	my $self		= shift;
	my $aUser		= shift;
	my $username    = shift;
	my $keyname		= shift;
	my $keyvalue    = shift;
	my $subValue	= shift;
	my $allDBs      = shift;
	
	if(!defined($aUser))
	{
		die "User information object is undef";
	}
	
	return(ChangeSynergy::util::modifyUserPreferences($aUser,$username,$allDBs,$self->{globals}->{EDIT},$keyname,$keyvalue,$self->{globals}->{SUBSTITUTION},$subValue, $self->getConnectionUrl()));	
}

sub PreferenceSubstitutionForAllUsers
{
	my $self		= shift;
	my $aUser		= shift;
	my $keyname		= shift;
	my $keyvalue    = shift;
	my $subValue	= shift;
	my $allDBs      = shift;
	
	if(!defined($aUser))
	{
		die "User information object is undef";
	}
	
	return(ChangeSynergy::util::modifyUserPreferences($aUser,"",$allDBs,$self->{globals}->{EDIT},$keyname,$keyvalue,$self->{globals}->{SUBSTITUTION},$subValue, $self->getConnectionUrl()));	
}

sub RefreshUsers
{
	my $self      = shift;
	my $aUser     = shift;

	if(!defined($aUser))
	{
		die "User information object is undef";
	}

	return ChangeSynergy::util::RefreshUsers($aUser, $self->getConnectionUrl());
}

sub CreateObjectAttributes
{
	my $self      = shift;
	my $aUser     = shift;
	my $cvidList  = shift;
	my $attrData  = shift;

	if(!defined($aUser))
	{
		die "User information object is undef";
	}
	return(ChangeSynergy::util::ModifyObjectsAction($aUser, $cvidList, $attrData, $self->{globals}->{CSAPI_CV_ATTR_CREATE}), $self->getConnectionUrl());
}

sub ModifyObjectAttributes
{
	my $self      = shift;
	my $aUser     = shift;
	my $cvidList  = shift;
	my $attrData  = shift;

	if(!defined($aUser))
	{
		die "User information object is undef";
	}

	return(ChangeSynergy::util::ModifyObjectsAction($aUser, $cvidList, $attrData, $self->{globals}->{CSAPI_CV_ATTR_MODIFY}));
}

sub DeleteObjectAttributes
{
	my $self      = shift;
	my $aUser     = shift;
	my $cvidList  = shift;
	my $attrData  = shift;

	if(!defined($aUser))
	{
		die "User information object is undef";
	}

	return(ChangeSynergy::util::ModifyObjectsAction($aUser, $cvidList, $attrData, $self->{globals}->{CSAPI_CV_ATTR_DELETE}));
}

sub GetObjectData
{
	my $self          = shift;
	my $aUser         = shift;
	my $cvid          = shift;
	my $attributeList = shift;
	my $xmlData       = "";

	if(!defined($aUser))
	{
		die "User information object is undef";
	}

	$xmlData .= "<csapi_action_flag>PreObjectModify</csapi_action_flag>";

	$xmlData .= "<csapi_token>"		. $aUser->getUserToken()	. "</csapi_token>";
	$xmlData .= "<csapi_role>"		. $aUser->getUserRole()		. "</csapi_role>";
	$xmlData .= "<csapi_database>"	. $aUser->getUserDatabase() . "</csapi_database>";
	$xmlData .= "<csapi_user>"		. $aUser->getUserName()		. "</csapi_user>";

	$xmlData .= "<csapi_attribute_flag>". $attributeList        . "</csapi_attribute_flag>";
	$xmlData .= "<csapi_cvid>"          . $cvid                 . "</csapi_cvid>";

	return(new ChangeSynergy::apiObjectVector(ChangeSynergy::util::callCsapi($aUser, $xmlData, $self->getConnectionUrl())));
}

sub CreateDefaultCSObject
{
	my $self  = shift;
	my $aUser = shift;
	my $name  = shift;

	return(ChangeSynergy::util::NewCVOperation($aUser, "", "", $name, "", "", "TRUE", $self->getConnectionUrl()));
}

sub CreateCSObject
{
	my $self   = shift;
	my $aUser  = shift;
	my $cvtype = shift;
	my $name   = shift;
	my $state  = shift;

	return(ChangeSynergy::util::NewCVOperation($aUser, "", $cvtype, $name, "", $state, "TRUE"));
}

sub CreateNewCV
{
	my $self    = shift;
	my $aUser   = shift;
	my $subsys  = shift;
	my $cvtype  = shift;
	my $name    = shift;
	my $version = shift;
	my $state   = shift;

	return(ChangeSynergy::util::NewCVOperation($aUser, $subsys, $cvtype, $name, $version, $state, "TRUE"));
}

sub DeleteNewCV
{
	my $self    = shift;
	my $aUser   = shift;
	my $subsys  = shift;
	my $cvtype  = shift;
	my $name    = shift;
	my $version = shift;

	return(ChangeSynergy::util::NewCVOperation($aUser, $subsys, $cvtype, $name, $version, "", "FALSE"));
}

sub GetNewCV
{
	my $self    = shift;
	my $aUser   = shift;
	my $subsys  = shift;
	my $cvtype  = shift;
	my $name    = shift;
	my $version = shift;
	my $xmlData = "";

	if(!defined($aUser))
	{
		die "User information object is undef";
	}

	$xmlData .= "<csapi_action_flag>get_new_cv</csapi_action_flag>";
	$xmlData .= "<csapi_encoded_password>true</csapi_encoded_password>";

	$xmlData .= "<csapi_token>"		. $aUser->getUserToken()	. "</csapi_token>";
	$xmlData .= "<csapi_role>"		. $aUser->getUserRole()		. "</csapi_role>";
	$xmlData .= "<csapi_password>"  . $aUser->getUserPasswordEncoded() . "</csapi_password>";
	$xmlData .= "<csapi_database>"	. $aUser->getUserDatabase() . "</csapi_database>";
	$xmlData .= "<csapi_user>"		. $aUser->getUserName()		. "</csapi_user>";

	$xmlData .= "<csapi_cv_subsys>"  . $subsys  . "</csapi_cv_subsys>";
	$xmlData .= "<csapi_cv_type>"    . $cvtype  . "</csapi_cv_type>";
	$xmlData .= "<csapi_cv_name>"    . $name    . "</csapi_cv_name>";
	$xmlData .= "<csapi_cv_version>" . $version . "</csapi_cv_version>";

	return(new ChangeSynergy::apiData(ChangeSynergy::util::callCsapi($aUser, $xmlData, $self->getConnectionUrl())));
}

sub DeleteCV
{
	my $self    = shift;
	my $aUser   = shift;
	my $cvid    = shift;
	my $xmlData = "";

	if(!defined($aUser))
	{
		die "User information object is undef";
	}

	$xmlData .= "<csapi_action_flag>delete_cv</csapi_action_flag>";
	$xmlData .= "<csapi_encoded_password>true</csapi_encoded_password>";

	$xmlData .= "<csapi_token>"		. $aUser->getUserToken()	. "</csapi_token>";
	$xmlData .= "<csapi_role>"		. $aUser->getUserRole()		. "</csapi_role>";
	$xmlData .= "<csapi_password>"  . $aUser->getUserPasswordEncoded() . "</csapi_password>";
	$xmlData .= "<csapi_database>"	. $aUser->getUserDatabase() . "</csapi_database>";
	$xmlData .= "<csapi_user>"		. $aUser->getUserName()		. "</csapi_user>";

	$xmlData .= "<csapi_cvid>"      . $cvid                     . "</csapi_cvid>";

	return(new ChangeSynergy::apiData(ChangeSynergy::util::callCsapi($aUser, $xmlData, $self->getConnectionUrl())));
}

sub GetCV
{
	my $self    = shift;
	my $aUser   = shift;
	my $cvid    = shift;
	my $xmlData = "";

	if(!defined($aUser))
	{
		die "User information object is undef";
	}

	$xmlData .= "<csapi_action_flag>get_cv</csapi_action_flag>";
	$xmlData .= "<csapi_encoded_password>true</csapi_encoded_password>";

	$xmlData .= "<csapi_token>"		. $aUser->getUserToken()	. "</csapi_token>";
	$xmlData .= "<csapi_role>"		. $aUser->getUserRole()		. "</csapi_role>";
	$xmlData .= "<csapi_password>"  . $aUser->getUserPasswordEncoded() . "</csapi_password>";
	$xmlData .= "<csapi_database>"	. $aUser->getUserDatabase() . "</csapi_database>";
	$xmlData .= "<csapi_user>"		. $aUser->getUserName()		. "</csapi_user>";

	$xmlData .= "<csapi_cvid>"      . $cvid                     . "</csapi_cvid>";

	return(new ChangeSynergy::apiData(ChangeSynergy::util::callCsapi($aUser, $xmlData, $self->getConnectionUrl())));
}

sub GetAttributes
{
	my $self    = shift;
	my $aUser   = shift;
	my $xmlData = "";

	if(!defined($aUser))
	{
		die "User information object is undef";
	}

	$xmlData .= "<csapi_action_flag>GetAttributes</csapi_action_flag>";

	$xmlData .= "<csapi_token>"		. $aUser->getUserToken()	. "</csapi_token>";
	$xmlData .= "<csapi_role>"		. $aUser->getUserRole()		. "</csapi_role>";
	$xmlData .= "<csapi_database>"	. $aUser->getUserDatabase() . "</csapi_database>";
	$xmlData .= "<csapi_user>"		. $aUser->getUserName()		. "</csapi_user>";

	return(new ChangeSynergy::apiObjectVector(ChangeSynergy::util::callCsapi($aUser, $xmlData, $self->getConnectionUrl())));
}

sub SetAttributes
{
	my $self     = shift;
	my $aUser    = shift;
	my $cfgName  = shift;
	my $attrData = shift;

	if(!defined($aUser))
	{
		die "User information object is undef";
	}

	if(!defined($attrData))
	{
		die "Data information object is undef";
	}

	my $xmlData = "";
	my $tmp     = $attrData->toAttributeXml();

	$xmlData .= "<csapi_action_flag>SetAttributes</csapi_action_flag>";

	$xmlData .= "<csapi_token>"		. $aUser->getUserToken()	. "</csapi_token>";
	$xmlData .= "<csapi_role>"		. $aUser->getUserRole()		. "</csapi_role>";
	$xmlData .= "<csapi_database>"	. $aUser->getUserDatabase() . "</csapi_database>";
	$xmlData .= "<csapi_user>"		. $aUser->getUserName()		. "</csapi_user>";

	$xmlData .= "<csapi_cfg_name>"  . $cfgName                  . "</csapi_cfg_name>";
	$xmlData .= $tmp;

	return(new ChangeSynergy::apiData(ChangeSynergy::util::callCsapi($aUser, $xmlData, $self->getConnectionUrl())));
}


###########################################################
## Administrative Methods
###########################################################

sub CreateAttachmentObject
{
	my $self			= shift;
	my $aUser			= shift;
	my $problemNumber	= shift;
	my $relation		= shift;
	my $attachmentName	= shift;
	my $webType			= shift;
	my $comment			= shift;
	my $type			= shift;
	my $isBinary		= shift;
	my $buffer			= shift;
	my $size			= shift;

	return(ChangeSynergy::util::CreateAttachmentObjectBase($aUser, $problemNumber, $relation, $attachmentName,
														   $webType, $comment, $type, $isBinary, $buffer, $size, $self->getConnectionUrl()));
}

sub DatabaseGetObject
{
	my $self		= shift;
	my $aUser		= shift;
	my $cvid		= shift;

	return(ChangeSynergy::util::DatabaseGetObjectBase($aUser, $cvid, $self->getConnectionUrl())); 
}

sub DatabaseSetObject
{
	my $self		= shift;
	my $aUser		= shift;	
	my $cvid		= shift;
	my $comment		= shift;
	my $buffer		= shift;
	my $size		= shift;

	return(ChangeSynergy::util::DatabaseSetObjectBase($aUser, $cvid, $comment, $buffer, $size, $self->getConnectionUrl()));
}

sub ServerGetFile
{
	my $self	= shift;
	my $aUser	= shift;
	my $file	= shift;

	return(ChangeSynergy::util::ServerGetFileBase($aUser, $file, $self->getConnectionUrl()));
}

sub ServerSendFile
{
	my $self	= shift;
	my $aUser	= shift;
	my $buffer	= shift;
	my $size	= shift;

	return(ChangeSynergy::util::ServerSendFileBase($aUser, $buffer, $size, $self->getConnectionUrl()));
}

sub ValidateLicense
{
	my $self		= shift;
	my $aUser		= shift;
	my $licenseStr  = shift;
	my $xmlData		= "";

	if(!defined($aUser))
	{
		die "User information object is undef";
	}

	$xmlData .= "<csapi_action_flag>ValidateLicense</csapi_action_flag>";
	$xmlData .= "<csapi_token>"		. $aUser->getUserToken()	. "</csapi_token>";
	$xmlData .= "<csapi_role>"		. $aUser->getUserRole()		. "</csapi_role>";
	$xmlData .= "<csapi_database>"	. $aUser->getUserDatabase() . "</csapi_database>";
	$xmlData .= "<csapi_user>"		. $aUser->getUserName()		. "</csapi_user>";
	$xmlData .= "<csapi_action_item>". $licenseStr				. "</csapi_action_item>";

	my $responseData = ChangeSynergy::util::callCsapi($aUser, $xmlData, $self->getConnectionUrl());

	return ($responseData);
}

sub LoadConfigurationData
{
	my $self		= shift;
	my $aUser		= shift;

	return(ChangeSynergy::util::AdminAction($aUser, "loadconfig", "", $self->getConnectionUrl()));
}

sub LoadAllConfigurationFiles
{
	my $self          = shift;
	my $aUser         = shift;

	return(ChangeSynergy::util::ConfigAdminAction($aUser, "section_loadconfig", "false", "false", "true", "false", "false", "false", "false", "false", "false", "false", "false", "", $self->getConnectionUrl()));
}

sub LoadMergeConfigurationFiles
{
	my $self          = shift;
	my $aUser         = shift;

	return(ChangeSynergy::util::ConfigAdminAction($aUser, "section_loadconfig", "false", "false", "false", "true", "false", "false", "false", "false", "false", "false", "false", "", $self->getConnectionUrl()));
}

sub LoadConfigurationFile
{
	my $self          = shift;
	my $aUser         = shift;
	my $actConfigFile = shift;

	return(ChangeSynergy::util::ConfigAdminAction($aUser, "section_loadconfig", "false", "false", "false", "false", "false", "false", "false", "false", "false", "false", "true", $actConfigFile, $self->getConnectionUrl()));
}

sub BalanceTransactionServer
{
	my $self          = shift;
	my $aUser         = shift;

	return(ChangeSynergy::util::ConfigAdminAction($aUser, "section_loadconfig", "true", "false", "false", "false", "false", "false", "false", "false", "false", "false", "false", "", $self->getConnectionUrl()));
}

sub LoadDatabaseListboxes
{
	my $self          = shift;
	my $aUser         = shift;

	return(ChangeSynergy::util::ConfigAdminAction($aUser, "section_loadconfig", "false", "true", "false", "false", "false", "false", "false", "false", "false", "false", "false", "", $self->getConnectionUrl()));
}

sub ReloadListboxes
{
	my $self          = shift;
	my $aUser         = shift;

	return(ChangeSynergy::util::ConfigAdminAction($aUser, "section_loadconfig", "false", "true", "false", "false", "false", "false", "false", "false", "false", "false", "true", "pt_listbox.cfg", $self->getConnectionUrl()));
}

sub ClearBusySessions
{
	my $self          = shift;
	my $aUser         = shift;

	return(ChangeSynergy::util::ConfigAdminAction($aUser, "section_loadconfig", "false", "false", "false", "false", "true", "false", "false", "false", "false", "false", "false", "", $self->getConnectionUrl()));
}

sub ResetAdminTokens
{
	my $self          = shift;
	my $aUser         = shift;

	return(ChangeSynergy::util::ConfigAdminAction($aUser, "section_loadconfig", "false", "false", "false", "false", "false", "true", "false", "false", "false", "false", "false", "", $self->getConnectionUrl()));
}

sub ClearAllUserConfigurationData
{
	my $self          = shift;
	my $aUser         = shift;

	return(ChangeSynergy::util::ConfigAdminAction($aUser, "section_loadconfig", "false", "false", "false", "false", "false", "false", "true", "false", "false", "false", "false", "", $self->getConnectionUrl()));
}

sub ClearTransitionUserList
{
	my $self          = shift;
	my $aUser         = shift;

	return(ChangeSynergy::util::ConfigAdminAction($aUser, "section_loadconfig", "false", "false", "false", "false", "false", "false", "false", "true", "false", "false", "false", "", $self->getConnectionUrl()));
}

sub ResetConfigurationDataLoadTime
{
	my $self          = shift;
	my $aUser         = shift;

	return(ChangeSynergy::util::ConfigAdminAction($aUser, "section_loadconfig", "false", "false", "false", "false", "false", "false", "false", "false", "true", "false", "false", "", $self->getConnectionUrl()));
}

sub ReloadStringTable
{
	my $self          = shift;
	my $aUser         = shift;

	return(ChangeSynergy::util::ConfigAdminAction($aUser, "section_loadconfig", "false", "false", "false", "false", "false", "false", "false", "false", "false", "true", "false", "", $self->getConnectionUrl()));
}

sub CSHostName
{
	my $self		= shift;
	my $aUser		= shift;

	return(ChangeSynergy::util::AdminAction($aUser, "cs_host_name", "", $self->getConnectionUrl()));
}

sub CreateUserSecurityData
{
	return "CreateUserSecurityData is obsolete and will be removed in a future release.";
}

sub ProcessEmailSubmitForms
{
	my $self		= shift;
	my $aUser		= shift;

	return(ChangeSynergy::util::AdminAction($aUser, "process_email_submissions", "", $self->getConnectionUrl()));
}

sub ToggleDebug
{
	my $self		= shift;
	my $aUser		= shift;
	my $enable      = shift;

	return(ChangeSynergy::util::AdminAction($aUser, "toggledebug", $enable, $self->getConnectionUrl()));
}

sub ClearLog
{
	my $self		= shift;
	my $aUser		= shift;

	return(ChangeSynergy::util::AdminAction($aUser, "clearlog", "", $self->getConnectionUrl()));
}

sub CreateIndex
{
	my $self		= shift;
	my $aUser		= shift;

	return(ChangeSynergy::util::AdminAction($aUser, "create_index", "", $self->getConnectionUrl()));
}

sub UpdateIndex
{
	my $self		= shift;
	my $aUser		= shift;

	return(ChangeSynergy::util::AdminAction($aUser, "update_index", "", $self->getConnectionUrl()));
}

sub EnableIndexing
{
	my $self		= shift;
	my $aUser		= shift;

	return(ChangeSynergy::util::AdminAction($aUser, "enable_indexing", "", $self->getConnectionUrl()));
}

sub DisableIndexing
{
	my $self		= shift;
	my $aUser		= shift;

	return(ChangeSynergy::util::AdminAction($aUser, "disable_indexing", "", $self->getConnectionUrl()));
}

sub StopServerAccess
{
	my $self		= shift;
	my $aUser		= shift;

	return(ChangeSynergy::util::AdminAction($aUser, "disable_server", "", $self->getConnectionUrl()));
}

sub StartServerAccess
{
	my $self		= shift;
	my $aUser		= shift;

	return(ChangeSynergy::util::AdminAction($aUser, "enable_server", "", $self->getConnectionUrl()));
}

sub ServerAPIVersion
{
	my $self		= shift;
	my $aUser		= shift;

	return(ChangeSynergy::util::AdminAction($aUser, "APIVersion", "", $self->getConnectionUrl()));
}

sub ServerVersion
{
	my $self = shift;
	# Creating a dummy user object as null is not accepted in callCsapi sub.
	my $aUser = new ChangeSynergy::apiUser("bogusUser", "noPass", "User", "", "noDb");	

	return(ChangeSynergy::util::AdminAction($aUser, "ServerVersion", "", $self->getConnectionUrl()));
}

sub ClientAPIVersion
{
	my $self		= shift;
	my $aUser		= shift;

	if(!defined($aUser))
	{
		die "User information object is undef";
	}

	return(new ChangeSynergy::apiData("5.2"));
}

sub GetHosts
{
	my $self		= shift;
	my $aUser		= shift;

	my $xmlData		= "";

	if(!defined($aUser))
	{
		die "User information object is undef";
	}

	$xmlData .= "<csapi_action_flag>server_hosts</csapi_action_flag>";
	$xmlData .= "<csapi_encoded_password>true</csapi_encoded_password>";

	$xmlData .= "<csapi_token>"		. $aUser->getUserToken()	. "</csapi_token>";
	$xmlData .= "<csapi_role>"		. $aUser->getUserRole()		. "</csapi_role>";
	$xmlData .= "<csapi_password>"	. $aUser->getUserPasswordEncoded() . "</csapi_password>";
	$xmlData .= "<csapi_database>"	. $aUser->getUserDatabase() . "</csapi_database>";
	$xmlData .= "<csapi_user>"		. $aUser->getUserName()		. "</csapi_user>";

	return(new ChangeSynergy::apiListObject(ChangeSynergy::util::callCsapi($aUser, $xmlData, $self->getConnectionUrl()), $self->{globals}->{VALUELISTBOX_TYPE}));
}

sub GetHostSettings
{
	my ($self, $user) = @_;
	die "User information object is undef" if not defined $user; 

	my $xml_req =
		"<csapi_action_flag>get_host_settings</csapi_action_flag>" .
		"<csapi_encoded_password>true</csapi_encoded_password>" .
		"<csapi_token>" . $user->getUserToken() . "</csapi_token>" .
		"<csapi_role>" . $user->getUserRole() . "</csapi_role>" .
		"<csapi_password>" . $user->getUserPasswordEncoded() . "</csapi_password>" .
		"<csapi_database>" . $user->getUserDatabase() . "</csapi_database>" .
		"<csapi_user>" . $user->getUserName() . "</csapi_user>";

	my @hosts = ();
	my $hosts_doc = new XML::Lite(ChangeSynergy::util::callCsapi($user, $xml_req, $self->getConnectionUrl()));

	foreach ($hosts_doc->elements_by_name('host'))
	{
		my $host_doc = new XML::Lite($_->content);

		# push a hash reference for each host we iterate over.
		push @hosts, {
			'hostname' => $host_doc->element_by_name('hostname')->content,
			'type' => $host_doc->element_by_name('type')->content,
			'description' => $host_doc->element_by_name('description')->content,
			'max_sessions' => $host_doc->element_by_name('max_sessions')->content,
			'priority' => $host_doc->element_by_name('priority')->content,
			'threshold' => $host_doc->element_by_name('threshold')->content,

			# expect the strings 'true' and 'false' from the XML. Convert to truthy/falsey values
			'enabled' => 'true' eq $host_doc->element_by_name('enabled')->content
			};
	}
	
	@hosts;
}

sub GetDatabaseSettings
{
	my ($self, $user) = @_;
	die "User information object is undef" if not defined $user; 

	my $xml_req =
		"<csapi_action_flag>get_database_settings</csapi_action_flag>" .
		"<csapi_encoded_password>true</csapi_encoded_password>" .
		"<csapi_token>" . $user->getUserToken() . "</csapi_token>" .
		"<csapi_role>" . $user->getUserRole() . "</csapi_role>" .
		"<csapi_password>" . $user->getUserPasswordEncoded() . "</csapi_password>" .
		"<csapi_database>" . $user->getUserDatabase() . "</csapi_database>" .
		"<csapi_user>" . $user->getUserName() . "</csapi_user>";

	my @databases = ();
	my $databases_doc = new XML::Lite(ChangeSynergy::util::callCsapi($user, $xml_req, $self->getConnectionUrl()));

	foreach ($databases_doc->elements_by_name('database'))
	{
		my $db_doc = new XML::Lite($_->content);

		# push a hash reference for each database we iterate over.
		push @databases, {
			'path' => $db_doc->element_by_name('path')->content,
			'label' => $db_doc->element_by_name('label')->content,
			'description' => $db_doc->element_by_name('description')->content,
			'max_sessions' => $db_doc->element_by_name('max_sessions')->content,
			'min_sessions' => $db_doc->element_by_name('min_sessions')->content,
			'users_per_session' => $db_doc->element_by_name('users_per_session')->content,

			# expect the strings 'true' and 'false' from the XML. Convert to truthy/falsey values
			'enabled' => 'true' eq $db_doc->element_by_name('enabled')->content
			};
	}
	
	@databases;
}

sub EnableHost
{
	my $self		= shift;
	my $aUser		= shift;
	my $host		= shift;

	return(ChangeSynergy::util::AdminAction($aUser, "enable_host", $host, $self->getConnectionUrl()));
}

sub DisableHost
{
	my $self		= shift;
	my $aUser		= shift;
	my $host		= shift;

	return(ChangeSynergy::util::AdminAction($aUser, "disable_host", $host, $self->getConnectionUrl()));
}

sub GetDatabases
{
	my $self		= shift;
	my $aUser		= shift;

	my $xmlData		= "";

	if(!defined($aUser))
	{
		die "User information object is undef";
	}

	$xmlData .= "<csapi_action_flag>server_databases</csapi_action_flag>";
	$xmlData .= "<csapi_encoded_password>true</csapi_encoded_password>";

	$xmlData .= "<csapi_token>"		. $aUser->getUserToken()	. "</csapi_token>";
	$xmlData .= "<csapi_role>"		. $aUser->getUserRole()		. "</csapi_role>";
	$xmlData .= "<csapi_password>"	. $aUser->getUserPasswordEncoded() . "</csapi_password>";
	$xmlData .= "<csapi_database>"	. $aUser->getUserDatabase() . "</csapi_database>";
	$xmlData .= "<csapi_user>"		. $aUser->getUserName()		. "</csapi_user>";

	return(new ChangeSynergy::apiListObject(ChangeSynergy::util::callCsapi($aUser, $xmlData, $self->getConnectionUrl()), $self->{globals}->{VALUELISTBOX_TYPE}));
}


sub GetCentralCrDatabase
{
	my $self		= shift;
	my $aUser		= shift;

	my $xmlData		= "";

	if(!defined($aUser))
	{
		die "User information object is undef";
	}

	$xmlData .= "<csapi_action_flag>get_central_cr_database_name</csapi_action_flag>";
	$xmlData .= "<csapi_encoded_password>true</csapi_encoded_password>";

	$xmlData .= "<csapi_token>"		. $aUser->getUserToken()	. "</csapi_token>";
	$xmlData .= "<csapi_role>"		. $aUser->getUserRole()		. "</csapi_role>";
	$xmlData .= "<csapi_password>"	. $aUser->getUserPasswordEncoded() . "</csapi_password>";
	$xmlData .= "<csapi_database>"	. $aUser->getUserDatabase() . "</csapi_database>";
	$xmlData .= "<csapi_user>"		. $aUser->getUserName()		. "</csapi_user>";


	return(new ChangeSynergy::apiData(ChangeSynergy::util::callCsapi($aUser, $xmlData, $self->getConnectionUrl())));
}

sub EnableDatabase
{
	my $self		= shift;
	my $aUser		= shift;
	my $database	= shift;

	return(ChangeSynergy::util::AdminAction($aUser, "enable_database", $database, $self->getConnectionUrl()));
}

sub DisableDatabase
{
	my $self		= shift;
	my $aUser		= shift;
	my $database	= shift;

	return(ChangeSynergy::util::AdminAction($aUser, "disable_database", $database, $self->getConnectionUrl()));
}


sub InstallAPackage
{
	my $self        = shift;
	my $aUser	= shift;
	my $packageName = shift;
	
	return(ChangeSynergy::util::packageInstall($aUser, $packageName, $self->getConnectionUrl()));

}

sub UninstallAPackage
{
	my $self = shift;
	my $user = shift;
	my $packageName = shift;
	
	return ChangeSynergy::util::packageUninstall($user, $packageName, $self->getConnectionUrl());	
}

sub createProcessPackage
{
	my $self = shift;
	my $user = shift;
	my $xmlFileName = shift;
	my $packageTemplate = shift;
	
	my $xmlData = "";
	
	if(!defined($user))
	{
		die "User information object is undef";
	}
	
	$xmlData .= "<csapi_action_flag>createProcessPackage</csapi_action_flag>";
	$xmlData .= "<csapi_encoded_password>true</csapi_encoded_password>";

	$xmlData .= "<csapi_xml_file_name>"  . $xmlFileName . "</csapi_xml_file_name>";
	
	if(defined($packageTemplate))
	{
		$xmlData .= "<csapi_package_template>"  . $packageTemplate . "</csapi_package_template>";
	}
	
	$xmlData .= "<csapi_token>"		. $user->getUserToken()	. "</csapi_token>";
	$xmlData .= "<csapi_role>"		. $user->getUserRole()		. "</csapi_role>";
	$xmlData .= "<csapi_password>"	. $user->getUserPasswordEncoded() . "</csapi_password>";
	$xmlData .= "<csapi_database>"	. $user->getUserDatabase() . "</csapi_database>";
	$xmlData .= "<csapi_user>"		. $user->getUserName()		. "</csapi_user>";
	
	return(new ChangeSynergy::apiData(ChangeSynergy::util::callCsapi($user, $xmlData, $self->getConnectionUrl())));
}

###########################################################
## List Object Methods
###########################################################

sub GetValueListBox
{
	my $self		= shift;
	my $aUser		= shift;
	my $listObject  = undef;
	my $configType  = undef;

	if(@_ == 1)
	{
		$listObject  = shift;
		$configType  = $self->{globals}->{SYSTEM_CONFIG};
	}
	elsif(@_ == 2)
	{
		$listObject  = shift;
		$configType  = shift;	
	}

	my $xmlData		= "";

	if(!defined($aUser))
	{
		die "User information object is undef";
	}

	$xmlData .= "<csapi_action_flag>GetValueListbox</csapi_action_flag>";
	$xmlData .= "<csapi_encoded_password>true</csapi_encoded_password>";

	$xmlData .= "<csapi_token>"		   . $aUser->getUserToken()    . "</csapi_token>";
	$xmlData .= "<csapi_role>"		   . $aUser->getUserRole()     . "</csapi_role>";
	$xmlData .= "<csapi_password>"	   . $aUser->getUserPasswordEncoded() . "</csapi_password>";
	$xmlData .= "<csapi_database>"	   . $aUser->getUserDatabase() . "</csapi_database>";
	$xmlData .= "<csapi_user>"		   . $aUser->getUserName()     . "</csapi_user>";
	$xmlData .= "<csapi_profile_type>" . $configType               . "</csapi_profile_type>";
	
	$xmlData .= "<csapi_valuelistbox>" . $listObject . "</csapi_valuelistbox>";

	return(new ChangeSynergy::apiListObject(ChangeSynergy::util::callCsapi($aUser, $xmlData, $self->getConnectionUrl()), $self->{globals}->{VALUELISTBOX_TYPE}));
}

sub GetListBox
{
	my $self		= shift;
	my $aUser		= shift;
	my $listObject  = undef;
	my $configType  = undef;
	
	if(@_ == 1)
	{
		$listObject  = shift;
		$configType  = $self->{globals}->{SYSTEM_CONFIG};
	}
	elsif(@_ == 2)
	{
		$listObject  = shift;
		$configType  = shift;	
	}

	my $xmlData		= "";

	if(!defined($aUser))
	{
		die "User information object is undef";
	}

	$xmlData .= "<csapi_action_flag>GetListbox</csapi_action_flag>";
	$xmlData .= "<csapi_encoded_password>true</csapi_encoded_password>";

	$xmlData .= "<csapi_token>"		   . $aUser->getUserToken()    . "</csapi_token>";
	$xmlData .= "<csapi_role>"		   . $aUser->getUserRole()     . "</csapi_role>";
	$xmlData .= "<csapi_password>"	   . $aUser->getUserPasswordEncoded() . "</csapi_password>";
	$xmlData .= "<csapi_database>"	   . $aUser->getUserDatabase() . "</csapi_database>";
	$xmlData .= "<csapi_user>"		   . $aUser->getUserName()     . "</csapi_user>";
	$xmlData .= "<csapi_profile_type>" . $configType               . "</csapi_profile_type>";
		
	$xmlData .= "<csapi_listbox>" . $listObject . "</csapi_listbox>";

	return(new ChangeSynergy::apiListObject(ChangeSynergy::util::callCsapi($aUser, $xmlData, $self->getConnectionUrl()), $self->{globals}->{LISTBOX_TYPE}));
}

sub GetList
{
	my $self		= shift;
	my $aUser		= shift;
	my $listObject  = undef;
	my $configType  = undef;
	
	if(@_ == 1)
	{
		$listObject  = shift;
		$configType  = $self->{globals}->{SYSTEM_CONFIG};
	}
	elsif(@_ == 2)
	{
		$listObject  = shift;
		$configType  = shift;	
	}
	
	my $xmlData		= "";

	if(!defined($aUser))
	{
		die "User information object is undef";
	}

	$xmlData .= "<csapi_action_flag>GetList</csapi_action_flag>";
	$xmlData .= "<csapi_encoded_password>true</csapi_encoded_password>";

	$xmlData .= "<csapi_token>"		   . $aUser->getUserToken()    . "</csapi_token>";
	$xmlData .= "<csapi_role>"		   . $aUser->getUserRole()     . "</csapi_role>";
	$xmlData .= "<csapi_password>"	   . $aUser->getUserPasswordEncoded() . "</csapi_password>";
	$xmlData .= "<csapi_database>"	   . $aUser->getUserDatabase() . "</csapi_database>";
	$xmlData .= "<csapi_user>"		   . $aUser->getUserName()     . "</csapi_user>";
	$xmlData .= "<csapi_profile_type>" . $configType               . "</csapi_profile_type>";

	$xmlData .= "<csapi_list>" . $listObject . "</csapi_list>";

	return(new ChangeSynergy::apiListObject(ChangeSynergy::util::callCsapi($aUser, $xmlData, $self->getConnectionUrl()), $self->{globals}->{LIST_TYPE}));
}

sub GetDataListBox
{
	my $self		= shift;
	my $aUser		= shift;
	my $listObject  = undef;
	my $configType  = undef;
	
	if(@_ == 1)
	{
		$listObject  = shift;
		$configType  = $self->{globals}->{SYSTEM_CONFIG};
	}
	elsif(@_ == 2)
	{
		$listObject  = shift;
		$configType  = shift;	
	}

	my $xmlData		= "";

	if(!defined($aUser))
	{
		die "User information object is undef";
	}

	$xmlData .= "<csapi_action_flag>GetDataListbox</csapi_action_flag>";
	$xmlData .= "<csapi_encoded_password>true</csapi_encoded_password>";

	$xmlData .= "<csapi_token>"		   . $aUser->getUserToken()    . "</csapi_token>";
	$xmlData .= "<csapi_role>"		   . $aUser->getUserRole()     . "</csapi_role>";
	$xmlData .= "<csapi_password>"	   . $aUser->getUserPasswordEncoded() . "</csapi_password>";
	$xmlData .= "<csapi_database>"	   . $aUser->getUserDatabase() . "</csapi_database>";
	$xmlData .= "<csapi_user>"		   . $aUser->getUserName()     . "</csapi_user>";
	$xmlData .= "<csapi_profile_type>" . $configType               . "</csapi_profile_type>";

	$xmlData .= "<csapi_datalistbox>" . $listObject . "</csapi_datalistbox>";

	return(new ChangeSynergy::apiListObject(ChangeSynergy::util::callCsapi($aUser, $xmlData, $self->getConnectionUrl()), $self->{globals}->{DATALISTBOX_TYPE}));
}

sub GetListBoxDefaultValue
{
      my $self          = shift;
      my $aUser         = shift;

      if(!defined($aUser))
      {
            die "User information object is undef";
      }

      my $xmlData       = ""; 

      $xmlData .= "<csapi_action_flag>getListboxDefaultValue</csapi_action_flag>";
      $xmlData .= "<csapi_token>"            . $aUser->getUserToken()    . "</csapi_token>";
      $xmlData .= "<csapi_user>"             . $aUser->getUserName()     . "</csapi_user>";

      return (new ChangeSynergy::apiData(ChangeSynergy::util::callCsapi($aUser, $xmlData, $self->getConnectionUrl())));
}

sub GetReport
{
	my $self		= shift;
	my $aUser		= shift;
	my $listObject  = undef;
	my $configType  = undef;
	
	if(@_ == 1)
	{
		$listObject  = shift;
		$configType  = $self->{globals}->{SYSTEM_CONFIG};
	}
	elsif(@_ == 2)
	{
		$listObject  = shift;
		$configType  = shift;	
	}

	my $xmlData		= "";

	if(!defined($aUser))
	{
		die "User information object is undef";
	}

	$xmlData .= "<csapi_action_flag>GetReport</csapi_action_flag>";
	$xmlData .= "<csapi_encoded_password>true</csapi_encoded_password>";

	$xmlData .= "<csapi_token>"		   . $aUser->getUserToken()    . "</csapi_token>";
	$xmlData .= "<csapi_role>"		   . $aUser->getUserRole()     . "</csapi_role>";
	$xmlData .= "<csapi_password>"	   . $aUser->getUserPasswordEncoded() . "</csapi_password>";
	$xmlData .= "<csapi_database>"	   . $aUser->getUserDatabase() . "</csapi_database>";
	$xmlData .= "<csapi_user>"		   . $aUser->getUserName()     . "</csapi_user>";
	$xmlData .= "<csapi_profile_type>" . $configType               . "</csapi_profile_type>";
	
	$xmlData .= "<csapi_report>" . $listObject . "</csapi_report>";

	return(new ChangeSynergy::apiListObject(ChangeSynergy::util::callCsapi($aUser, $xmlData, $self->getConnectionUrl()), $self->{globals}->{REPORT_TYPE}));
}

sub GetQuery
{
	my $self		= shift;
	my $aUser		= shift;
	my $listObject  = undef;
	my $configType  = undef;
	
	if(@_ == 1)
	{
		$listObject  = shift;
		$configType  = $self->{globals}->{SYSTEM_CONFIG};
	}
	elsif(@_ == 2)
	{
		$listObject  = shift;
		$configType  = shift;	
	}

	my $xmlData		= "";

	if(!defined($aUser))
	{
		die "User information object is undef";
	}

	$xmlData .= "<csapi_action_flag>GetQuery</csapi_action_flag>";
	$xmlData .= "<csapi_encoded_password>true</csapi_encoded_password>";

	$xmlData .= "<csapi_token>"		   . $aUser->getUserToken()    . "</csapi_token>";
	$xmlData .= "<csapi_role>"		   . $aUser->getUserRole()     . "</csapi_role>";
	$xmlData .= "<csapi_password>"	   . $aUser->getUserPasswordEncoded() . "</csapi_password>";
	$xmlData .= "<csapi_database>"	   . $aUser->getUserDatabase() . "</csapi_database>";
	$xmlData .= "<csapi_user>"		   . $aUser->getUserName()     . "</csapi_user>";
	$xmlData .= "<csapi_profile_type>" . $configType               . "</csapi_profile_type>";
	
	$xmlData .= "<csapi_query>" . $listObject . "</csapi_query>";

	return(new ChangeSynergy::apiListObject(ChangeSynergy::util::callCsapi($aUser, $xmlData, $self->getConnectionUrl()), $self->{globals}->{REPORT_TYPE}));
}

###########################################################
## Report and Folder management methods
###########################################################
sub createReport
{
	my $self = shift;
	my $aUser = shift;
	my $reportDefinition = shift;
	my $objectType = shift;
	my $configType = shift;
	
	if (!defined($aUser))
	{
		die "User information object is undef";
	}
	
	my $datalistbox = ChangeSynergy::util::getDatalistboxName($objectType, $self->{globals}->{REPORT}, $configType);
	
	my $xmlData = "<csapi_action_flag>createReport</csapi_action_flag>";
	
	$xmlData .= "<csapi_datalistbox>" . ChangeSynergy::util::xmlEncode($datalistbox).  "</csapi_datalistbox>";
	$xmlData .= "<csapi_profile_type>" . $configType . "</csapi_profile_type>";
	
	$xmlData .= $reportDefinition->toXml();
	
	$xmlData .= "<csapi_token>"		   . $aUser->getUserToken()    . "</csapi_token>";
	$xmlData .= "<csapi_role>"		   . $aUser->getUserRole()     . "</csapi_role>";
	$xmlData .= "<csapi_database>"	   . $aUser->getUserDatabase() . "</csapi_database>";
	$xmlData .= "<csapi_user>"		   . $aUser->getUserName()     . "</csapi_user>";
	
	return (new ChangeSynergy::apiData(ChangeSynergy::util::callCsapi($aUser, $xmlData, $self->getConnectionUrl())));
}

sub exportAReport
{
	my $self = shift;
	my $aUser = shift;
	my $reportName = shift;
	my $objectType = shift;
	my $configType = shift;
	
	if(!defined($aUser))
	{
		die "User information object is undef";
	}
	
	my $datalistbox = ChangeSynergy::util::getDatalistboxName($objectType, $self->{globals}->{REPORT}, $configType);
		
	my $xmlData = "<csapi_action_flag>exportAReport</csapi_action_flag>";
	
	$xmlData .= "<csapi_chosen_report>" . ChangeSynergy::util::xmlEncode($reportName) . "</csapi_chosen_report>";
	$xmlData .= "<csapi_datalistbox>" . ChangeSynergy::util::xmlEncode($datalistbox).  "</csapi_datalistbox>";
	$xmlData .= "<csapi_profile_type>" . $configType . "</csapi_profile_type>";
	
	$xmlData .= "<csapi_token>"		   . $aUser->getUserToken()    . "</csapi_token>";
	$xmlData .= "<csapi_role>"		   . $aUser->getUserRole()     . "</csapi_role>";
	$xmlData .= "<csapi_database>"	   . $aUser->getUserDatabase() . "</csapi_database>";
	$xmlData .= "<csapi_user>"		   . $aUser->getUserName()     . "</csapi_user>";
	
	return new ChangeSynergy::ReportEntryFactory()->createReportEntryFromXml(ChangeSynergy::util::callCsapi($aUser, $xmlData, $self->getConnectionUrl()));
}

sub exportReportsFromFolder
{
	my $self = shift;
	my $aUser = shift;
	my $folderName = shift;
	my $objectType = shift;
	my $configType = shift;
		
	if(!defined($aUser))
	{
		die "User information object is undef";
	}
	
	my $datalistbox = ChangeSynergy::util::getDatalistboxName($objectType, $self->{globals}->{REPORT}, $configType);
		
	my $xmlData = "<csapi_action_flag>exportReportsFromFolder</csapi_action_flag>";
	
	$xmlData .= "<csapi_folder_name>" . ChangeSynergy::util::xmlEncode($folderName) . "</csapi_folder_name>";
	$xmlData .= "<csapi_datalistbox>" . ChangeSynergy::util::xmlEncode($datalistbox).  "</csapi_datalistbox>";
	$xmlData .= "<csapi_profile_type>" . $configType . "</csapi_profile_type>";
	
	$xmlData .= "<csapi_token>"		   . $aUser->getUserToken()    . "</csapi_token>";
	$xmlData .= "<csapi_role>"		   . $aUser->getUserRole()     . "</csapi_role>";
	$xmlData .= "<csapi_database>"	   . $aUser->getUserDatabase() . "</csapi_database>";
	$xmlData .= "<csapi_user>"		   . $aUser->getUserName()     . "</csapi_user>";
	
	return new ChangeSynergy::ReportEntryFactory()->createReportEntriesFromXml(ChangeSynergy::util::callCsapi($aUser, $xmlData, $self->getConnectionUrl()));
}

sub importAReport
{
	my $self = shift;
	my $aUser = shift;
	my $reportEntry = shift;
	my $objectType = shift;
	my $configType = shift;
	
	if(!defined($aUser))
	{
		die "User information object is undef";
	}
	
	my $datalistbox = ChangeSynergy::util::getDatalistboxName($objectType, $self->{globals}->{REPORT}, $configType);
		
	my $xmlData = "<csapi_action_flag>add_user_report</csapi_action_flag>";
	
	$xmlData .= "<csapi_datalistbox>" . ChangeSynergy::util::xmlEncode($datalistbox).  "</csapi_datalistbox>";
	$xmlData .= "<csapi_profile_type>" . $configType . "</csapi_profile_type>";
	$xmlData .= "<csapi_chosen_report>" . ChangeSynergy::util::xmlEncode($reportEntry->getName()) . "</csapi_chosen_report>";
	$xmlData .= "<csapi_folder_name>" . ChangeSynergy::util::xmlEncode($reportEntry->getFolderName()) . "</csapi_folder_name>";
	$xmlData .= "<csapi_config_file>" . ChangeSynergy::util::xmlEncode($reportEntry->toConfigData()) . "</csapi_config_file>";
	
	$xmlData .= "<csapi_token>"		   . $aUser->getUserToken()    . "</csapi_token>";
	$xmlData .= "<csapi_role>"		   . $aUser->getUserRole()     . "</csapi_role>";
	$xmlData .= "<csapi_database>"	   . $aUser->getUserDatabase() . "</csapi_database>";
	$xmlData .= "<csapi_user>"		   . $aUser->getUserName()     . "</csapi_user>";
	
	return (new ChangeSynergy::apiData(ChangeSynergy::util::callCsapi($aUser, $xmlData, $self->getConnectionUrl())));
}

sub deleteReport
{
	my $self = shift;
	my $aUser = shift;
	my $reportName = shift;
	my $objectType = shift;
	my $configType = shift;
	
	if(!defined($aUser))
	{
		die "User information object is undef";
	}
	
	my $datalistbox = ChangeSynergy::util::getDatalistboxName($objectType, $self->{globals}->{REPORT}, $configType);
		
	my $xmlData = "<csapi_action_flag>delete_user_report</csapi_action_flag>";
	
	$xmlData .= "<csapi_chosen_report>" . ChangeSynergy::util::xmlEncode($reportName) . "</csapi_chosen_report>";
	$xmlData .= "<csapi_datalistbox>" . ChangeSynergy::util::xmlEncode($datalistbox).  "</csapi_datalistbox>";
	$xmlData .= "<csapi_profile_type>" . $configType . "</csapi_profile_type>";
	
	$xmlData .= "<csapi_token>"		   . $aUser->getUserToken()    . "</csapi_token>";
	$xmlData .= "<csapi_role>"		   . $aUser->getUserRole()     . "</csapi_role>";
	$xmlData .= "<csapi_database>"	   . $aUser->getUserDatabase() . "</csapi_database>";
	$xmlData .= "<csapi_user>"		   . $aUser->getUserName()     . "</csapi_user>";
	
	return (new ChangeSynergy::apiData(ChangeSynergy::util::callCsapi($aUser, $xmlData, $self->getConnectionUrl())));
}

sub addFolder
{
	my $self = shift;
	my $aUser = shift;
	my $folderName = shift;
	my $objectType = shift;
	my $formatType = shift;
	my $configType = shift;
	
	if(!defined($aUser))
	{
		die "User information object is undef";
	}
	
	my $datalistbox = ChangeSynergy::util::getDatalistboxName($objectType, $formatType, $configType);
		
	my $xmlData = "<csapi_action_flag>addFolder</csapi_action_flag>";
	
	$xmlData .= "<csapi_folder_name>" . ChangeSynergy::util::xmlEncode($folderName) . "</csapi_folder_name>";
	$xmlData .= "<csapi_datalistbox>" . ChangeSynergy::util::xmlEncode($datalistbox).  "</csapi_datalistbox>";
	$xmlData .= "<csapi_profile_type>" . $configType . "</csapi_profile_type>";
	
	$xmlData .= "<csapi_token>"		   . $aUser->getUserToken()    . "</csapi_token>";
	$xmlData .= "<csapi_role>"		   . $aUser->getUserRole()     . "</csapi_role>";
	$xmlData .= "<csapi_database>"	   . $aUser->getUserDatabase() . "</csapi_database>";
	$xmlData .= "<csapi_user>"		   . $aUser->getUserName()     . "</csapi_user>";
	
	return (new ChangeSynergy::apiData(ChangeSynergy::util::callCsapi($aUser, $xmlData, $self->getConnectionUrl())));	
}
 
sub deleteFolder
{
	my $self = shift;
	my $aUser = shift;
	my $folderName = shift;
	my $objectType = shift;
	my $formatType = shift;
	my $configType = shift;
	
	if(!defined($aUser))
	{
		die "User information object is undef";
	}
	
	my $datalistbox = ChangeSynergy::util::getDatalistboxName($objectType, $formatType, $configType);
		
	my $xmlData = "<csapi_action_flag>deleteFolder</csapi_action_flag>";
	
	$xmlData .= "<csapi_folder_name>" . ChangeSynergy::util::xmlEncode($folderName) . "</csapi_folder_name>";
	$xmlData .= "<csapi_datalistbox>" . ChangeSynergy::util::xmlEncode($datalistbox).  "</csapi_datalistbox>";
	$xmlData .= "<csapi_profile_type>" . $configType . "</csapi_profile_type>";
	
	$xmlData .= "<csapi_token>"		   . $aUser->getUserToken()    . "</csapi_token>";
	$xmlData .= "<csapi_role>"		   . $aUser->getUserRole()     . "</csapi_role>";
	$xmlData .= "<csapi_database>"	   . $aUser->getUserDatabase() . "</csapi_database>";
	$xmlData .= "<csapi_user>"		   . $aUser->getUserName()     . "</csapi_user>";
	
	return (new ChangeSynergy::apiData(ChangeSynergy::util::callCsapi($aUser, $xmlData, $self->getConnectionUrl())));
}

sub renameFolder
{
	my $self = shift;
	my $aUser = shift;
	my $folderName = shift;
	my $newfolderName = shift;
	my $objectType = shift;
	my $formatType = shift;
	my $configType = shift;
	
	if(!defined($aUser))
	{
		die "User information object is undef";
	}
	
	my $datalistbox = ChangeSynergy::util::getDatalistboxName($objectType, $formatType, $configType);
	
	my $xmlData = "<csapi_action_flag>renameFolder</csapi_action_flag>";
	
	$xmlData .= "<csapi_folder_name>" . ChangeSynergy::util::xmlEncode($folderName) . "</csapi_folder_name>";
	$xmlData .= "<csapi_new_folder_name>" . ChangeSynergy::util::xmlEncode($newfolderName) . "</csapi_new_folder_name>";
	$xmlData .= "<csapi_datalistbox>" . ChangeSynergy::util::xmlEncode($datalistbox).  "</csapi_datalistbox>";
	$xmlData .= "<csapi_profile_type>" . $configType . "</csapi_profile_type>";
	
	$xmlData .= "<csapi_token>"		   . $aUser->getUserToken()    . "</csapi_token>";
	$xmlData .= "<csapi_role>"		   . $aUser->getUserRole()     . "</csapi_role>";
	$xmlData .= "<csapi_database>"	   . $aUser->getUserDatabase() . "</csapi_database>";
	$xmlData .= "<csapi_user>"		   . $aUser->getUserName()     . "</csapi_user>";
	
	return (new ChangeSynergy::apiData(ChangeSynergy::util::callCsapi($aUser, $xmlData, $self->getConnectionUrl())));
}

sub moveFolderMembers
{
	my $self = shift;
	my $aUser = shift;
	my $toFolderName = shift;
	my $memberList = shift;
	my $objectType = shift;
	my $formatType = shift;
	my $configType = shift;
	
	if(!defined($aUser))
	{
		die "User information object is undef";
	}
	
	my $datalistbox = ChangeSynergy::util::getDatalistboxName($objectType, $formatType, $configType);
	
	my $xmlData = "<csapi_action_flag>moveFolderMembers</csapi_action_flag>";
	
	$xmlData .= "<csapi_folder_name>" . ChangeSynergy::util::xmlEncode($toFolderName) . "</csapi_folder_name>";
	$xmlData .= "<csapi_members_list>" . ChangeSynergy::util::xmlEncode($memberList) . "</csapi_members_list>";
	$xmlData .= "<csapi_datalistbox>" . ChangeSynergy::util::xmlEncode($datalistbox).  "</csapi_datalistbox>";
	$xmlData .= "<csapi_profile_type>" . $configType . "</csapi_profile_type>";
	
	$xmlData .= "<csapi_token>"		   . $aUser->getUserToken()    . "</csapi_token>";
	$xmlData .= "<csapi_role>"		   . $aUser->getUserRole()     . "</csapi_role>";
	$xmlData .= "<csapi_database>"	   . $aUser->getUserDatabase() . "</csapi_database>";
	$xmlData .= "<csapi_user>"		   . $aUser->getUserName()     . "</csapi_user>";
	
	return (new ChangeSynergy::apiData(ChangeSynergy::util::callCsapi($aUser, $xmlData, $self->getConnectionUrl())));
	
}

sub listFolders
{
	my $self = shift;
	my $aUser = shift;
	my $objectType = shift;
	my $formatType = shift;
	my $configType = shift;
	
	if(!defined($aUser))
	{
		die "User information object is undef";
	}
	
	my $datalistbox = ChangeSynergy::util::getDatalistboxName($objectType, $formatType, $configType);
		
	my $xmlData = "<csapi_action_flag>listFolders</csapi_action_flag>";
		
	$xmlData .= "<csapi_datalistbox>" . ChangeSynergy::util::xmlEncode($datalistbox).  "</csapi_datalistbox>";
	$xmlData .= "<csapi_profile_type>" . $configType . "</csapi_profile_type>";
	
	$xmlData .= "<csapi_token>"		   . $aUser->getUserToken()    . "</csapi_token>";
	$xmlData .= "<csapi_role>"		   . $aUser->getUserRole()     . "</csapi_role>";
	$xmlData .= "<csapi_database>"	   . $aUser->getUserDatabase() . "</csapi_database>";
	$xmlData .= "<csapi_user>"		   . $aUser->getUserName()     . "</csapi_user>";
	
	my $globals = new ChangeSynergy::Globals();
	return(new ChangeSynergy::apiListObject(ChangeSynergy::util::callCsapi($aUser, $xmlData, $self->getConnectionUrl()), $globals->{LIST_TYPE}));
}

sub getFolderSecurityRule
{
	my $self = shift;
	my $aUser = shift;
	my $folderName = shift;
	my $objectType = shift;
	my $formatType = shift;
	my $configType = shift;
	
	if(!defined($aUser))
	{
		die "User information object is undef";
	}
	
	my $datalistbox = ChangeSynergy::util::getDatalistboxName($objectType, $formatType, $configType);
		
	my $xmlData = "<csapi_action_flag>getFolderSecurityRule</csapi_action_flag>";
	
	$xmlData .= "<csapi_folder_name>" . ChangeSynergy::util::xmlEncode($folderName) . "</csapi_folder_name>";
	$xmlData .= "<csapi_datalistbox>" . ChangeSynergy::util::xmlEncode($datalistbox).  "</csapi_datalistbox>";
	$xmlData .= "<csapi_profile_type>" . $configType . "</csapi_profile_type>";
	
	$xmlData .= "<csapi_token>"		   . $aUser->getUserToken()    . "</csapi_token>";
	$xmlData .= "<csapi_role>"		   . $aUser->getUserRole()     . "</csapi_role>";
	$xmlData .= "<csapi_database>"	   . $aUser->getUserDatabase() . "</csapi_database>";
	$xmlData .= "<csapi_user>"		   . $aUser->getUserName()     . "</csapi_user>";
	
	return(new ChangeSynergy::FolderSecurityRule(ChangeSynergy::util::callCsapi($aUser, $xmlData, $self->getConnectionUrl())));
}

sub setFolderSecurityRule
{
	my $self = shift;
	my $aUser = shift;
	my $folderRule = shift;
	my $objectType = shift;
	my $formatType = shift;
	my $configType = shift;
	
	if(!defined($aUser))
	{
		die "User information object is undef";
	}
	
	my $datalistbox = ChangeSynergy::util::getDatalistboxName($objectType, $formatType, $configType);
		
	my $xmlData = "<csapi_action_flag>setFolderSecurityRule</csapi_action_flag>";
	
	$xmlData .= "<csapi_datalistbox>" . ChangeSynergy::util::xmlEncode($datalistbox).  "</csapi_datalistbox>";
	$xmlData .= "<csapi_profile_type>" . $configType . "</csapi_profile_type>";
	$xmlData .= $folderRule->toXml();

	$xmlData .= "<csapi_token>"		   . $aUser->getUserToken()    . "</csapi_token>";
	$xmlData .= "<csapi_role>"		   . $aUser->getUserRole()     . "</csapi_role>";
	$xmlData .= "<csapi_database>"	   . $aUser->getUserDatabase() . "</csapi_database>";
	$xmlData .= "<csapi_user>"		   . $aUser->getUserName()     . "</csapi_user>";
	
	return(new ChangeSynergy::apiData(ChangeSynergy::util::callCsapi($aUser, $xmlData, $self->getConnectionUrl())));
}


###########################################################
## Administrative Methods
###########################################################

sub setUpConnection
{
	my $connect_to = "";
	my $self = shift;

	if (@_ == 1) #If only one parameter is given
	{
		my $url = $_[0]; 
		# if url ends with '/', chop it. 
		if ($url =~ /\/$/)
		{
			chop $url;
		} 
		
		#assumeing it is desired URL
		$connect_to = $url;
	}
	elsif (@_ == 3) 	#For more than one parameters(3 parameters)
	{
		#Expected order would be: 1-protocol, 2-host, 3-port
		$connect_to = $_[0] . "://" . $_[1] . ":" . $_[2] . "/change";
		print "\nWarning: setUpConnection(protocol, host, port) has been deprecated; use setUpConnection(url) instead. Proceeding with the URL \'". $connect_to ."\'\n";
	}
	
	if((!defined($connect_to)) || ($connect_to eq ""))
	{
		die "Cannot establish internet connection with provided parameters";
	}

	#Sets the constructed URL for futher use.
	$self->setConnectionUrl($connect_to);
}



sub setReportConfigType
{
	my $self		= shift;
	my $configType	= shift;

	if(!defined($configType))
	{
		die "configType is undef.";
	}
	
	$self->{reportConfigType} = $configType;
}

sub setQueryConfigType
{
	my $self		= shift;
	my $configType	= shift;

	if(!defined($configType))
	{
		die "configType is undef.";
	}
	
	$self->{queryConfigType} = $configType;
}


sub Login
{
	my $self		= shift;
	my $user		= shift;
	my $password	= shift;
	my $role		= shift;
	my $database	= shift;
	my $aUser		= undef;
	my $xmlData		= "";

	if(!defined($database) || length($database) == 0)
	{
		die "Missing required login data\n";
	}
	
	$aUser = new ChangeSynergy::apiUser($user, $password, $role, $database);

	$xmlData .= "<csapi_action_flag>login</csapi_action_flag>";
	$xmlData .= "<csapi_encoded_password>true</csapi_encoded_password>";

	$xmlData .= "<csapi_user>"		. $aUser->getUserName()		. "</csapi_user>";
	$xmlData .= "<csapi_password>"	. $aUser->getUserPasswordEncoded() . "</csapi_password>";
	$xmlData .= "<csapi_role>"		. $aUser->getUserRole()		. "</csapi_role>";
	$xmlData .= "<csapi_database>"	. $aUser->getUserDatabase() . "</csapi_database>";

	my $token = (ChangeSynergy::util::callCsapi($aUser, $xmlData, $self->getConnectionUrl()));

	$aUser->setUserToken($token);

	return $aUser;
}

sub SwitchUser
{
	my $self			= shift;
	my $aUser			= shift;
	my $targetUserName	= shift;
	my $targetRole		= shift;
	my $targetDatabase  = shift;
	
	my $aTargetUser = undef;
	my $xmlData		= "";

	if(!defined($targetDatabase) || length($targetDatabase) == 0)
	{
		die "Missing required login data\n";
	}
	
	$aTargetUser = new ChangeSynergy::apiUser($targetUserName, "", $targetRole, $targetDatabase);
	
	$xmlData .= "<csapi_action_flag>switch_user</csapi_action_flag>";
	$xmlData .= "<csapi_token>"     . $aUser->getUserToken()    . "</csapi_token>";
	$xmlData .= "<csapi_role>"      . $aUser->getUserRole()     . "</csapi_role>";
	$xmlData .= "<csapi_database>"  . $aUser->getUserDatabase() . "</csapi_database>";
	$xmlData .= "<csapi_user>"      . $aUser->getUserName()     . "</csapi_user>";
	
	$xmlData .= "<csapi_username>"      . $aTargetUser->getUserName()       . "</csapi_username>";
	$xmlData .= "<csapi_role_name>"     . $aTargetUser->getUserRole()       . "</csapi_role_name>";
	$xmlData .= "<csapi_database_name>" . $aTargetUser->getUserDatabase()   . "</csapi_database_name>";

	my $token = (ChangeSynergy::util::callCsapi($aUser, $xmlData, $self->getConnectionUrl()));

	$aTargetUser->setUserToken($token);

	return $aTargetUser;
}

sub GetDOORSAttribute
{
	my $self           = shift;
	my $aUser          = shift;
	my $cvid           = shift;
	my $attributeValue = shift;
	my $attributeTag   = shift;
	my $objectType     = shift;
	my $charSet        = shift;
	my $xmlData        = "";

	if(!defined($aUser))
	{
		die "User information object is undef";
	}

	$xmlData .= "<csapi_action_flag>get_DOORS_attribute</csapi_action_flag>";
	
	$xmlData .= "<csapi_token>"		. $aUser->getUserToken()	. "</csapi_token>";
	$xmlData .= "<csapi_role>"		. $aUser->getUserRole()		. "</csapi_role>";
	$xmlData .= "<csapi_database>"	. $aUser->getUserDatabase() . "</csapi_database>";
	$xmlData .= "<csapi_user>"		. $aUser->getUserName()		. "</csapi_user>";
	
	$xmlData .= "<csapi_cvid>"          . $cvid           . "</csapi_cvid>";
	$xmlData .= "<csapi_keyname>"       . $attributeValue . "</csapi_keyname>";
	$xmlData .= "<csapi_attribute_flag>". $attributeTag   . "</csapi_attribute_flag>";
	$xmlData .= "<csapi_keyvalue>"      . $objectType     . "</csapi_keyvalue>";
	$xmlData .= "<csapi_preferenceName>". $charSet        . "</csapi_preferenceName>";

	return (new ChangeSynergy::apiData(ChangeSynergy::util::callCsapi($aUser, $xmlData, $self->getConnectionUrl())));
}

sub GetDOORSAttribute52
{
	my $self           = shift;
	my $aUser          = shift;
	my $cvid           = shift;
	my $attributeValue = shift;
	my $attributeTag   = shift;
	my $objectType     = shift;
	my $objectId       = shift;
	my $charSet        = shift;
	my $xmlData        = "";

	if(!defined($aUser))
	{
		die "User information object is undef";
	}

	$xmlData .= "<csapi_action_flag>getDoorsAttribute52</csapi_action_flag>";
	
	$xmlData .= "<csapi_token>"		. $aUser->getUserToken()	. "</csapi_token>";
	$xmlData .= "<csapi_role>"		. $aUser->getUserRole()		. "</csapi_role>";
	$xmlData .= "<csapi_database>"	. $aUser->getUserDatabase() . "</csapi_database>";
	$xmlData .= "<csapi_user>"		. $aUser->getUserName()		. "</csapi_user>";
	
	$xmlData .= "<csapi_cvid>"          . $cvid           . "</csapi_cvid>";
	$xmlData .= "<csapi_keyname>"       . $attributeValue . "</csapi_keyname>";
	$xmlData .= "<csapi_attribute_flag>". $attributeTag   . "</csapi_attribute_flag>";
	$xmlData .= "<csapi_keyvalue>"      . $objectType     . "</csapi_keyvalue>";
	$xmlData .= "<csapi_object_id>"     . $objectId       . "</csapi_object_id>";
	$xmlData .= "<csapi_preferenceName>". $charSet        . "</csapi_preferenceName>";

	return (new ChangeSynergy::apiData(ChangeSynergy::util::callCsapi($aUser, $xmlData, $self->getConnectionUrl())));
}

####################################################################
## Any basic form type
####################################################################

sub LoadFormHtml
{
	my $self		 = shift;
	my $aUser		 = shift;
	my $templateName = shift;
	my $templateType = shift;
	my $xmlData		= "";

	if(!defined($aUser))
	{
		die "User information object is undef";
	}

	$xmlData .= "<csapi_token>"			. $aUser->getUserToken()	. "</csapi_token>";
	$xmlData .= "<csapi_role>"			. $aUser->getUserRole()		. "</csapi_role>";
	$xmlData .= "<csapi_database>"		. $aUser->getUserDatabase() . "</csapi_database>";
	$xmlData .= "<csapi_user>"			. $aUser->getUserName()		. "</csapi_user>";
	$xmlData .= "<csapi_template_flag>"	. $templateName . "</csapi_template_flag>";
	$xmlData .= "<csapi_action_flag>"	. $templateType . "</csapi_action_flag>";

	return (new ChangeSynergy::apiData(ChangeSynergy::util::callCsapi($aUser, $xmlData, $self->getConnectionUrl())));
}

sub LoadFormUrl
{
	my $self		 = shift;
	my $aUser		 = shift;
	my $templateName = shift;
	my $templateType = shift;
	my $retData		 = "";

	if(!defined($aUser))
	{
		die "User information object is undef";
	}

	$retData .= $self->getConnectionUrl();
	$retData .= "/servlet/PTweb";
	$retData .= "?ACTION_FLAG=";
	$retData .= ChangeSynergy::util::escape($templateType);
	$retData .= "&TEMPLATE_FLAG=";
	$retData .= ChangeSynergy::util::escape($templateName);
	$retData .= "&user=";
	$retData .= ChangeSynergy::util::escape($aUser->getUserName());
	$retData .= "&token=";
	$retData .= ChangeSynergy::util::escape($aUser->getUserToken());
	$retData .= "&role=";
	$retData .= ChangeSynergy::util::escape($aUser->getUserRole());
	$retData .= "&database=";
	$retData .= ChangeSynergy::util::escape($aUser->getUserDatabase());

	return (new ChangeSynergy::apiData($retData));
}

####################################################################
## Query and Report
####################################################################

sub QueryHtml
{
	my $self		 = shift;
	my $aUser		 = shift;
	my $reportName	 = shift;
	my $queryString	 = shift;
	my $queryName	 = shift;
	my $reportTitle	 = shift;
	my $templateName = shift;

	if(!defined($aUser))
	{
		die "User information object is undef";
	}

	return(ChangeSynergy::util::QueryHtmlBase($aUser, "query", $reportName, $queryString, $queryName, $reportTitle,
					     $templateName, undef, $self->getConnectionUrl(), $self->getReportConfigType(), $self->getQueryConfigType()));
}

sub QueryData
{
	my $self			= shift;
	my $aUser			= shift;
	my $reportName		= shift;
	my $queryString		= shift;
	my $queryName		= shift;
	my $reportTitle		= shift;
	my $templateName	= shift;
	my $attributeList	= shift;

	if(!defined($aUser))
	{
		die "User information object is undef";
	}

	if(!defined($attributeList))
	{
		return(new ChangeSynergy::apiQueryData(ChangeSynergy::util::QueryHtmlBaseStr($aUser, "data_report", $reportName, $queryString, $queryName, 
							$reportTitle, $templateName, undef, $self->getConnectionUrl(), $self->getReportConfigType(), $self->getQueryConfigType())));
	}
	else
	{
		return(new ChangeSynergy::apiQueryData(ChangeSynergy::util::QueryHtmlBaseStr($aUser, "data_report", $reportName, $queryString, $queryName,
			$reportTitle, $templateName, $attributeList, $self->getConnectionUrl(), $self->getReportConfigType(), $self->getQueryConfigType())));
	}
}

sub QueryStringData
{
	my $self		 = shift;
	my $aUser		 = shift;
	my $reportName	 = shift;
	my $queryString	 = shift;
	my $attributeList = shift;

	if(!defined($aUser))
	{
		die "User information object is undef";
	}

	return(new ChangeSynergy::apiQueryData(ChangeSynergy::util::QueryHtmlBaseStr($aUser, "data_report", $reportName, $queryString, undef, undef, undef, $attributeList, $self->getConnectionUrl(), $self->getReportConfigType(), $self->getQueryConfigType())));
}

sub QueryNameData
{
	my $self		 = shift;
	my $aUser		 = shift;
	my $reportName	 = shift;
	my $queryName	 = shift;
	my $attributeList = shift;

	if(!defined($aUser))
	{
		die "User information object is undef";
	}

	return(new ChangeSynergy::apiQueryData(ChangeSynergy::util::QueryHtmlBaseStr($aUser, "data_report", $reportName, undef, $queryName, undef, undef, $attributeList, $self->getConnectionUrl(), $self->getReportConfigType(), $self->getQueryConfigType())));
}

sub ImmediateQueryHtml
{
	my $self		 = shift;
	my $aUser		 = shift;
	my $reportName	 = shift;
	my $queryString	 = shift;
	my $queryName	 = shift;
	my $reportTitle	 = shift;

	if(!defined($aUser))
	{
		die "User information object is undef";
	}

	return(ChangeSynergy::util::QueryHtmlBase($aUser, "immediate_report", $reportName, $queryString, $queryName, $reportTitle, undef, undef, $self->getConnectionUrl(), $self->getReportConfigType(), $self->getQueryConfigType()));
}

sub ReportHtml
{
	my $self		 = shift;
	my $aUser		 = shift;
	my $reportName	 = shift;
	my $reportTitle  = shift;
	my $templateName = shift;

	if(!defined($aUser))
	{
		die "User information object is undef";
	}

	return(ChangeSynergy::util::QueryHtmlBase($aUser, "report", $reportName, undef, undef, $reportTitle, $templateName, undef, $self->getConnectionUrl(), $self->getReportConfigType(), $self->getQueryConfigType()));
}

sub ReportData
{
	my $self		 = shift;

	if(@_ == 3)
	{
		my $aUser			= shift;
		my $reportName		= shift;
		my $attributeList	= shift;

		if(!defined($aUser))
		{
			die "User information object is undef";
		}

		return(new ChangeSynergy::apiQueryData(ChangeSynergy::util::QueryHtmlBaseStr($aUser, "data_report", $reportName,  undef, undef, undef, undef, $attributeList, $self->getConnectionUrl(), $self->getReportConfigType(), $self->getQueryConfigType())));
	}
	elsif(@_ >= 4)
	{
		my $aUser		 = shift;
		my $reportName	 = shift;
		my $reportTitle  = shift;
		my $templateName = shift;
		my $attributeList	= shift;

		if(!defined($aUser))
		{
			die "User information object is undef";
		}

		if(!defined($attributeList))
		{
			return(new ChangeSynergy::apiQueryData(ChangeSynergy::util::QueryHtmlBaseStr($aUser, "data_report", $reportName, undef, undef, $reportTitle, $templateName, undef, $self->getConnectionUrl(), $self->getReportConfigType(), $self->getQueryConfigType())));
		}
		else
		{
			return(new ChangeSynergy::apiQueryData(ChangeSynergy::util::QueryHtmlBaseStr($aUser, "data_report", $reportName, undef, undef, $reportTitle, $templateName, $attributeList, $self->getConnectionUrl(), $self->getReportConfigType(), $self->getQueryConfigType())));
		}
	}
}

sub ImmediateReportHtml
{
	my $self		 = shift;
	my $aUser		 = shift;
	my $reportName	 = shift;
	my $reportTitle	 = shift;

	if(!defined($aUser))
	{
		die "User information object is undef";
	}

	return(ChangeSynergy::util::QueryHtmlBase($aUser, "immediate_report", $reportName, undef, undef, $reportTitle, undef, undef, $self->getConnectionUrl(), $self->getReportConfigType(), $self->getQueryConfigType()));
}

sub ReportOnCRHtml
{
	my $self			= shift;
	my $aUser			= shift;
	my $problemNumber	= shift;
	my $reportName		= shift;
	my $reportTitle		= shift;
	
	if(!defined($aUser))
	{
		die "User information object is undef";
	}

	return(ChangeSynergy::util::QueryHtmlBase($aUser, "problemreport", $reportName, "problem_number='" . $problemNumber ."'", undef, $reportTitle, undef, undef, $self->getConnectionUrl(), $self->getReportConfigType(), $self->getQueryConfigType()));
}

sub ReportOnCRData
{
	my $self			= shift;
	my $aUser			= shift;
	my $problemNumber	= shift;
	my $reportName		= shift;
	my $reportTitle		= shift;
	my $attributeList	= shift;
	
	if(!defined($aUser))
	{
		die "User information object is undef";
	}

	if(!defined($attributeList))
	{
		return(new ChangeSynergy::apiQueryData(ChangeSynergy::util::QueryHtmlBaseStr($aUser, "data_report", $reportName, "problem_number='" . $problemNumber ."'", undef, $reportTitle, undef, undef, $self->getConnectionUrl(), $self->getReportConfigType(), $self->getQueryConfigType())));
	}
	else
	{
		return(new ChangeSynergy::apiQueryData(ChangeSynergy::util::QueryHtmlBaseStr($aUser, "data_report", $reportName, "problem_number='" . $problemNumber ."'", undef, $reportTitle, undef, $attributeList, $self->getConnectionUrl(), $self->getReportConfigType(), $self->getQueryConfigType())));
	}
}

sub ReportOnTaskHtml
{
	my $self			= shift;
	my $aUser			= shift;
	my $taskNumber		= shift;
	my $reportName		= shift;
	my $reportTitle		= shift;
	
	if(!defined($aUser))
	{
		die "User information object is undef";
	}

	return(ChangeSynergy::util::QueryHtmlBase($aUser, "taskreport", $reportName, "task_number='" . $taskNumber ."'", undef, $reportTitle, undef, undef, $self->getConnectionUrl(), $self->getReportConfigType(), $self->getQueryConfigType()));
}

sub ReportOnTaskData
{
	my $self			= shift;
	my $aUser			= shift;
	my $taskNumber		= shift;
	my $reportName		= shift;
	my $reportTitle		= shift;
	my $attributeList	= shift;
	
	if(!defined($aUser))
	{
		die "User information object is undef";
	}
	
	#if logged in database is central cr database, this operation should fail.
	ChangeSynergy::util::checkLoggedinDatabase($aUser, 'ReportOnTaskData', $self->getConnectionUrl());
	
	if(!defined($attributeList))
	{
		return(new ChangeSynergy::apiQueryData(ChangeSynergy::util::QueryHtmlBaseStr($aUser, "data_report", $reportName, "task_number='" . $taskNumber ."'", undef, $reportTitle, undef, undef, $self->getConnectionUrl(), $self->getReportConfigType(), $self->getQueryConfigType())));
	}
	else
	{
		return(new ChangeSynergy::apiQueryData(ChangeSynergy::util::QueryHtmlBaseStr($aUser, "data_report", $reportName, "task_number='" . $taskNumber ."'", undef, $reportTitle, undef, $attributeList, $self->getConnectionUrl(), $self->getReportConfigType(), $self->getQueryConfigType())));
	}
}

sub ReportOnObjectHtml
{
	my $self			= shift;
	my $aUser			= shift;
	my $objectId		= shift;
	my $reportName		= shift;
	my $reportTitle		= shift;
	
	if(!defined($aUser))
	{
		die "User information object is undef";
	}

	return(ChangeSynergy::util::QueryHtmlBase($aUser, "objectreport", $reportName, "cvid='" . $objectId ."'", undef, $reportTitle, undef, undef, $self->getConnectionUrl(), $self->getReportConfigType(), $self->getQueryConfigType()));
}

sub ReportOnObjectData
{
	my $self			= shift;
	my $aUser			= shift;
	my $objectId		= shift;
	my $reportName		= shift;
	my $reportTitle		= shift;
	my $attributeList	= shift;

	if(!defined($aUser))
	{
		die "User information object is undef";
	}
	
	#if logged in database is central cr database, this operation should fail.
	ChangeSynergy::util::checkLoggedinDatabase($aUser, 'ReportOnObjectData', $self->getConnectionUrl());

	if(!defined($attributeList))
	{
		return(new ChangeSynergy::apiQueryData(ChangeSynergy::util::QueryHtmlBaseStr($aUser, "data_report", $reportName, "cvid='" . $objectId ."'", undef, $reportTitle, undef, undef, $self->getConnectionUrl(), $self->getReportConfigType(), $self->getQueryConfigType())));
	}
	else
	{
		return(new ChangeSynergy::apiQueryData(ChangeSynergy::util::QueryHtmlBaseStr($aUser, "data_report", $reportName, "cvid='" . $objectId ."'", undef, $reportTitle, undef, $attributeList, $self->getConnectionUrl(), $self->getReportConfigType(), $self->getQueryConfigType())));
	}
}

####################################################################
## Framesets
####################################################################

sub LoadFrameSetHtml
{
	my $self			= shift;
	my $aUser			= shift;
	my $templateName	= shift;
	my $taskNumber		= shift;
	my $taskStatus		= shift;
	my $problemNumber	= shift;
	my $problemStatus	= shift;
	my $cvid			= shift;
	my $externalData	= shift;
	my $xmlData			= "";

	if(!defined($aUser))
	{
		die "User information object is undef";
	}

	$xmlData .= "<csapi_action_flag>frameset_form</csapi_action_flag>";
	$xmlData .= "<csapi_token>"			. $aUser->getUserToken()	. "</csapi_token>";
	$xmlData .= "<csapi_role>"			. $aUser->getUserRole()		. "</csapi_role>";
	$xmlData .= "<csapi_database>"		. $aUser->getUserDatabase() . "</csapi_database>";
	$xmlData .= "<csapi_user>"			. $aUser->getUserName()		. "</csapi_user>";
	$xmlData .= "<csapi_template_flag>"	. $templateName				. "</csapi_template_flag>";

	if(defined($taskNumber))
	{
		$xmlData .= "<csapi_task_id>" . $taskNumber . "</csapi_task_id>";
	}

	if(defined($taskStatus))
	{
		$xmlData .= "<csapi_task_status>" . $taskStatus . "</csapi_task_status>";
	}

	if(defined($problemNumber))
	{
		$xmlData .= "<csapi_cr_id>" . $problemNumber . "</csapi_cr_id>";
	}

	if(defined($problemStatus))
	{
		$xmlData .= "<csapi_cr_status>" . $problemStatus . "</csapi_cr_status>";
	}

	if(defined($cvid))
	{
		$xmlData .= "<csapi_object_id>" . $cvid . "</csapi_object_id>";
	}

	if(defined($externalData))
	{
		$xmlData .= "<csapi_external_data>" . $externalData . "</csapi_external_data>";
	}

	return(new ChangeSynergy::apiData(ChangeSynergy::util::callCsapi($aUser, $xmlData, $self->getConnectionUrl())));
}

sub LoadFrameSetUrl
{
	my $self			= shift;
	my $aUser			= shift;
	my $templateName	= shift;
	my $taskNumber		= shift;
	my $taskStatus		= shift;
	my $problemNumber	= shift;
	my $problemStatus	= shift;
	my $cvid			= shift;
	my $externalData	= shift;
	my $retData			= "";

	if(!defined($aUser))
	{
		die "User information object is undef";
	}

	$retData .= $self->getConnectionUrl();
	$retData .= "/servlet/PTweb";
	$retData .= "?ACTION_FLAG=frameset_form";
	$retData .= "&TEMPLATE_FLAG=";
	$retData .= ChangeSynergy::util::escape($templateName);
	$retData .= "&user=";
	$retData .= ChangeSynergy::util::escape($aUser->getUserName());
	$retData .= "&token=";
	$retData .= ChangeSynergy::util::escape($aUser->getUserToken());
	$retData .= "&role=";
	$retData .= ChangeSynergy::util::escape($aUser->getUserRole());
	$retData .= "&database=";
	$retData .= ChangeSynergy::util::escape($aUser->getUserDatabase());

	if(defined($taskNumber))
	{
		$retData .= "&task_number=";
		$retData .= ChangeSynergy::util::escape($taskNumber);
	}

	if(defined($taskStatus))
	{
		$retData .= "&status=";
		$retData .= ChangeSynergy::util::escape($taskStatus);
	}

	if(defined($problemNumber))
	{
		$retData .= "&problem_number=";
		$retData .= ChangeSynergy::util::escape($problemNumber);
	}

	if(defined($problemStatus))
	{
		$retData .= "&crstatus=";
		$retData .= ChangeSynergy::util::escape($problemStatus);
	}

	if(defined($cvid))
	{
		$retData .= "&cvid=";
		$retData .= ChangeSynergy::util::escape($cvid);
	}

	if(defined($externalData))
	{
		$retData .= "&EXTERNAL_CONTEXT_DATA=";
		$retData .= ChangeSynergy::util::escape($externalData);
	}

	return(new ChangeSynergy::apiData($retData));
}

####################################################################
## Relation Create
####################################################################

sub CreateMiscObject
{
	my $self			= shift;
	my $aUser			= shift;
	my $objectString	= shift;
	my $xmlData			= "";

	if(!defined($aUser))
	{
		die "User information object is undef";
	}

	$xmlData .= "<csapi_action_flag>CreateMiscObject</csapi_action_flag>";
	$xmlData .= "<csapi_token>"			. $aUser->getUserToken()	. "</csapi_token>";
	$xmlData .= "<csapi_role>"			. $aUser->getUserRole()		. "</csapi_role>";
	$xmlData .= "<csapi_database>"		. $aUser->getUserDatabase() . "</csapi_database>";
	$xmlData .= "<csapi_user>"			. $aUser->getUserName()		. "</csapi_user>";
	$xmlData .= "<csapi_action_item>"	. $objectString				. "</csapi_action_item>";

	my $tmp = ChangeSynergy::util::callCsapi($aUser, $xmlData, $self->getConnectionUrl());
	my $iStart = index($tmp, $self->{globals}->{BGN_CSAPI_CVID});
	my $iEnd   = index($tmp, $self->{globals}->{END_CSAPI_CVID});

	if(($iStart < 0) || ($iEnd < 0))
	{
		die "Cannot parse CVID";
	}

	$iStart += length($self->{globals}->{BGN_CSAPI_CVID});

	if(($iStart == $iEnd) || ($iStart > $iEnd))
	{
		die "Cannot parse CVID";
	}

	return(new ChangeSynergy::apiData(substr($tmp, $iStart, $iEnd - $iStart)));
}

sub CreateRelation
{
	my $self				= shift;
	my $aUser				= shift;
	my $bothWayRelationship	= shift;
	my $fromObject			= shift;
	my $toObject			= shift;
	my $relationName		= shift;
	my $relationType		= shift;
	my $xmlData			= "";

	if(!defined($aUser))
	{
		die "User information object is undef";
	}

	$xmlData .= "<csapi_action_flag>CreateRelation</csapi_action_flag>";
	$xmlData .= "<csapi_token>"			. $aUser->getUserToken()	. "</csapi_token>";
	$xmlData .= "<csapi_role>"			. $aUser->getUserRole()		. "</csapi_role>";
	$xmlData .= "<csapi_database>"		. $aUser->getUserDatabase() . "</csapi_database>";
	$xmlData .= "<csapi_user>"			. $aUser->getUserName()		. "</csapi_user>";

	$xmlData .= "<csapi_relation_flag>"	. $relationName			. "</csapi_relation_flag>";
	$xmlData .= "<csapi_to_object>"		. $toObject				. "</csapi_to_object>";
	$xmlData .= "<csapi_from_object>"	. $fromObject			. "</csapi_from_object>";
	$xmlData .= "<csapi_relation_type>"	. $relationType			. "</csapi_relation_type>";

	if($bothWayRelationship eq "true")
	{
		$xmlData .= "<csapi_both_way_relationship>true</csapi_both_way_relationship>";
	}
	else
	{
		$xmlData .= "<csapi_both_way_relationship>false</csapi_both_way_relationship>";
	}

	return(new ChangeSynergy::apiData(ChangeSynergy::util::callCsapi($aUser, $xmlData, $self->getConnectionUrl())));
}

sub DeleteRelation
{
	my $self				= shift;
	my $aUser				= shift;
	my $bothWayRelationship	= shift;
	my $fromObject			= shift;
	my $toObject			= shift;
	my $relationName		= shift;
	my $relationType		= shift;
	my $xmlData			= "";

	if(!defined($aUser))
	{
		die "User information object is undef";
	}

	$xmlData .= "<csapi_action_flag>DeleteRelation</csapi_action_flag>";
	$xmlData .= "<csapi_token>"			. $aUser->getUserToken()	. "</csapi_token>";
	$xmlData .= "<csapi_role>"			. $aUser->getUserRole()		. "</csapi_role>";
	$xmlData .= "<csapi_database>"		. $aUser->getUserDatabase() . "</csapi_database>";
	$xmlData .= "<csapi_user>"			. $aUser->getUserName()		. "</csapi_user>";

	$xmlData .= "<csapi_relation_flag>"	. $relationName			. "</csapi_relation_flag>";
	$xmlData .= "<csapi_to_object>"		. $toObject				. "</csapi_to_object>";
	$xmlData .= "<csapi_from_object>"	. $fromObject			. "</csapi_from_object>";
	$xmlData .= "<csapi_relation_type>"	. $relationType			. "</csapi_relation_type>";

	if($bothWayRelationship eq "true")
	{
		$xmlData .= "<csapi_both_way_relationship>true</csapi_both_way_relationship>";
	}
	else
	{
		$xmlData .= "<csapi_both_way_relationship>false</csapi_both_way_relationship>";
	}

	return(new ChangeSynergy::apiData(ChangeSynergy::util::callCsapi($aUser, $xmlData, $self->getConnectionUrl())));
}

####################################################################
## Change Requests
####################################################################

sub ModifyCR
{
	my $self	= shift;
	my $aUser	= shift;
	my $lpData	= shift;

	if(!defined($aUser))
	{
		die "User information object is undef";
	}

	return(new ChangeSynergy::apiData(ChangeSynergy::util::ModifyShowAction($aUser, $lpData, "CRModify", $self->getConnectionUrl())));
}

sub TransitionCR
{
	my $self	= shift;
	my $aUser	= shift;
	my $lpData	= shift;

	if(!defined($aUser))
	{
		die "User information object is undef";
	}

	return(new ChangeSynergy::apiData(ChangeSynergy::util::ModifyShowAction($aUser, $lpData, "CRTransition", $self->getConnectionUrl())));
}

sub SubmitCR
{
	my $self	= shift;
	my $aUser	= shift;
	my $lpData	= shift;

	return(new ChangeSynergy::apiData(ChangeSynergy::util::ModifySubmitAction($aUser, $lpData, "CRSubmit", $self->getConnectionUrl())));
}

sub SubmitCRAssocCR
{
	my $self			= shift;
	my $aUser			= shift;
	my $lpData			= shift;
	my $relationName	= shift;
	my $problemNumber	= shift;
	
	return(new ChangeSynergy::apiData(ChangeSynergy::util::ModifySubmitAssocAction($aUser, $lpData, "CRSubmitCRAssoc", $relationName, $problemNumber, $self->getConnectionUrl())));
}

sub AttributeModifyCRData
{
	my $self			= shift;
	my $aUser			= shift;
	my $problem_number	= shift;
	my $attributeName	= shift;
	my $xmlData			= "";

	if(!defined($aUser))
	{
		die "User information object is undef";
	}

	if(!defined($attributeName))
	{
		$attributeName = "crstatus";
	}

	$xmlData .= "<csapi_action_flag>PreCRAttrModify</csapi_action_flag>";
	$xmlData .= "<csapi_all_transitions>false</csapi_all_transitions>";
	$xmlData .= "<csapi_template_flag>" . $attributeName			. "</csapi_template_flag>";
	$xmlData .= "<csapi_token>"			. $aUser->getUserToken()	. "</csapi_token>";
	$xmlData .= "<csapi_role>"			. $aUser->getUserRole()		. "</csapi_role>";
	$xmlData .= "<csapi_database>"		. $aUser->getUserDatabase() . "</csapi_database>";
	$xmlData .= "<csapi_user>"			. $aUser->getUserName()		. "</csapi_user>";	
	$xmlData .= "<csapi_cr_id>"			. $problem_number			. "</csapi_cr_id>";

	return(new ChangeSynergy::apiObjectVector(ChangeSynergy::util::callCsapi($aUser, $xmlData, $self->getConnectionUrl())));
}

sub AttributeModifyCRDataAllTransitions
{
	my $self          = shift;
	my $aUser = shift;
	my $ProblemNumber = shift;
	my $AttributeName = shift;

	if(!defined($aUser))
	{
		die "User information object is undef";
	}

	if(!defined($AttributeName))
	{
		$AttributeName = "crstatus";
	}

	my $xmlData = "";
	
	$xmlData .= "<csapi_action_flag>PreCRAttrModify</csapi_action_flag>";
	$xmlData .= "<csapi_all_transitions>true</csapi_all_transitions>";
	$xmlData .= "<csapi_template_flag>" . $AttributeName			           . "</csapi_template_flag>";
	$xmlData .= "<csapi_token>"         . $aUser->getUserToken()		       . "</csapi_token>";
	$xmlData .= "<csapi_role>"          . $aUser->getUserRole()				   . "</csapi_role>";
	$xmlData .= "<csapi_database>"      . $aUser->getUserDatabase()			   . "</csapi_database>";
	$xmlData .= "<csapi_user>"          . $aUser->getUserName()			       . "</csapi_user>";
	$xmlData .= "<csapi_cr_id>"         . $ProblemNumber					   . "</csapi_cr_id>";

	return(new ChangeSynergy::apiObjectVector(ChangeSynergy::util::callCsapi($aUser, $xmlData, $self->getConnectionUrl())));
}

sub ModifyCRData
{
	my $self			= shift;
	my $aUser			= shift;
	my $problem_number	= shift;
	my $templateName	= shift;
	my $xmlData			= "";

	if(!defined($aUser))
	{
		die "User information object is undef";
	}

	$xmlData .= "<csapi_action_flag>PreCRModify</csapi_action_flag>";
	$xmlData .= "<csapi_all_transitions>false</csapi_all_transitions>";
	$xmlData .= "<csapi_template_flag>" . $templateName				. "</csapi_template_flag>";
	$xmlData .= "<csapi_token>"			. $aUser->getUserToken()	. "</csapi_token>";
	$xmlData .= "<csapi_role>"			. $aUser->getUserRole()		. "</csapi_role>";
	$xmlData .= "<csapi_database>"		. $aUser->getUserDatabase() . "</csapi_database>";
	$xmlData .= "<csapi_user>"			. $aUser->getUserName()		. "</csapi_user>";	
	$xmlData .= "<csapi_cr_id>"			. $problem_number			. "</csapi_cr_id>";

	return(new ChangeSynergy::apiObjectVector(ChangeSynergy::util::callCsapi($aUser, $xmlData, $self->getConnectionUrl())));
}

sub ModifyCRDataAllTransitions
{
	my $self          = shift;
	my $aUser = shift;
	my $ProblemNumber = shift;
	my $TemplateName = shift;

	if(!defined($aUser))
	{
		die "User information object is undef";
	}


	my $xmlData = "";
	
	$xmlData .= "<csapi_action_flag>PreCRModify</csapi_action_flag>";
	$xmlData .= "<csapi_all_transitions>true</csapi_all_transitions>";
	$xmlData .= "<csapi_template_flag>" . $TemplateName				   . "</csapi_template_flag>";
	$xmlData .= "<csapi_token>"         . $aUser->getUserToken()       . "</csapi_token>";
	$xmlData .= "<csapi_role>"          . $aUser->getUserRole()        . "</csapi_role>";
	$xmlData .= "<csapi_database>"      . $aUser->getUserDatabase()    . "</csapi_database>";
	$xmlData .= "<csapi_user>"          . $aUser->getUserName()        . "</csapi_user>";
	$xmlData .= "<csapi_cr_id>"         . $ProblemNumber               . "</csapi_cr_id>";

	return(new ChangeSynergy::apiObjectVector(ChangeSynergy::util::callCsapi($aUser, $xmlData, $self->getConnectionUrl())));
}

sub GetCRData
{
	my $self			= shift;
	my $aUser			= shift;
	my $problem_number	= shift;
	my $attributeList	= shift;
	my $xmlData			= "";

	if(!defined($aUser))
	{
		die "User information object is undef";
	}

	$xmlData .= "<csapi_action_flag>PreCRModify</csapi_action_flag>";
	$xmlData .= "<csapi_all_transitions>false</csapi_all_transitions>";
	$xmlData .= "<csapi_attribute_flag>"	. $attributeList				. "</csapi_attribute_flag>";
	$xmlData .= "<csapi_token>"				. $aUser->getUserToken()	. "</csapi_token>";
	$xmlData .= "<csapi_role>"				. $aUser->getUserRole()		. "</csapi_role>";
	$xmlData .= "<csapi_database>"			. $aUser->getUserDatabase() . "</csapi_database>";
	$xmlData .= "<csapi_user>"				. $aUser->getUserName()		. "</csapi_user>";	
	$xmlData .= "<csapi_cr_id>"				. $problem_number			. "</csapi_cr_id>";

	return(new ChangeSynergy::apiObjectVector(ChangeSynergy::util::callCsapi($aUser, $xmlData, $self->getConnectionUrl())));
}

sub GetCRDataAllTransitions
{
	my $self          = shift;
	my $aUser		  = shift;
	my $ProblemNumber = shift;
	my $AttributeList = shift;

	if(!defined($aUser))
	{
		die "User information object is undef";
	}

	my $xmlData = "";
	
	$xmlData .= "<csapi_action_flag>PreCRModify</csapi_action_flag>";
	$xmlData .= "<csapi_all_transitions>true</csapi_all_transitions>";
	$xmlData .= "<csapi_attribute_flag>". $AttributeList           . "</csapi_attribute_flag>";
	$xmlData .= "<csapi_token>"         . $aUser->getUserToken()       . "</csapi_token>";
	$xmlData .= "<csapi_role>"          . $aUser->getUserRole()        . "</csapi_role>";
	$xmlData .= "<csapi_database>"      . $aUser->getUserDatabase()    . "</csapi_database>";
	$xmlData .= "<csapi_user>"          . $aUser->getUserName()        . "</csapi_user>";
	$xmlData .= "<csapi_cr_id>"         . $ProblemNumber           . "</csapi_cr_id>";

	return(new ChangeSynergy::apiObjectVector(ChangeSynergy::util::callCsapi($aUser, $xmlData, $self->getConnectionUrl())));
}



sub TransitionCRData
{
	my $self			= shift;
	my $aUser			= shift;
	my $problem_number	= shift;
	my $templateName	= shift;
	my $xmlData			= "";

	if(!defined($aUser))
	{
		die "User information object is undef";
	}

	$xmlData .= "<csapi_action_flag>PreCRTransition</csapi_action_flag>";
	$xmlData .= "<csapi_template_flag>"  . $templateName				. "</csapi_template_flag>";
	$xmlData .= "<csapi_token>"				. $aUser->getUserToken()	. "</csapi_token>";
	$xmlData .= "<csapi_role>"				. $aUser->getUserRole()		. "</csapi_role>";
	$xmlData .= "<csapi_database>"			. $aUser->getUserDatabase() . "</csapi_database>";
	$xmlData .= "<csapi_user>"				. $aUser->getUserName()		. "</csapi_user>";
	$xmlData .= "<csapi_cr_id>"				. $problem_number			. "</csapi_cr_id>";

	return(new ChangeSynergy::apiObjectVector(ChangeSynergy::util::callCsapi($aUser, $xmlData, $self->getConnectionUrl())));
}

sub CopyCRData
{
	my $self			= shift;
	my $aUser			= shift;
	my $problemNumber	= shift;
	my $templateName	= shift;
	my $xmlData			= "";

	if(!defined($aUser))
	{
		die "User information object is undef";
	}

	$xmlData .= "<csapi_action_flag>PreCRCopy</csapi_action_flag>";
	$xmlData .= "<csapi_template_flag>"	. $templateName				. "</csapi_template_flag>";
	$xmlData .= "<csapi_token>"			. $aUser->getUserToken()	. "</csapi_token>";
	$xmlData .= "<csapi_role>"			. $aUser->getUserRole()		. "</csapi_role>";
	$xmlData .= "<csapi_database>"		. $aUser->getUserDatabase() . "</csapi_database>";
	$xmlData .= "<csapi_user>"			. $aUser->getUserName()		. "</csapi_user>";
	$xmlData .= "<csapi_cr_id>"			. $problemNumber			. "</csapi_cr_id>";

	return(new ChangeSynergy::apiObjectVector(ChangeSynergy::util::callCsapi($aUser, $xmlData, $self->getConnectionUrl())));
}

sub SubmitCRData
{
	my $self			= shift;
	my $aUser			= shift;
	my $templateName	= shift;
	my $xmlData			= "";

	if(!defined($aUser))
	{
		die "User information object is undef";
	}

	$xmlData .= "<csapi_action_flag>PreCRSubmit</csapi_action_flag>";
	$xmlData .= "<csapi_template_flag>"	. $templateName				. "</csapi_template_flag>";
	$xmlData .= "<csapi_token>"			. $aUser->getUserToken()	. "</csapi_token>";
	$xmlData .= "<csapi_role>"			. $aUser->getUserRole()		. "</csapi_role>";
	$xmlData .= "<csapi_database>"		. $aUser->getUserDatabase() . "</csapi_database>";
	$xmlData .= "<csapi_user>"			. $aUser->getUserName()		. "</csapi_user>";

	return(new ChangeSynergy::apiObjectVector(ChangeSynergy::util::callCsapi($aUser, $xmlData, $self->getConnectionUrl())));
}

sub SubmitCRHtml
{
	my $self			= shift;
	my $aUser			= shift;
	my $templateName	= shift;
	my $problemNumber   = shift;
	my $relationName	= shift;
	my $externalData	= shift;
	my $xmlData			= "";

	if(!defined($aUser))
	{
		die "User information object is undef";
	}

	$xmlData .= "<csapi_action_flag>problem_submit_form</csapi_action_flag>";
	$xmlData .= "<csapi_token>"			. $aUser->getUserToken()	. "</csapi_token>";
	$xmlData .= "<csapi_role>"			. $aUser->getUserRole()		. "</csapi_role>";
	$xmlData .= "<csapi_database>"		. $aUser->getUserDatabase() . "</csapi_database>";
	$xmlData .= "<csapi_user>"			. $aUser->getUserName()		. "</csapi_user>";
	$xmlData .= "<csapi_template_flag>"	. $templateName				. "</csapi_template_flag>";

	if(defined($problemNumber))
	{
		$xmlData .= "<csapi_cr_id>" . $problemNumber . "</csapi_cr_id>";
	}

	if(defined($relationName))
	{
		$xmlData .= "<csapi_relation_flag>" . $relationName . "</csapi_relation_flag>";
	}

	if(defined($externalData))
	{
		$xmlData .= "<csapi_external_data>" . $externalData . "</csapi_external_data>";
	}

	return(new ChangeSynergy::apiData(ChangeSynergy::util::callCsapi($aUser, $xmlData, $self->getConnectionUrl())));
}

sub SubmitCRUrl
{
	my $self			= shift;
	my $aUser			= shift;
	my $templateName	= shift;
	my $problemNumber   = shift;
	my $relationName	= shift;
	my $externalData	= shift;
	my $retData			= "";

	if(!defined($aUser))
	{
		die "User information object is undef";
	}

	$retData .= $self->getConnectionUrl();
	$retData .= "/servlet/PTweb";
	$retData .= "?ACTION_FLAG=problem_submit_form";
	$retData .= "&TEMPLATE_FLAG=";
	$retData .= ChangeSynergy::util::escape($templateName);
	$retData .= "&user=";
	$retData .= ChangeSynergy::util::escape($aUser->getUserName());
	$retData .= "&token=";
	$retData .= ChangeSynergy::util::escape($aUser->getUserToken());
	$retData .= "&role=";
	$retData .= ChangeSynergy::util::escape($aUser->getUserRole());
	$retData .= "&database=";
	$retData .= ChangeSynergy::util::escape($aUser->getUserDatabase());

	if(defined($problemNumber))
	{
		$retData .= "&problem_number=";
		$retData .=  ChangeSynergy::util::escape($problemNumber);
	}

	if(defined($relationName))
	{
		$retData .= "&RELATION_NAME=";
		$retData .=  ChangeSynergy::util::escape($relationName);
	}

	if(defined($externalData))
	{
		$retData .= "&EXTERNAL_CONTEXT_DATA=";
		$retData .=  ChangeSynergy::util::escape($externalData);
	}

	return(new ChangeSynergy::apiData($retData));
}

sub ShowCRHtml
{
	my $self			= shift;

	if(@_ == 4)
	{
		my $aUser			= shift;
		my $problemNumber	= shift;
		my $relationName	= shift;
		my $isModifiable	= shift;
		my $xmlData			= "";	

		if(!defined($aUser))
		{
			die "User information object is undef";
		}

		$xmlData .= "<csapi_action_flag>problem_attr_show_form</csapi_action_flag>";
		$xmlData .= "<csapi_template_flag>crstatus</csapi_template_flag>";
		$xmlData .= "<csapi_token>"			. $aUser->getUserToken()	. "</csapi_token>";
		$xmlData .= "<csapi_role>"			. $aUser->getUserRole()		. "</csapi_role>";
		$xmlData .= "<csapi_database>"		. $aUser->getUserDatabase() . "</csapi_database>";
		$xmlData .= "<csapi_user>"			. $aUser->getUserName()		. "</csapi_user>";

		if(defined($problemNumber))
		{
			$xmlData .= "<csapi_cr_id>" . $problemNumber . "</csapi_cr_id>";
		}

		if(defined($isModifiable))
		{
			$xmlData .= "<csapi_is_modifiable>" . $isModifiable . "</csapi_is_modifiable>";
		}

		return(new ChangeSynergy::apiData(ChangeSynergy::util::callCsapi($aUser, $xmlData, $self->getConnectionUrl())));
	}
	else
	{
		my $aUser			= shift;
		my $problemNumber	= shift;
		my $templateName	= shift;
		my $relationName	= shift;
		my $isModifiable	= shift;
		my $xmlData			= "";

		if(!defined($aUser))
		{
			die "User information object is undef";
		}

		$xmlData .= "<csapi_action_flag>problem_show_form</csapi_action_flag>";
		$xmlData .= "<csapi_token>"			. $aUser->getUserToken()	. "</csapi_token>";
		$xmlData .= "<csapi_role>"			. $aUser->getUserRole()		. "</csapi_role>";
		$xmlData .= "<csapi_database>"		. $aUser->getUserDatabase() . "</csapi_database>";
		$xmlData .= "<csapi_user>"			. $aUser->getUserName()		. "</csapi_user>";
		$xmlData .= "<csapi_template_flag>"	. $templateName				. "</csapi_template_flag>";
		$xmlData .= "<csapi_cr_id>"			. $problemNumber			. "</csapi_cr_id>";

		if(defined($relationName))
		{
			$xmlData .= "<csapi_relation_flag>" . $relationName . "</csapi_relation_flag>";
		}

		if(defined($isModifiable))
		{
			$xmlData .= "<csapi_is_modifiable>" . $isModifiable . "</csapi_is_modifiable>";
		}

		return(new ChangeSynergy::apiData(ChangeSynergy::util::callCsapi($aUser, $xmlData, $self->getConnectionUrl())));
	}
}

sub ShowCRUrl
{
	my $self			= shift;

	if(@_ == 4)
	{
		my $aUser			= shift;
		my $problemNumber	= shift;
		my $relationName	= shift;
		my $isModifiable	= shift;
		my $retData			= "";	

		if(!defined($aUser))
		{
			die "User information object is undef";
		}

		$retData .= $self->getConnectionUrl();
		$retData .= "/servlet/PTweb";
		$retData .= "?ACTION_FLAG=problem_attr_show_form";
		$retData .= "&TEMPLATE_FLAG=crstatus";
		$retData .= "&problem_number=";
		$retData .= ChangeSynergy::util::escape($problemNumber);
		$retData .= "&user=";
		$retData .= ChangeSynergy::util::escape($aUser->getUserName());
		$retData .= "&token=";
		$retData .= ChangeSynergy::util::escape($aUser->getUserToken());
		$retData .= "&role=";
		$retData .= ChangeSynergy::util::escape($aUser->getUserRole());
		$retData .= "&database=";
		$retData .= ChangeSynergy::util::escape($aUser->getUserDatabase());

		if(defined($relationName))
		{
			$retData .= "&RELATION_NAME=";
			$retData .= ChangeSynergy::util::escape($relationName);
		}

		if(defined($isModifiable))
		{
			$retData .= "&IS_MODIFIABLE=";
			$retData .= ChangeSynergy::util::escape($isModifiable);
		}

		return(new ChangeSynergy::apiData($retData));
	}
	else
	{
		my $aUser			= shift;
		my $problemNumber	= shift;
		my $templateName	= shift;
		my $relationName	= shift;
		my $isModifiable	= shift;
		my $retData			= "";	

		if(!defined($aUser))
		{
			die "User information object is undef";
		}

		$retData .= $self->getConnectionUrl();
		$retData .= "/servlet/PTweb";
		$retData .= "?ACTION_FLAG=problem_show_form";
		$retData .= "&TEMPLATE_FLAG=";
		$retData .= ChangeSynergy::util::escape($templateName);
		$retData .= "&problem_number=";
		$retData .= ChangeSynergy::util::escape($problemNumber);
		$retData .= "&user=";
		$retData .= ChangeSynergy::util::escape($aUser->getUserName());
		$retData .= "&token=";
		$retData .= ChangeSynergy::util::escape($aUser->getUserToken());
		$retData .= "&role=";
		$retData .= ChangeSynergy::util::escape($aUser->getUserRole());
		$retData .= "&database=";
		$retData .= ChangeSynergy::util::escape($aUser->getUserDatabase());

		if(defined($relationName))
		{
			$retData .= "&RELATION_NAME=";
			$retData .= ChangeSynergy::util::escape($relationName);
		}

		if(defined($isModifiable))
		{
			$retData .= "&IS_MODIFIABLE=";
			$retData .= ChangeSynergy::util::escape($isModifiable);
		}

		return(new ChangeSynergy::apiData($retData));
	}
}

####################################################################
## Tasks
####################################################################

sub ModifyTask
{
	my $self	= shift;
	my $aUser	= shift;
	my $lpData	= shift;

	if(!defined($aUser))
	{
		die "User information object is undef";
	}

	return(new ChangeSynergy::apiData(ChangeSynergy::util::ModifyShowAction($aUser, $lpData, "TaskModify", $self->getConnectionUrl())));
}

sub TransitionTask
{
	my $self	= shift;
	my $aUser	= shift;
	my $lpData	= shift;

	if(!defined($aUser))
	{
		die "User information object is undef";
	}

	return(new ChangeSynergy::apiData(ChangeSynergy::util::ModifyShowAction($aUser, $lpData, "TaskTransition", $self->getConnectionUrl())));
}

sub SubmitTask
{
	my $self	= shift;
	my $aUser	= shift;
	my $lpData	= shift;

	if(!defined($aUser))
	{
		die "User information object is undef";
	}

	return(new ChangeSynergy::apiData(ChangeSynergy::util::ModifySubmitAction($aUser, $lpData, "TaskSubmit", $self->getConnectionUrl())));
}

sub SubmitTaskAssocCR
{
	my $self			= shift;
	my $aUser			= shift;
	my $lpData			= shift;
	my $relationName	= shift;
	my $problemNumber	= shift;

	if(!defined($aUser))
	{
		die "User information object is undef";
	}

	return(new ChangeSynergy::apiData(ChangeSynergy::util::ModifySubmitAssocAction($aUser, $lpData, "TaskSubmitCRAssoc", $relationName, $problemNumber, $self->getConnectionUrl())));
}

sub ModifyTaskData
{
	my $self			= shift;
	my $aUser			= shift;
	my $taskNumber		= shift;
	my $templateName	= shift;
	my $xmlData			= shift;

	if(!defined($aUser))
	{
		die "User information object is undef";
	}

	$xmlData .= "<csapi_action_flag>PreTaskModify</csapi_action_flag>";
	$xmlData .= "<csapi_template_flag>"	. $templateName				. "</csapi_template_flag>";
	$xmlData .= "<csapi_token>"			. $aUser->getUserToken()	. "</csapi_token>";
	$xmlData .= "<csapi_role>"			. $aUser->getUserRole()		. "</csapi_role>";
	$xmlData .= "<csapi_database>"		. $aUser->getUserDatabase() . "</csapi_database>";
	$xmlData .= "<csapi_user>"			. $aUser->getUserName()		. "</csapi_user>";
	$xmlData .= "<csapi_task_id>"		. $taskNumber				. "</csapi_task_id>";

	return(new ChangeSynergy::apiObjectVector(ChangeSynergy::util::callCsapi($aUser, $xmlData, $self->getConnectionUrl())));
}

sub GetTaskData
{
	my $self			= shift;
	my $aUser			= shift;
	my $taskNumber		= shift;
	my $attributeList	= shift;
	my $xmlData			= shift;

	if(!defined($aUser))
	{
		die "User information object is undef";
	}

	$xmlData .= "<csapi_action_flag>PreTaskModify</csapi_action_flag>";
	$xmlData .= "<csapi_attribute_flag>"	. $attributeList			. "</csapi_attribute_flag>";
	$xmlData .= "<csapi_token>"				. $aUser->getUserToken()	. "</csapi_token>";
	$xmlData .= "<csapi_role>"				. $aUser->getUserRole()		. "</csapi_role>";
	$xmlData .= "<csapi_database>"			. $aUser->getUserDatabase() . "</csapi_database>";
	$xmlData .= "<csapi_user>"				. $aUser->getUserName()		. "</csapi_user>";
	$xmlData .= "<csapi_task_id>"			. $taskNumber				. "</csapi_task_id>";

	return(new ChangeSynergy::apiObjectVector(ChangeSynergy::util::callCsapi($aUser, $xmlData, $self->getConnectionUrl())));
}

sub TransitionTaskData
{
	my $self			= shift;
	my $aUser			= shift;
	my $taskNumber		= shift;
	my $templateName	= shift;
	my $xmlData			= shift;

	if(!defined($aUser))
	{
		die "User information object is undef";
	}

	$xmlData .= "<csapi_action_flag>PreTaskTransition</csapi_action_flag>";
	$xmlData .= "<csapi_template_flag>"		. $templateName				. "</csapi_template_flag>";
	$xmlData .= "<csapi_token>"				. $aUser->getUserToken()	. "</csapi_token>";
	$xmlData .= "<csapi_role>"				. $aUser->getUserRole()		. "</csapi_role>";
	$xmlData .= "<csapi_database>"			. $aUser->getUserDatabase() . "</csapi_database>";
	$xmlData .= "<csapi_user>"				. $aUser->getUserName()		. "</csapi_user>";
	$xmlData .= "<csapi_task_id>"			. $taskNumber				. "</csapi_task_id>";

	return(new ChangeSynergy::apiObjectVector(ChangeSynergy::util::callCsapi($aUser, $xmlData, $self->getConnectionUrl())));
}

sub CopyTaskData
{
	my $self			= shift;
	my $aUser			= shift;
	my $taskNumber		= shift;
	my $templateName	= shift;
	my $xmlData			= shift;

	if(!defined($aUser))
	{
		die "User information object is undef";
	}

	$xmlData .= "<csapi_action_flag>PreTaskCopy</csapi_action_flag>";
	$xmlData .= "<csapi_template_flag>"		. $templateName				. "</csapi_template_flag>";
	$xmlData .= "<csapi_token>"				. $aUser->getUserToken()	. "</csapi_token>";
	$xmlData .= "<csapi_role>"				. $aUser->getUserRole()		. "</csapi_role>";
	$xmlData .= "<csapi_database>"			. $aUser->getUserDatabase() . "</csapi_database>";
	$xmlData .= "<csapi_user>"				. $aUser->getUserName()		. "</csapi_user>";
	$xmlData .= "<csapi_task_id>"			. $taskNumber				. "</csapi_task_id>";

	return(new ChangeSynergy::apiObjectVector(ChangeSynergy::util::callCsapi($aUser, $xmlData, $self->getConnectionUrl())));
}

sub SubmitTaskData
{
	my $self			= shift;
	my $aUser			= shift;
	my $templateName	= shift;
	my $xmlData			= shift;

	if(!defined($aUser))
	{
		die "User information object is undef";
	}

	$xmlData .= "<csapi_action_flag>PreTaskSubmit</csapi_action_flag>";
	$xmlData .= "<csapi_template_flag>"		. $templateName				. "</csapi_template_flag>";
	$xmlData .= "<csapi_token>"				. $aUser->getUserToken()	. "</csapi_token>";
	$xmlData .= "<csapi_role>"				. $aUser->getUserRole()		. "</csapi_role>";
	$xmlData .= "<csapi_database>"			. $aUser->getUserDatabase() . "</csapi_database>";
	$xmlData .= "<csapi_user>"				. $aUser->getUserName()		. "</csapi_user>";

	return(new ChangeSynergy::apiObjectVector(ChangeSynergy::util::callCsapi($aUser, $xmlData, $self->getConnectionUrl())));
}

sub SubmitTaskHtml
{
	my $self			= shift;
	my $aUser			= shift;
	my $templateName	= shift;

	if(!defined($aUser))
	{
		die "User information object is undef";
	}

	return(&LoadFormHtml($self, $aUser, $templateName, "task_submit_form"));
}

sub SubmitTaskUrl
{
	my $self			= shift;
	my $aUser			= shift;
	my $templateName	= shift;

	if(!defined($aUser))
	{
		die "User information object is undef";
	}

	return(&LoadFormUrl($self, $aUser, $templateName, "task_submit_form"));
}

sub ShowTaskHtml
{
	my $self			= shift;

	if(@_ == 4)
	{
		my $aUser			= shift;
		my $taskNumber		= shift;
		my $relationName	= shift;
		my $isModifiable	= shift;
		my $xmlData			= shift;

		if(!defined($aUser))
		{
			die "User information object is undef";
		}

		$xmlData .= "<csapi_action_flag>task_attr_show_form</csapi_action_flag>";
		$xmlData .= "<csapi_template_flag>status</csapi_template_flag>";
		$xmlData .= "<csapi_token>"				. $aUser->getUserToken()	. "</csapi_token>";
		$xmlData .= "<csapi_role>"				. $aUser->getUserRole()		. "</csapi_role>";
		$xmlData .= "<csapi_database>"			. $aUser->getUserDatabase() . "</csapi_database>";
		$xmlData .= "<csapi_user>"				. $aUser->getUserName()		. "</csapi_user>";
		$xmlData .= "<csapi_task_id>"			. $taskNumber				. "</csapi_task_id>";

		if(defined($relationName))
		{
			$xmlData .= "<csapi_relation_flag>"	. $relationName	. "</csapi_relation_flag>";
		}

		if(defined($isModifiable))
		{
			$xmlData .= "<csapi_is_modifiable>"	. $isModifiable	. "</csapi_is_modifiable>";
		}

		return(new ChangeSynergy::apiData(ChangeSynergy::util::callCsapi($aUser, $xmlData, $self->getConnectionUrl())));
	}
	else
	{
		my $aUser			= shift;
		my $taskNumber		= shift;
		my $templateName	= shift;
		my $relationName	= shift;
		my $isModifiable	= shift;
		my $xmlData			= shift;

		if(!defined($aUser))
		{
			die "User information object is undef";
		}

		$xmlData .= "<csapi_action_flag>task_show_form</csapi_action_flag>";
		$xmlData .= "<csapi_template_flag>"     . $templateName				. "</csapi_template_flag>";
		$xmlData .= "<csapi_token>"				. $aUser->getUserToken()	. "</csapi_token>";
		$xmlData .= "<csapi_role>"				. $aUser->getUserRole()		. "</csapi_role>";
		$xmlData .= "<csapi_database>"			. $aUser->getUserDatabase() . "</csapi_database>";
		$xmlData .= "<csapi_user>"				. $aUser->getUserName()		. "</csapi_user>";
		$xmlData .= "<csapi_task_id>"			. $taskNumber				. "</csapi_task_id>";

		if(defined($relationName))
		{
			$xmlData .= "<csapi_relation_flag>"	. $relationName	. "</csapi_relation_flag>";
		}

		if(defined($isModifiable))
		{
			$xmlData .= "<csapi_is_modifiable>"	. $isModifiable	. "</csapi_is_modifiable>";
		}

		return(new ChangeSynergy::apiData(ChangeSynergy::util::callCsapi($aUser, $xmlData, $self->getConnectionUrl())));
	}
}

sub ShowTaskUrl
{
	my $self			= shift;

	if(@_ == 4)
	{
		my $aUser			= shift;
		my $taskNumber		= shift;
		my $relationName	= shift;
		my $isModifiable	= shift;
		my $retData			= shift;

		if(!defined($aUser))
		{
			die "User information object is undef";
		}

		$retData .= $self->getConnectionUrl();
		$retData .= "/servlet/PTweb";
		$retData .= "?ACTION_FLAG=task_attr_show_form";
		$retData .= "&TEMPLATE_FLAG=status";
		$retData .= "&task_number=";
		$retData .= ChangeSynergy::util::escape($taskNumber);
		$retData .= "&user=";
		$retData .= ChangeSynergy::util::escape($aUser->getUserName());
		$retData .= "&token=";
		$retData .= ChangeSynergy::util::escape($aUser->getUserToken());
		$retData .= "&role=";
		$retData .= ChangeSynergy::util::escape($aUser->getUserRole());
		$retData .= "&database=";
		$retData .= ChangeSynergy::util::escape($aUser->getUserDatabase());

		if(defined($relationName))
		{
			$retData .= "&RELATION_NAME=";
			$retData .= ChangeSynergy::util::escape($relationName);
		}

		if(defined($isModifiable))
		{
			$retData .= "&IS_MODIFIABLE=";
			$retData .= ChangeSynergy::util::escape($isModifiable);
		}

		return(new ChangeSynergy::apiData($retData));
	}
	else
	{
		my $aUser			= shift;
		my $taskNumber		= shift;
		my $templateName	= shift;
		my $relationName	= shift;
		my $isModifiable	= shift;
		my $retData			= shift;

		if(!defined($aUser))
		{
			die "User information object is undef";
		}

		$retData .= $self->getConnectionUrl();
		$retData .= "/servlet/PTweb";
		$retData .= "?ACTION_FLAG=task_show_form";
		$retData .= "&TEMPLATE_FLAG=";
		$retData .= ChangeSynergy::util::escape($templateName);
		$retData .= "&task_number=";
		$retData .= ChangeSynergy::util::escape($taskNumber);
		$retData .= "&user=";
		$retData .= ChangeSynergy::util::escape($aUser->getUserName());
		$retData .= "&token=";
		$retData .= ChangeSynergy::util::escape($aUser->getUserToken());
		$retData .= "&role=";
		$retData .= ChangeSynergy::util::escape($aUser->getUserRole());
		$retData .= "&database=";
		$retData .= ChangeSynergy::util::escape($aUser->getUserDatabase());

		if(defined($relationName))
		{
			$retData .= "&RELATION_NAME=";
			$retData .= ChangeSynergy::util::escape($relationName);
		}

		if(defined($isModifiable))
		{
			$retData .= "&IS_MODIFIABLE=";
			$retData .= ChangeSynergy::util::escape($isModifiable);
		}

		return(new ChangeSynergy::apiData($retData));
	}
}

sub VerifySignatures
{
	my $self          = shift;
	my $aUser         = shift;
	my $problemNumber = shift;
	my $attributeName = shift;
	my $xmlData       = "";

	if(!defined($aUser))
	{
		die "User information object is undef";
	}
	
	$xmlData .= "<csapi_action_flag>verify_signatures</csapi_action_flag>";
	$xmlData .= "<csapi_token>"          . $aUser->getUserToken()    . "</csapi_token>";
	$xmlData .= "<csapi_role>"           . $aUser->getUserRole()     . "</csapi_role>";
	$xmlData .= "<csapi_database>"       . $aUser->getUserDatabase() . "</csapi_database>";
	$xmlData .= "<csapi_user>"           . $aUser->getUserName()     . "</csapi_user>";
	$xmlData .= "<csapi_cr_id>"          . $problemNumber            . "</csapi_cr_id>";
	$xmlData .= "<csapi_attribute_flag>" . $attributeName            . "</csapi_attribute_flag>";
	
	my $responseData = ChangeSynergy::util::callCsapi($aUser, $xmlData, $self->getConnectionUrl());

	return ($responseData);
}

sub DeleteChangeRequest
{
	my $self          = shift;
	my $aUser         = shift;
	my $problemNumber = shift;
	my $xmlData       = "";

	if(!defined($aUser))
	{
		die "User information object is undef";
	}

	$xmlData .= "<csapi_action_flag>delete_cr</csapi_action_flag>";
	$xmlData .= "<csapi_token>"    . $aUser->getUserToken()    . "</csapi_token>";
	$xmlData .= "<csapi_role>"     . $aUser->getUserRole()     . "</csapi_role>";
	$xmlData .= "<csapi_database>" . $aUser->getUserDatabase() . "</csapi_database>";
	$xmlData .= "<csapi_user>"     . $aUser->getUserName()     . "</csapi_user>";
	$xmlData .= "<csapi_cr_id>"    . $problemNumber            . "</csapi_cr_id>";

	return(new ChangeSynergy::apiData(ChangeSynergy::util::callCsapi($aUser, $xmlData, $self->getConnectionUrl())));
}

sub DeleteTask
{

	my $self          = shift;
	my $aUser         = shift;
	my $taskNumber = shift;
	my $xmlData       = "";

	if(!defined($aUser))
	{
		die "User information object is undef";
	}

	$xmlData .= "<csapi_action_flag>delete_task</csapi_action_flag>";
	$xmlData .= "<csapi_token>"    . $aUser->getUserToken()    . "</csapi_token>";
	$xmlData .= "<csapi_role>"     . $aUser->getUserRole()     . "</csapi_role>";
	$xmlData .= "<csapi_database>" . $aUser->getUserDatabase() . "</csapi_database>";
	$xmlData .= "<csapi_user>"     . $aUser->getUserName()     . "</csapi_user>";
	$xmlData .= "<csapi_task_id>"  . $taskNumber               . "</csapi_task_id>";

	return(new ChangeSynergy::apiData(ChangeSynergy::util::callCsapi($aUser, $xmlData, $self->getConnectionUrl())));
}

sub ChangeRequestFullName
{
	my $self            = shift;
	my $aUser			= shift;
	my $ProblemNumber	= shift;
	my $xmlData			= "";

	if(!defined($aUser))
	{
		die "User information object is undef";
	}

	$xmlData .= "<csapi_action_flag>GetCRFullName</csapi_action_flag>";
	$xmlData .= "<csapi_token>"    . $aUser->getUserToken()    . "</csapi_token>";
	$xmlData .= "<csapi_role>"     . $aUser->getUserRole()     . "</csapi_role>";
	$xmlData .= "<csapi_database>" . $aUser->getUserDatabase() . "</csapi_database>";
	$xmlData .= "<csapi_user>"     . $aUser->getUserName()     . "</csapi_user>";
	$xmlData .= "<csapi_cr_id>"    . $ProblemNumber        . "</csapi_cr_id>";

	return(new ChangeSynergy::apiData(ChangeSynergy::util::callCsapi($aUser, $xmlData, $self->getConnectionUrl())));
}

sub TaskFullName
{
	my $self        = shift;
	my $aUser		= shift;
	my $TaskNumber	= shift;
	my $xmlData		= "";

	if(!defined($aUser))
	{
		die "User information object is undef";
	}
	
	$xmlData .= "<csapi_action_flag>GetTaskFullName</csapi_action_flag>";

	$xmlData .= "<csapi_token>"    . $aUser->getUserToken()    . "</csapi_token>";
	$xmlData .= "<csapi_role>"     . $aUser->getUserRole()     . "</csapi_role>";
	$xmlData .= "<csapi_database>" . $aUser->getUserDatabase() . "</csapi_database>";
	$xmlData .= "<csapi_user>"     . $aUser->getUserName()     . "</csapi_user>";
	$xmlData .= "<csapi_task_id>"  . $TaskNumber           . "</csapi_task_id>";
	
	return(new ChangeSynergy::apiData(ChangeSynergy::util::callCsapi($aUser, $xmlData, $self->getConnectionUrl())));
}

sub CallBsfScript
{
	my $self = shift;
	my $aUser = shift;
	my $scriptName = shift;
	my $scriptData = shift;
	my $xmlData = "";

	if(!defined($aUser))
	{
		die "User information object is undef";
	}

	$xmlData .= "<csapi_action_flag>callScript</csapi_action_flag>";

	$xmlData .= "<csapi_token>" . $aUser->getUserToken() . "</csapi_token>";
	$xmlData .= "<csapi_role>" . $aUser->getUserRole() . "</csapi_role>";
	$xmlData .= "<csapi_database>" . $aUser->getUserDatabase() . "</csapi_database>";
	$xmlData .= "<csapi_user>" . $aUser->getUserName() . "</csapi_user>";
	$xmlData .= "<csapi_script_name>" . ChangeSynergy::util::xmlEncode($scriptName) . "</csapi_script_name>";
	$xmlData .= "<csapi_script_data>" . ChangeSynergy::util::xmlEncode($scriptData) . "</csapi_script_data>";

	return(new ChangeSynergy::apiData(ChangeSynergy::util::callCsapi($aUser, $xmlData, $self->getConnectionUrl())));
}

sub Logout
{
	my $self = shift;	
	my $aUser = shift;
	my $xmlData	= "";

	$xmlData .= "<csapi_action_flag>logout</csapi_action_flag>";
	$xmlData .= "<csapi_token>" . $aUser->getUserToken() . "</csapi_token>";

	return new ChangeSynergy::apiData(ChangeSynergy::util::callCsapi($aUser, $xmlData, $self->getConnectionUrl()));
}

sub SyncDatabase
{
	my $self = shift;	
	my $user = shift;
	my $task_database = shift;

	my $xml = "<csapi_action_flag>syncDatabase</csapi_action_flag>" .
		"<csapi_token>" . $user->getUserToken() . "</csapi_token>" .
		"<csapi_task_database>${task_database}</csapi_task_database>";

	return new ChangeSynergy::apiData(ChangeSynergy::util::callCsapi($user, $xml, $self->getConnectionUrl()));
}

##############################################################################
# Fix TDS such that all shared and admin defined preferences 
# are removed.  This is used to prepare the TDS server for
# migration.  Warning - this permanently removes all shared preferences, 
# formats, reports, and home pages.
#
# Parameters:
#	apiUser aUser: The current api user's login data.
# 
# Returns: apiData
#	the return message from the server.
#
# Example:
#
#	my $csapi = new ChangeSynergy::csapi();
#
#	eval
#	{
#		$csapi->setUpConnection("http://your_hostname:port/your_context");
#
#		my $aUser = $csapi->Login("u00001", "u00001", "User", "\\\\your_hostname\\ccmdb\\cm_database");
#
#		my $data = $csapi->FixTdsForMigration($aUser);
#	};
#
#	if ($@)
#	{
#		print $@;
#	}
##############################################################################

sub FixTdsForMigration
{
	my $self = shift;
	my $aUser = shift;
		
	return(ChangeSynergy::util::AdminAction($aUser, "FixTdsForMigration", $self->getConnectionUrl()));
}

1;

__END__

=head1 Name

ChangeSynergy::csapi

=head1 Description

The ChangeSynergy::csapi class is the class used to send and retrieve
information from the IBM Rational Change server.

=head1 Methods

The following methods are available:

=over 4

=cut

##############################################################################

=item B<new>

 sub new()

Initializes a newly created ChangeSynergy::csapi class.

 my $csapi = new ChangeSynergy::csapi();

=cut

##############################################################################

=item B<AddAPreferenceForAUser>

Add/Change a user preference and value for a user.  The value to be 
added or changed must already be defined as a user preference via one of 
the configuration files.  To edit or add a users cfg setting, the keyName
should be "_USER_CFG_" and the system will append the users name. 
The return result is an instance of the L<apiData> class.

Note: It is not possible to change or add user profile values.  These values
are the users first names, last names, email addresses, fax numbers, telephone
numbers and addresses.

 Parameters:
	apiUser aUser   : The current api user's login data.
	scalar  username: The name of the user's preferences to edit.
	scalar  keyName : The name of the preference to add.
	scalar  keyValue: The value for the preference being added.
	scalar  allDBs  : true or false, should the add take place for all databases
						or just the one that the current api user is logged into.

 Returns: apiData
	the return message from the server.
 
 Example:
	
	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "Admin", "\\\\your_hostname\\ccmdb\\cm_database");
		
		$tmpData = $csapi->AddAPreferenceForAUser($aUser, "u00001", "user_fontsize", "9", "true");
	
		print $tmpData->getResponseData();

	};

	if ($@)
	{
		print $@;
	}

=cut

#############################################################################


=item B<AddAPreferenceForAllUsers>

Add/Change a user preference and value for all users.  The value to be 
added or changed must already be defined as a user preference via one of 
the configuration files.  To edit or add a users cfg setting, the keyName
should be "_USER_CFG_" and the system will append the users name. 
The return result is an instance of the L<apiData> class.

Note: It is not possible to change or add user profile values.  These values
are the users first names, last names, email addresses, fax numbers, telephone
numbers and addresses.

 Parameters:
	apiUser aUser   : The current api user's login data.
	scalar  keyName : The name of the preference to add.
	scalar  keyValue: The value for the preference being added.
	scalar  allDBs  : true or false, should the add take place for all databases
						or just the one that the current api user is logged into.

 Returns: apiData
	the return message from the server.
 
 Example:
	
	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "Admin", "\\\\your_hostname\\ccmdb\\cm_database");
		
		$tmpData = $csapi->AddAPreferenceForAllUsers($aUser, "user_fontsize", "9", "true");
	
		print $tmpData->getResponseData();

	};

	if ($@)
	{
		print $@;
	}

=cut

#############################################################################

=item B<addFolder>

Adds a new empty query, report format or report folder to the server.
The return result is an instance of the L<apiData> class.

 Parameters:
	apiUser aUser     : The current api user's login data.
	scalar  folderName: The name of the folder to add.
	scalar  objectType: The object type for the folder.
	scalar  formatType: The format type of the folder: report, query or report format.
	scalar  configType: The configuration location for the report.

 Valid object types (Constants defiend in Globals.pm):
        PROBLEM_TYPE
        TASK_TYPE
        OBJECT_TYPE

 Valid format types (Constants defiend in Globals.pm):
 		QUERY
        REPORT
        REPORT_FORMAT
 
 Valid configuration types (Constants defiend in Globals.pm):
        SHARED_PROFILE
        SYSTEM_CONFIG
        USER_PROFILE
        
 Returns: apiData
	the return message from the server.
 
 Example:
	
	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "Admin", "\\\\machine\\ccmdb\\cm_database");
		
		my $globals = new ChangeSynergy::Globals();
		
		#Create a new shared CR Report folder called 'API Folder'.
		my $addResults = $csapi->addFolder($aUser, "API Folder", $globals->{PROBLEM_TYPE}, $globals->{REPORT}, $globals->{SHARED_PROFILE});
		print $addResults->getResponseData();
	};

	if ($@)
	{
		print $@;
	}

=cut


##############################################################################

=item B<AttributeModifyCRData>

Load the details of a Change Request into data classes in which the 
details of the Change Request can be modified. The modified data classes
can then be submitted using one of the modification api functions 
to change a Change Request.
The return result is an instance of the L<apiObjectVector> class.

Note: Current transition choices are provided with this api function call.
See L<apiTransitions> class description.

 Parameters:
	apiUser aUser        : The current api user's login data.
	scalar  problemNumber: The Change Request ID/Problem Number ID to reference.

 Returns: apiObjectVector
	the details of a change request in data format.

 Example:

	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "User", "\\\\your_hostname\\ccmdb\\cm_database");

		my $tmp = $csapi->AttributeModifyCRData($aUser, "100");

		my $tmpstr = $tmp->getXmlData();
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<AttributeModifyCRData>

Load the details of a Change Request into data classes in which the 
details of the Change Request can be modified. The modified data classes
can then be submitted using one of the modification api functions 
to change a Change Request.
The return result is an instance of the L<apiObjectVector> class.

Note: Current transition choices are provided with this api function call.
See L<apiTransitions> class description.

 Parameters:
	apiUser aUser        : The current api user's login data.
	scalar  problemNumber: The Change Request ID/Problem Number ID to reference.
	scalar  attributeName: The name of the attribute in which to look up the
	                       referenced object's current value. This value MUST
	                       be a name of a IBM Rational Change template.

 Returns: apiObjectVector
	the details of a change request in data format.

 Example:

	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "User", "\\\\your_hostname\\ccmdb\\cm_database");

		my $tmp = $csapi->AttributeModifyCRData($aUser, "100", "crstatus");

		my $tmpstr = $tmp->getXmlData();
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<AttributeModifyCRDataAllTransitions>

Load the details of a Change Request into data classes in which the 
details of the Change Request can be modified. The modified data classes
can then be submitted using one of the modification api functions 
to change a Change Request.
The return result is an instance of the L<apiObjectVector> class.
The AllTransitions function includes HIDDEN transitions.

Note: Current transition choices are provided with this api function call.
See L<apiTransitions> class description.

 Parameters:
	apiUser aUser        : The current api user's login data.
	scalar  problemNumber: The Change Request ID/Problem Number ID to reference.
	scalar  attributeName: The name of the attribute in which to look up the
	                       referenced object's current value. This value MUST
	                       be a name of a IBM Rational Change template.

 Returns: apiObjectVector
	the details of a change request in data format.

 Example:

	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "User", "\\\\your_hostname\\ccmdb\\cm_database");

		my $tmp = $csapi->AttributeModifyCRDataAllTransitions($aUser, "100", "crstatus");

		my $tmpstr = $tmp->getXmlData();
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<AttributeModifyCRDataAllTransitions>

Load the details of a Change Request into data classes in which the 
details of the Change Request can be modified. The modified data classes
can then be submitted using one of the modification api functions 
to change a Change Request.
The return result is an instance of the L<apiObjectVector> class.
The AllTransitions function includes HIDDEN transitions.

Note: Current transition choices are provided with this api function call.
See L<apiTransitions> class description.

 Parameters:
	apiUser aUser        : The current api user's login data.
	scalar  problemNumber: The Change Request ID/Problem Number ID to reference.

 Returns: apiObjectVector
	the details of a change request in data format.

 Example:

	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "User", "\\\\your_hostname\\ccmdb\\cm_database");

		my $tmp = $csapi->AttributeModifyCRDataAllTransitions($aUser, "100");

		my $tmpstr = $tmp->getXmlData();
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<BalanceTransactionServer>

Triggers the session balancing routine.
The return result is an instance of the L<apiData> class.

 Parameters:
	apiUser aUser: The current api user's login data.

 Returns: apiData
	the return message from the server.
 
 Example:

	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "Admin", "\\\\your_hostname\\ccmdb\\cm_database");

		my $tmpstr = $csapi->BalanceTransactionServer($aUser);
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<CallBsfScript>

Calls a Bean Scripting Framework (BSF) script on the server and gets its
return value. The BSF script must reside in the servers wsconfig/scripts directory.
The return result is an instance of the L<apiData> class.

 Parameters:
	apiUser aUser     : The current api user's login data.
	scalar  scriptName: The name of the script to execute on the server. Must reside in the wsconfig/script directory.
						The value will be XML encoded by this method.
	scalar  scriptData: The data that should be sent to the script as a string. Can be XML, but must be XML encoded.
						The value will be XML encoded by this method.

 Returns: apiData
	the return message from the script.
 
 Example:

	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "Admin", "\\\\your_hostname\\ccmdb\\cm_database");

		my $scriptResults = $csapi->CallBsfScript($aUser, "testscript.js", "Data to the script");

		print $scriptResults->getResponseData() . "\n";
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<ChangePreferenceNameForAUser>

Change the name of a user's preference for a single user.  A preference
name cannot be renamed to a preference name which already exists for 
the user. The return result is an instance of the L<apiData> class.

Note: It is not possible to change or add user profile values.  These values
are the users first names, last names, email addresses, fax numbers, telephone
numbers and addresses.

 Parameters:
	apiUser aUser   : The current api user's login data.
	scalar  username: The name of the user's preferences to edit.
	scalar  keyName : The name of the preference to change.
	scalar  keyValue: The new name for the preference.
	scalar  allDBs  : true or false, should the add take place for all databases
						or just the one that the current api user is logged into.

 Returns: apiData
	the return message from the server.
 
 Example:
	
	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "Admin", "\\\\your_hostname\\ccmdb\\cm_database");
		
		$tmpData = $csapi->ChangePreferenceNameForAUser($aUser, "u00001", "user_cr_notes", "user_crnotes", "true");
	
		print $tmpData->getResponseData();

	};

	if ($@)
	{
		print $@;
	}

=cut

#############################################################################

=item B<ChangePreferenceNameForAllUsers>

Change the name of a user's preference for all users in the system.
A preference name cannot be renamed to a preference name which already 
exists for user. If the preference name does not exist for a user then
no changes will be made for that user.  If it does exist then the preference
name will be changed accordingly. The return result is an instance of
the L<apiData> class.

Note: It is not possible to change or add user profile values.  These values
are the users first names, last names, email addresses, fax numbers, telephone
numbers and addresses.

 Parameters:
	apiUser aUser   : The current api user's login data.
	scalar  keyName : The name of the preference to change.
	scalar  keyValue: The new name for the preference.
	scalar  allDBs  : true or false, should the add take place for all databases
						or just the one that the current api user is logged into.

 Returns: apiData
	the return message from the server.
 
 Example:
	
	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "Admin", "\\\\your_hostname\\ccmdb\\cm_database");
		
		$tmpData = $csapi->ChangePreferenceNameForAllUsers($aUser, "user_cr_notes", "user_crnotes", "true");
	
		print $tmpData->getResponseData();

	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<ChangeRequestFullName>

Obtains the four-part name for a Change Request.

 Parameters:
 
	apiUser aUser       : The current api user's login data.
	scalar ProblemNumber: The problem number.
 
 Returns: scalar 
	The four part name.

=cut

##############################################################################

=item B<ClearAllUserConfigurationData>

Unloads all user configuration data on the IBM Rational Change server.
The return result is an instance of the L<apiData> class.

 Parameters:
	apiUser aUser: The current api user's login data.

 Returns: apiData
	the return message from the server.
 
 Example:

	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "Admin", "\\\\your_hostname\\ccmdb\\cm_database");

		my $tmpstr = $csapi->ClearAllUserConfigurationData($aUser);
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<ClearBusySessions>

Clears the busy session table.
The return result is an instance of the L<apiData> class.

 Parameters:
	apiUser aUser: The current api user's login data.

 Returns: apiData
	the return message from the server.
 
 Example:

	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "Admin", "\\\\your_hostname\\ccmdb\\cm_database");

		my $tmpstr = $csapi->ClearBusySessions($aUser);
	};

	if ($@)
	{
		print $@;
	}

=cut

#############################################################################

	
=item B<ClearLog>

Clears the log file on the IBM Rational Change server.
The return result is an instance of the L<apiData> class.

 Parameters:
	apiUser aUser: The current api user's login data.

 Returns: apiData
	the return message from the server.
 
 Example:

	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "Admin", "\\\\your_hostname\\ccmdb\\cm_database");

		my $tmpstr = $csapi->ClearLog($aUser);
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<ClearTransitionUserList>

Clears the transition user list, a new copy will be created on the next request.
The return result is an instance of the L<apiData> class.

 Parameters:
	apiUser aUser: The current api user's login data.

 Returns: apiData
	the return message from the server.
 
 Example:

	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "Admin", "\\\\your_hostname\\ccmdb\\cm_database");

		my $tmpstr = $csapi->ClearTransitionUserList($aUser);
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<ClientAPIVersion>

Get the API version number of the client.
The return result is an instance of the L<apiData> class.

 Parameters:
	apiUser aUser: The current api user's login data.

 Returns: apiData
	The version number string.
 
 Example:

	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "User", "\\\\your_hostname\\ccmdb\\cm_database");

		my $tmpstr1 = $csapi->ClientAPIVersion($aUser);
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<ServerVersion>

Get the server version number. It is a tokenless api. 
The return result is an instance of the L<apiData> class.

 Parameters:
	apiUser aUser: The current api user's login data.

 Returns: apiData
	The version number string.
 
 Example:

	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "User", "\\\\your_hostname\\ccmdb\\cm_database");

		my $tmpstr1 = $csapi->ServerVersion();
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<CopyCRData>

Load the details of a Change Request into data classes in which the details
of the Change Request can be submitted/copied. The modified data classes can
then be submitted using one of the modification api functions to change a 
Change Request. The return result is an instance of the L<apiObjectVector> class.

Note: The submit "to state" and "relation name" are provided with this api function call.
See L<apiTransitions> class description.


 Parameters:
	apiUser aUser        : The current api user's login data.
	scalar  problemNumber: The Change Request ID/Problem Number ID to reference.
	scalar  templateName : The name of the IBM Rational Change template to load
	                       ([CCM_TEMPLATE][NAME]template name[/NAME]...[/CCM_TEMPLATE]).

 Returns: apiObjectVector
	the details of a change request in data format.

 Example:

	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "User", "\\\\your_hostname\\ccmdb\\cm_database");

		my $tmp = $csapi->CopyCRData($aUser, "100", "COPY_child_cr2new_child");

		my $tmpstr = $tmp->getXmlData();
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<CopyTaskData>

Load the details of a Task into data classes in which the details of
the Task can be submitted/copied. The modified data classes can then
be submitted using one of the modification api functions to change a Task.
The return result is an instance of the L<apiObjectVector> class.

 Parameters:
	apiUser aUser       : The current api user's login data.
	scalar  taskNumber  : The Task ID to reference.
	scalar  templateName: The name of the IBM Rational Change template to load 
	                      ([CCM_TEMPLATE][NAME]template name[/NAME]...[/CCM_TEMPLATE]).

 Returns: apiObjectVector
	the details of a task in data format.

 Example:

	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "User", "\\\\your_hostname\\ccmdb\\cm_database");

		my $tmp = $csapi->CopyTaskData($aUser, "12", "CreateTask");

		my $tmpstr = $tmp->getXmlData();
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<CreateAttachmentObject>

Create an attachment file object on the IBM Rational Change server and relates it to a CR.
The return result is an instance of the L<apiData> class. 


 Parameters:
	apiUser aUser         : The current api user's login data.
	scalar  problemNumber : The ProblemNumber/CR ID to relate the file to.
	scalar  relation      : The relation name to use when relating the object to the CR.
	scalar  attachmentName: The file name for this object.
	scalar  webType       : Carriage return sequence on client.
	                              CRLF:   Windows client text file.
	                              LF:     Unix client text file.
	                              BINARY: File is binary.
	scalar  comment       : The comments for the object to update.
	scalar  type          : Reserved for future use.
	scalar  isBinary      : A flag to specify that the file is a binary file.
	scalar  buffer        : A buffer of the data.
	scalar  size          : The size of the buffer.

 Returns: apiData
	the return message from the server.

 Example:

	my $csapi  = new ChangeSynergy::csapi();
	my $buf    = "";
	my $buffer = "";
	my $size   = "";

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "User", "\\\\your_hostname\\ccmdb\\cm_database");

		open(INPUTFILE, "output.doc") or die "Could not open up the file";
		binmode(INPUTFILE);

		while($buf = readline *INPUTFILE)
		{
			$buffer .= $buf;
		}

		close(INPUTFILE);
	
		$size = -s "output.doc";
    	
		my $data = $csapi->CreateAttachmentObject($aUser, "1", "attachment", "output",
											   "BINARY", "The output", "", "true", $buffer, $size);
		print $data->getResponseData();
	};
    
	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<CreateCSObject>

Creates a component version entity with model "model".
See CreateNewCV for a full description.
 
The cvtype, and name arguments are used to set the values of the full name 
attributes of the new entity. The creation will fail if the full name is not
unique among all component versions in the IBM Rational Synergy database.

CVs may contain names with the alpha-numerics and !&^~@*_.+: However, it is still
possible for a particular model to impose more constrained naming rules.

Note: If "cvtype" is a empty string, then the type will be "cs_object".

Note: "cvtype" must be the name of a component version type component 
      version in the model assembly model.

 Note: If "State" is a empty string then the status will default to "cs_public".

 Note: Default state change from (ac_def -> cs_public).
       No transitions are available in default state!

The return result is an instance of the L<apiData> class.

 Parameters:
	apiUser aUser   : The current api user's login data.
	scalar  cvtype  : The cvtype value of the desired four part compver name.
	scalar  name    : The name value of the desired four part compver name.
	scalar  state   : The status (state) value to be automatically transitioned to.

 Returns: apiData
	The return message from the server.
	Use the getResponseData() method to retrieve the compver id.
	The string value will be, ex: "CV: 5_digit_integer_value_of_compver"
	
 Example:

	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "User", "\\\\your_hostname\\ccmdb\\cm_database");

		my $tmp = $csapi->CreateCSObject($aUser, "admin", "special","");

		print $tmp->getResponseData(); #ex: "CV: 12345"

		#Note: Result will be like: "CV: 5_digit_integer_value_of_compver".
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<CreateDefaultCSObject>

Creates a component version entity with model "model".
See CreateNewCV for a full description.

The name argument is used to set the value of the full name attributes of the
new entity. The creation will fail if the full name is not unique among all
component versions in the IBM Rational Synergy database.
 
CVs may contain names with the alpha-numerics and !&^~@*_.+: However, it is still
possible for a particular model to impose more constrained naming rules.  
The return result is an instance of the L<apiData> class.

 Parameters:
	apiUser aUser  : The current api user's login data.
	scalar  name   : The name value of the desired four part compver name.

 Returns: apiData
	The return message from the server.
	Use the getResponseData() method to retrieve the compver id.
	The string value will be, ex: "CV: 5_digit_integer_value_of_compver"
	
 Example:

	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "User", "\\\\your_hostname\\ccmdb\\cm_database");

		my $tmp = $csapi->CreateDefaultCSObject($aUser, "special");

		print $tmp->getResponseData(); #ex: "CV: 12345"

		#Note: Result will be like: "CV: 5_digit_integer_value_of_compver".
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<CreateIndex>

Create the search index on the IBM Rational Change Server.
The return result is an instance of the L<apiData> class.

 Parameters:
	apiUser aUser: The current api user's login data.

 Returns: apiData
	the return message from the server.
 
 Example:

	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "Admin", "\\\\your_hostname\\ccmdb\\cm_database");

		my $tmpstr = $csapi->CreateIndex($aUser);
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<CreateMiscObject>

Create a misc object. The return result is an instance of the L<apiData> class.

 Parameters:
	apiUser aUser       : The current api user's login data.
	scalar  objectString: The object identifier to be created.
 
 Returns: apiData
	CVID of the new object.

 Example:

	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "User", "\\\\your_hostname\\ccmdb\\cm_database");

		my $tmpstr = $csapi->CreateMiscObject($aUser, "DOORS_ID_400");
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<CreateNewCV>

WARNING:
This method is not intended for general use. Users of this method must be
very familiar with ACcent programming. Use the general "CreateCSObject"
or "CreateDefaultCSObject" api methods.

Creates a component version entity with model "model".

[subsys/cvtype/name/version]
ex: "1/admin/cs/1"

The subsys, cvtype, name, and version arguments are used to set the values of the
full name attributes of the new entity. The creation will fail if the full name is
not unique among all component versions in the IBM Rational Synergy database.

CVs may contain names with the alpha-numerics and !&^~@*_.+: However, it is still
possible for a particular model to impose more constrained naming rules.
 
Note: If "version" is a empty string, then the version will be "1".

Note: If "cvtype" is a empty string, then the type will be "cs_object".

Note: "cvtype" must be the name of a component version type component 
       version in the model assembly model.

Predefined cvtypes on the default model:
           cs_object,admin,ascii,asm0,baseline,binary,bitmap,c++,class,csrc,
           css,dir,dtd,executable,folder,folder_temp,gif,group,html,
           incl,jar,java,jpeg,library,lsrc,makefile,misc,perl,problem,
           project,recon_temp,releasedef,relocatable_obj,shared_library,
           shsrc,symlink,task,tset,xml,ysrc

Note: Do not add the DBID and DCM delimiter to the "subsys". These values will be
automatically added if DCM/DCS is initialized. If the DBID and DCM delimiter are added
then a subsystem of that looks like foo#foo#1 would be created instead of foo#1.

Note: If "subsys" is a empty string, then the instance_number will be calculated.
      If DCM/DCS is initialized, the DCM database id and DCM delimiter are
      used in addition to the "subsys" or calculated instance. 

      DCM initialized:
         ex: db63#1/cs_object/your_name/1
 
      Not DCM initialized:
         ex: 1/cs_object/your_name/1
 
The following attributes of the new entity may/will be created and given values:

 create_time  : time    : Current time.
 cvtype       : string  : Argument cvtype.
 is_asm       : boolean : Component version type's "is_asm" attribute value.
 is_model     : boolean : Component version type's "is_model" attribute value.
 local_bgraph : boolean : FALSE.
 modify_time  : time    : Current time.
 name         : string  : Argument name.
 owner        : string  : Current user.
 status       : string  : Component version type's "dflt_status" attribute value.
 subsystem    : string  : Argument subsys.
 version      : string  : Argument version.
 
Note: If "State" is a empty string then the status will default to "cs_public".

Note: Default state change from (ac_def -> cs_public).
      No transitions are available in default state!

Default security is based on CHANGE_STATE = "cs_public"

			  *** SYSTEM PREDEFINED STATES ***
 state working            = private + read + eval;
 state visible            = private + read + eval + bind;
 state working_folder     = private + read + eval + user1;
 state checkpoint         = private + read + eval + user0;

 state readonly           = static + read + eval;
 state cs_admin           = static + read + user9;
 state published_baseline = static + read + eval + user7;
 state released           = static + read + eval + derive + bind;
 state readonly_folder    = static + read + eval + derive + user0;
 state rejected           = static + read + eval + derive + bind + user3;
 state test               = static + read + eval + derive + bind + user2;
 state sqa                = static + read + eval + derive + bind + user0;
 state integrate          = static + read + eval + derive + bind + user1;
 
 state task_deferred      = read + write + user0;
 state registered         = read + write + user1;
 state task_assigned      = read + write + user2;
 state completed          = read + write + user3;
 state deleted            = read + write + user4;
 state excluded           = read + write + user5;
 state task_automatic     = read + write + user6;
 state public             = read + eval  + bind   + write;
 state crbase             = read + write + eval   + user1;
 state entered            = read + write + eval   + user2;
 state deferred           = read + write + eval   + user3;
 state concluded          = read + write + eval   + user4;
 state duplicate          = read + write + user1  + user2;
 state working_recon_temp = read + eval  + write  + user5;
 state static_recon_temp  = read + eval  + static + user5;
 state prep_baseline      = read + eval  + write  + user7;
 state shared_folder      = read + eval  + derive + write;
 state shared             = read + eval  + derive + bind  + write;
 state admin              = read + eval  + bind   + write + user0;
 state release_admin      = read + eval  + write  + user0 + user1;
 state cs_public          = read + eval  + bind   + write + user8;
 state in_review          = read + write + eval   + bind  + user1;
 state assigned           = read + write + eval   + bind  + user2;
 state probreject         = read + write + eval   + bind  + user3;
 state resolved           = read + write + eval   + bind  + user4;
 state prep_folder        = read + eval  + derive + write + user1;
 state prep               = read + eval  + derive + bind  + write + user0;
 state dcm_admin          = read + eval  + bind   + write + user0 + user1;

The return result is an instance of the L<apiData> class.

 Parameters:
	apiUser aUser   : The current api user's login data.
	scalar  subsys  : The subsys value of the desired four part compver name.
	scalar  cvtype  : The cvtype value of the desired four part compver name.
	scalar  name    : The name value of the desired four part compver name.
	scalar  version : The version value of the desired four part compver name.
	scalar  state   : The status (state) value to be automatically transitioned to.

 Returns: apiData
	The return message from the server.
	Use the getResponseData() method to retrieve the compver id.
	The string value will be, ex: "CV: 5_digit_integer_value_of_compver"
	
 Example:

	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "User", "\\\\your_hostname\\ccmdb\\cm_database");

		my $tmp = $csapi->CreateNewCV($aUser, "", "admin", "special", "1", "");

		print $tmp->getResponseData(); #ex: "CV: 12345"

		#Note: Result will be like: "CV: 5_digit_integer_value_of_compver".
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<CreateObjectAttributes>

Creates new attribute(s) of compver with name "your name value" and attribute type "your type value."
"type" must be a member of compver's model assembly. The initial value given to the attribute 
must be provided. This operation also updates the compver's modify_time attribute. The return
result is an instance of the L<apiData> class.

 Parameters:
	apiUser         aUser       : The current api user's login data.
	scalar          cvidList    : A "|" pipe delimited list of cvids to be affected, or a single cvid.
	apiObjectVector attrData    : The data to be processed by the api function.
 
 Returns: apiData
	The return message from the server.

 Example:

	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "User", "\\\\your_hostname\\ccmdb\\cm_database");

		my $attrData = new ChangeSynergy::apiObjectVector();

		my $objData = new ChangeSynergy::apiObjectData();
		$objData->setName("attribute_a");
		$objData->setType("text");
		$objData->setValue("Linux");
		$attrData->addDataObject($objData);

		my $objData = new ChangeSynergy::apiObjectData();
		$objData->setName("attribute_b");
		$objData->setType("boolean");
		$objData->setValue("true");
		$attrData->addDataObject($objData);

		my $objData = new ChangeSynergy::apiObjectData();
		$objData->setName("attribute_c");
		$objData->setType("integer");
		$objData->setValue("777");
		$attrData->addDataObject($objData);

		my $tmp = $csapi->CreateObjectAttributes($aUser, "10156|10157|10158|10159|10160", $attrData)

		print $tmp->getResponseData();
	};

	if ($@)
	{
		print $@;
	}

=cut



##############################################################################

=item B<createProcessPackage>

Create a CR Process package using an XML file already on the server
and potentially a package template that also already exists on the server.
The return result is an instance of the L<apiData> class.

 Parameters:
	apiUser aUser           : The current api user's login data.
	scalar  xmlFileName     : The name of the CR Process XML file in the WEB-INF\cr_process directory.
	scalar  packageTemplate : The name of a package template to merge with that is 
	                          in the WEB-INF\package_templates directory.

 Returns: apiData
	results The name of the package which was created.

 Example:

	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $globals = new ChangeSynergy::Globals();

		my $aUser = $csapi->Login("u00001", "u00001", "Admin", "\\\\machineA\\ccmdb\\cm_database");

		my $response = $csapi->createProcessPackage($aUser, "dev_process.xml", "dev_template");
		print $response->getResponseData();
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<CreateRelation>

Create a relation between two IBM Rational Synergy objects.
The return result is an instance of the L<apiData> class.

 Parameters:
	apiUser aUser              : The current api user's login data.
	scalar  bothWayRelationship: Create a relationship in both directions, [true|false].
	scalar  fromObject         : The object from which the relation is created.
	scalar  toObject           : The object to which the relation is applied.
	scalar  relationName       : A valid IBM Rational Synergy/IBM Rational Change relation name.
	scalar  relationType       : The relation type, see below.

 Valid Relation Types (Constants defiend in Globals.pm):
        CCM_PROBLEM_PROBLEM  // Create a Change Request to Change Request relation
        CCM_PROBLEM_TASK     // Create a Change Request to Task relation
        CCM_PROBLEM_OBJECT   // Create a Change Request to Object relation
        CCM_TASK_PROBLEM     // Create a Task to Change Request relation
        CCM_TASK_TASK        // Create a Task to Task relation
        CCM_TASK_OBJECT      // Create a Task to Object relation
        CCM_OBJECT_PROBLEM   // Create a Object to Change Request relation
        CCM_OBJECT_TASK      // Create a Object to Task relation
        CCM_OBJECT_OBJECT    // Create a Object to Object relation
        
        Example usage:
          my $globals = new ChangeSynergy::Globals();
          my $relationType = $globals->{CCM_PROBLEM_PROBLEM};

 Returns: apiData
	results only if the creation was successful.

 Example:

	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $globals = new ChangeSynergy::Globals();

		my $aUser = $csapi->Login("u00001", "u00001", "User", "\\\\your_hostname\\ccmdb\\cm_database");

		my $tmpstr = $csapi->CreateRelation($aUser, "FALSE", "400", "1355", "my_copy", 
                                            $globals->{CCM_PROBLEM_PROBLEM});
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<createReport>

Create a new Change report that is based off of an existing Change report.
The return result is an instance of the L<apiData> class.

 Parameters:
	apiUser aUser              : The current api user's login data.
	scalar  reportDefinition   : An instance of a ChangeSynergy::CreateReportDefinition object.
	scalar  objectType         : The object type the report is querying for.
	scalar  configType         : The configuration location the report will end up in, valid types are user and shared only.

 Valid object types (Constants defiend in Globals.pm):
        PROBLEM_TYPE
        TASK_TYPE
        OBJECT_TYPE
 
 Valid configuration types (Constants defiend in Globals.pm):
        SHARED_PROFILE
        USER_PROFILE

 Returns: apiData
	results on if the creation was successful.

To see an example of how to use the createReport API see the example in the L<CreateReportDefinition> help. Be sure
that the required paramters name, query string and base report are all defined in the CreateReportDefinition object.

=cut

##############################################################################

=item B<CreateUserSecurityData>

Create user security files on the server.

 Parameters:
 
	apiUser aUser: The current api user's login data.
 
 Returns: scalar
	A return message.


 Example:

	my $csapi = new ChangeSynergy::csapi();
	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "Admin", "\\\\your_hostname\\ccmdb\\cm_database");

		my $tmp = $csapi->CreateUserSecurityData($aUser);
	}

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<CSHostName>

Get the configured host name for the ChangeSynergy server.
The return result is an instance of the L<apiData> class.

 Parameters:
	apiUser aUser: The current api user's login data.

 Returns: apiData
	the host name string.
 
 Example:

	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "User", "\\\\your_hostname\\ccmdb\\cm_database");

		my $tmpstr = $csapi->CSHostName($aUser);
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<DatabaseGetObject>

Copy a database object into a new BYTE array.
The return result is an instance of the L<apiData> class. 

 Parameters:
	apiUser aUser: The current api user's login data.
	scalar  Cvid : The cvid of the source object to retrieve.

 Returns: apiData
	the byte data from the server
	
 Example:
 
 	$csapi->setUpConnection("http://your_hostname:port/your_context");
 	
 	eval
 	{
 		my $aUser = $csapi->Login("u00001", "u00001", "User", "\\\\your_hostname\\ccmdb\\cm_database");
 		my $data  = $csapi->DatabaseGetObject($aUser, "11023");

		open(OUTPUT, ">file.txt");
		print(OUTPUT $data->getResponseByteData());
		close(OUTPUT);
 	};
 	
 	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<DatabaseSetObject>

Update a file object on the IBM Rational Change server.
Can only update objects in the 'public' state.
The return result is an instance of the L<apiData> class. 

 Parameters:
	apiUser aUser  : The current api user's login data.
	scalar  cvid   : The cvid of the public source object to update.
	scalar  comment: The comments for the object to update.
	scalar  buffer : The BYTE data to set on the server.
	scalar  size   : The size of the BYTE data.

 Returns: apiData
	the return message from the server.
	
 Example:
 
 	$csapi->setUpConnection("http://your_hostname:port/your_context");

 	my $buf    = "";
	my $buffer = "";
	my $size   = "";
 	
	eval
	{
		my $aUser      = $csapi->Login("u00001", "u00001", "User", "\\\\your_hostname\\ccmdb\\cm_database");
 		
		open(INPUTFILE, "input.txt") or die "Could not open up the file";

		while($buf = readline *INPUTFILE)
		{
			$buffer .= $buf;
		}

		close(INPUTFILE);
    
		$size = -s "input.txt";
    	
		my $data = $csapi->DatabaseSetObject($aUser, "10341", "new comment", $buffer, $size);
	};
 	
	if ($@)
	{
		print $@;
	}

=cut

##############################################################################


=item B<DeleteAllUserPreferences>

Delete the preference object for all users in the system.  Warning - this
permanently deletes ALL preferences for ALL users;  there is no recovery
option. The return result is an instance of the L<apiData> class.

 Parameters:
	apiUser aUser   : The current api user's login data.

 Returns: apiData
	the return message from the server.
 
 Example:
	
	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "Admin", "\\\\your_hostname\\ccmdb\\cm_database");
		
		$tmpData = $csapi->DeleteAllUserPreferences($aUser);
	
		print $tmpData->getResponseData();

	};

	if ($@)
	{
		print $@;
	}

=cut

#############################################################################


=item B<DeleteAPreferenceForAllUsers>

Delete a preference for all users in the system.  Warning - this permanently 
this deletes a single preferences for ALL users; there is no recovery 
option. The return result is an instance of the L<apiData> class.

Note: It is not possible to delete user profile values.  These values
are the users first names, last names, email addresses, fax numbers, telephone
numbers and addresses.

 Parameters:
	apiUser aUser   : The current api user's login data.
	scalar  keyname : The name of the preference to delete.
	scalar  allDBs  : true or false, should the add take place for all databases
						or just the one that the current api user is logged into.

 Returns: apiData
	the return message from the server.
 
 Example:
	
	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "Admin", "\\\\your_hostname\\ccmdb\\cm_database");
		
		$tmpData = $csapi->DeleteAPreferenceForAllUsers($aUser, "user_fontsize" "true");

		print $tmpData->getResponseData();

	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<DeleteAPreferenceForAUser>

Delete a preference for a user in the system.  Warning - this 
permanently deletes a single preferences for a user; there is
no recovery option. The return result is an instance of the L<apiData>
class.

Note: It is not possible to delete user profile values.  These values
are the users first names, last names, email addresses, fax numbers, telephone
numbers and addresses.

 Parameters:
	apiUser aUser   : The current api user's login data.
	scalar  username: The name of the user's preferences to delete.
	scalar  keyname : The name of the preference to delete.
	scalar  allDBs  : true or false, should the add take place for all databases
						or just the one that the current api user is logged into.

 Returns: apiData
	the return message from the server.
 
 Example:
	
	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "Admin", "\\\\your_hostname\\ccmdb\\cm_database");
		
		$tmpData = $csapi->DeleteAPreferenceForAUser($aUser, "u00001", "user_fontsize", "true");
	
		print $tmpData->getResponseData();

	};

	if ($@)
	{
		print $@;
	}

=cut

#############################################################################

=item B<DeleteAUsersPreferences>

Delete the preference object for a single user in the system.  Warning -
this permanently deletes ALL preferences for a single user; there is no recovery 
option. The return result is an instance of the L<apiData> class.

 Parameters:
	apiUser aUser   : The current api user's login data.
	scalar  username: The name of the user's preferences to delete

 Returns: apiData
	the return message from the server.
 
 Example:
	
	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "Admin", "\\\\your_hostname\\ccmdb\\cm_database");
		
		$tmpData = $csapi->DeleteAUsersPreferences($aUser, "u00001");
	
		print $tmpData->getResponseData();

	};

	if ($@)
	{
		print $@;
	}

=cut

#############################################################################

=item B<DeleteChangeRequest>

Deletes a Change Request.  This operation requires the process admin privilege.  The return result is an instance of the L<apiData> class. 

 Parameters:
	apiUser aUser        : The current api user's login data.
	scalar  problemNumber: The problem number to delete.

 Returns: apiData
	The delete status message.

 Example:

	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "User", "\\\\your_hostname\\ccmdb\\cm_database");

		my $tmpstr = $csapi->DeleteChangeRequest($aUser, "10");
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<DeleteCV>

Deletes compver and all subordinate objects and attributes from the database. 
The subordinate objects include collectors, processors, connectors, bindings
(in the case of an assembly), and binding sites. The entity will not be 
deleted if any of the following conditions are true:

         > compver is a member of an existing assembly.
         > compver is a model assembly and component versions with it as model exist.
         > compver is an attribute, binding site, component version, or product type
               component version and instances of it currently exist.
         > compver is an attribute, binding site, component version, or product type
               component version and is also the super_type of another existing type
               component version.

The return result is an instance of the L<apiData> class.

 Parameters:
	apiUser aUser : The current api user's login data.
	scalar  cvid  : The cvid of the compver to delete.
 
 Returns: apiData
	The return message from the server.

 Example:

	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "User", "\\\\your_hostname\\ccmdb\\cm_database");

		my $tmp = $csapi->DeleteCV($aUser,"10159");

		print $tmp->getResponseData();
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<deleteFolder>

Delete a query, report format or report folder and all members from the server.
The return result is an instance of the L<apiData> class.

 Parameters:
	apiUser aUser     : The current api user's login data.
	scalar  folderName: The name of the folder to delete.
	scalar  objectType: The object type for the folder.
	scalar  formatType: The format type of the folder: report, query or report format.
	scalar  configType: The configuration location for the report.

 Valid object types (Constants defiend in Globals.pm):
        PROBLEM_TYPE
        TASK_TYPE
        OBJECT_TYPE

 Valid format types (Constants defiend in Globals.pm):
 		QUERY
        REPORT
        REPORT_FORMAT
 
 Valid configuration types (Constants defiend in Globals.pm):
        SHARED_PROFILE
        SYSTEM_CONFIG
        USER_PROFILE
        
 Returns: apiData
	the return message from the server.
 
 Example:
	
	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "Admin", "\\\\machine\\ccmdb\\cm_database");
		
		my $globals = new ChangeSynergy::Globals();
		
		#Delete a shared CR Report folder called 'API Folder'.
		my $deleteResults = $csapi->deleteFolder($aUser, 'API Folder', $globals->{PROBLEM_TYPE}, $globals->{REPORT}, $globals->{SHARED_PROFILE});
		print $deleteResults->getResponseData();
	};

	if ($@)
	{
		print $@;
	}

=cut

#############################################################################

=item B<DeleteNewCV>

Deletes compver and all subordinate objects and attributes from the database. 
The subordinate objects include collectors, processors, connectors, bindings
(in the case of an assembly), and binding sites. The entity will not be 
deleted if any of the following conditions are true:

         > compver is a member of an existing assembly.
         > compver is a model assembly and component versions with it as model exist.
         > compver is an attribute, binding site, component version, or product type
               component version and instances of it currently exist.
         > compver is an attribute, binding site, component version, or product type
               component version and is also the super_type of another existing type
               component version.

The return result is an instance of the L<apiData> class.

 Parameters:
	apiUser aUser   : The current api user's login data.
	scalar  Subsys  : The subsys value of the desired four part compver name.
	scalar  cvtype  : The cvtype value of the desired four part compver name.
	scalar  name    : The name value of the desired four part compver name.
	scalar  version : The version value of the desired four part compver name.
 
 Returns: apiData
	The return message from the server.

 Example:

	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "User", "\\\\your_hostname\\ccmdb\\cm_database");

		my $tmp = $csapi->DeleteNewCV($aUser, "3", "admin", "special", "1");

		print $tmp->getResponseData();
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<DeleteObjectAttributes>

Deletes existing attribute(s) of compver with name "your name value." This operation
also updates the compver's modify_time attribute. The return result is an instance of
the L<apiData> class.

 Parameters:
	apiUser         aUser       : The current api user's login data.
	scalar          cvidList    : A "|" pipe delimited list of cvids to be affected, or a single cvid.
	apiObjectVector attrData    : The data to be processed by the api function.
 
 Returns: apiData
	The return message from the server.

 Example:

	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "User", "\\\\your_hostname\\ccmdb\\cm_database");

		my $attrData = new ChangeSynergy::apiObjectVector();

		my $objData = new ChangeSynergy::apiObjectData();
		$objData->setName("attribute_a");
		$attrData->addDataObject($objData);

		my $objData = new ChangeSynergy::apiObjectData();
		$objData->setName("attribute_b");
		$attrData->addDataObject($objData);

		my $objData = new ChangeSynergy::apiObjectData();
		$objData->setName("attribute_c");
		$attrData->addDataObject($objData);

		my $tmp = $csapi->DeleteObjectAttributes($aUser, "10156|10157|10158|10159|10160", $attrData)

		print $tmp->getResponseData();
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<DeleteRelation>

Delete a relation between two IBM Rational Synergy objects.
The return result is an instance of the L<apiData> class.

 Parameters:
	apiUser aUser              : The current api user's login data.
	scalar  bothWayRelationship: Create a relationship in both directions, [true|false].
	scalar  fromObject         : The object from which the relation is created.
	scalar  toObject           : The object to which the relation is applied.
	scalar  relationName       : A valid IBM Rational Synergy/IBM Rational Change relation name.
	scalar  relationType       : The relation type, see below.

 Valid Relation Types (Constants defiend in Globals.pm):
        CCM_PROBLEM_PROBLEM	// Create a Change Request to Change Request relation
        CCM_PROBLEM_TASK		// Create a Change Request to Task relation
        CCM_PROBLEM_OBJECT		// Create a Change Request to Object relation
        CCM_TASK_PROBLEM		// Create a Task to Change Request relation
        CCM_TASK_TASK		// Create a Task to Task relation
        CCM_TASK_OBJECT		// Create a Task to Object relation
        CCM_OBJECT_PROBLEM		// Create a Object to Change Request relation
        CCM_OBJECT_TASK		// Create a Object to Task relation
        CCM_OBJECT_OBJECT		// Create a Object to Object relation
        
        Example usage:
          my $globals = new ChangeSynergy::Globals();
          my $relationType = $globals->{CCM_PROBLEM_PROBLEM};

 Returns: apiData
	results only if the deletion was successful.

 Example:

	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $globals = new ChangeSynergy::Globals();

		my $aUser = $csapi->Login("u00001", "u00001", "User", "\\\\your_hostname\\ccmdb\\cm_database");

		my $tmpstr = $csapi->DeleteRelation($aUser, "FALSE", "400", "1355", "my_copy", 
                                            $globals->{CCM_PROBLEM_PROBLEM});
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<deleteReport>

Delete a CR or task report from a users preferences or from shared data. Will throw an exception if the 
named report cannot be found to be deleted.
The return result is an instance of the L<apiData> class. 

 Parameters:
	apiUser aUser      : The current api user's login data.
	scalar  reportName : The name of the report to delete.
	scalar  objectType : The object type for the report.
	scalar  configType : The configuration location for the report, valid types are user and shared only.

 Valid object types (Constants defiend in Globals.pm):
        PROBLEM_TYPE
        TASK_TYPE
        OBJECT_TYPE
 
 Valid configuration types (Constants defiend in Globals.pm):
        SHARED_PROFILE
        USER_PROFILE
 
 Returns: apiData
	The delete status message.
	
 Example:
 
	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "User", "\\\\machine\\ccmdb\\cm_database");

		my $globals = new ChangeSynergy::Globals();
		
		#Delete a CR report named 'My column report' from the shared preferences and print the results.
		my $deleteResults = $csapi->deleteReport($aUser, "My column report", $globals->{PROBLEM_TYPE}, $globals->{SHARED_PROFILE});
		print $deleteResults->getResponseData();
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<DeleteTask>

Delete a Task. The return result is an instance of the L<apiData> class. 

 Parameters:
	apiUser aUser     : The current api user's login data.
	scalar  taskNumber: The task number to delete.

 Returns: apiData
	The delete status message.

 Example:

	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "User", "\\\\your_hostname\\ccmdb\\cm_database");

		my $tmpstr = $csapi->DeleteTask($aUser, "1");
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<DisableDatabase>

Disable a IBM Rational Change database on the IBM Rational Change server.
The return result is an instance of the L<apiData> class.

 Parameters:
	apiUser aUser   : The current api user's login data.
	scalar  database: The database to disable.

 Returns: apiData
	the return message from the server.

 Example:

	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "Admin", "\\\\your_hostname\\ccmdb\\cm_database");

		my $tmpstr = $csapi->DisableDatabase($aUser, "\\\\your_hostname\\ccmdb\\cm_database");
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<DisableHost>

Disable a IBM Rational Change host on the IBM Rational Change server.
The return result is an instance of the L<apiData> class.

 Parameters:
	apiUser aUser: The current api user's login data.
	scalar  host : The host to disable.

 Returns: apiData
	the return message from the server.
 
 Example:

	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "Admin", "\\\\your_hostname\\ccmdb\\cm_database");


		my $tmpstr = $csapi->DisableHost($aUser, "cm_host");
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<DisableIndexing>

Force indexing to stop on the IBM Rational Change Server.
The return result is an instance of the L<apiData> class.

 Parameters:
	apiUser aUser: The current api user's login data.

 Returns: apiData
	the return message from the server.
 
 Example:

	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "Admin", "\\\\your_hostname\\ccmdb\\cm_database");

		my $tmpstr = $csapi->DisableIndexing($aUser);
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<DumpAUsersPreferences>

Get the entire contents of the user's preferences returned as a string.
This string contains the name and value for everything found in a user's
preference object.  This is helpful for debugging purposes and ensuring
the desired changes have taken effect.
The return result is an instance of the L<apiData> class.

 Parameters:
	apiUser aUser   : The current api user's login data.
	scalar  username: The users preference data to get.

 Returns: apiData
	the return message from the server.
 
 Example:

	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "Admin", "\\\\your_hostname\\ccmdb\\cm_database");

		my $tmpstr = $csapi->DumpAUsersPreferences($aUser, "u00001");
		print $tmpstr->getResponseData();
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<EnableDatabase>

Enable a IBM Rational Change database on the IBM Rational Change server.
The return result is an instance of the L<apiData> class.

 Parameters:
	apiUser aUser   : The current api user's login data.
	scalar  database: The database to enable.

 Returns: apiData
	the return message from the server.

 Example:

	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "Admin", "\\\\your_hostname\\ccmdb\\cm_database");

		my $tmpstr = $csapi->EnableDatabase($aUser, "\\\\your_hostname\\ccmdb\\cm_database");
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<EnableHost>

Enable a IBM Rational Change host on the IBM Rational Change server.
The return result is an instance of the L<apiData> class.

 Parameters:
	apiUser aUser: The current api user's login data.
	scalar  host : The host to enable.

 Returns: apiData
	the return message from the server.
 
 Example:

	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "Admin", "\\\\your_hostname\\ccmdb\\cm_database");


		my $tmpstr = $csapi->EnableHost($aUser, "cm_host");
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<EnableIndexing>

Allow indexing to resume on the IBM Rational Change Server.
The return result is an instance of the L<apiData> class.

 Parameters:
	apiUser aUser: The current api user's login data.

 Returns: apiData
	the return message from the server.
 
 Example:

	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "Admin", "\\\\your_hostname\\ccmdb\\cm_database");

		my $tmpstr = $csapi->EnableIndexing($aUser);
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<exportAReport>

Export a named CR or task report from either the shared preferences or a users preferences. 
The return result is an instance of the L<ReportEntry> class.

 Parameters:
	apiUser aUser      : The current api user's login data.
	scalar  reportName : The name of the report to export from the server.
	scalar  objectType : The object type for the report.
	scalar  configType : The configuration location for the report.

 Valid object types (Constants defiend in Globals.pm):
        PROBLEM_TYPE
        TASK_TYPE
        OBJECT_TYPE
 
 Valid configuration types (Constants defiend in Globals.pm):
        SHARED_PROFILE
        SYSTEM_CONFIG
        USER_PROFILE
        
 Returns: ReportEntry
	a report entry object which contains all the information about a report.
 
 Example 1:
 	
 	#Print all data about a report.
 	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "User", "\\\\machine\\ccmdb\\cm_database");

		#Construct a new Globals object.
		my $globals = new ChangeSynergy::Globals();
		
		#Export a CR report named 'My Report' from the shared preferences 
		my $reportEntry = $csapi->exportAReport($aUser, "My Report",  $globals->{PROBLEM_TYPE}, $globals->{SHARED_PROFILE});
		
		#Print all information about the report, query and subreport.
		print "--------------- Report Entry ---------------------\n";
		print "\nreportEntry->getName          : " . $reportEntry->getName();
		print "\nreportEntry->getBaseName      : " . $reportEntry->getBaseName();
		print "\nreportEntry->getReportTemplate: " . $reportEntry->getReportTemplate();
		print "\nreportEntry->getExportFormat  : " . $reportEntry->getExportFormat();
		print "\nreportEntry->getMaxQuery      : " . $reportEntry->getMaxQuery();
		print "\nreportEntry->getMaxString     : " . $reportEntry->getMaxString();
		print "\nreportEntry->getDescription   : " . $reportEntry->getDescription();
		print "\nreportEntry->getIncrementSize : " . $reportEntry->getIncrementSize();
		print "\nreportEntry->getIncremental   : " . $reportEntry->getIncremental();
		print "\nreportEntry->getStyle         : " . $reportEntry->getStyle();
		print "\nreportEntry->getCustomDisOrder: " . $reportEntry->getCustomDisplayOrder();
		print "\nreportEntry->getImagePath     : " . $reportEntry->getImagePath();
		
		print "\n\n";
		print "--------------- Query Entry ---------------------\n";
		my $queryEntry = $reportEntry->getQueryEntry();
	
		print "Name        : " . $queryEntry->getName() . "\n";
		print "Query String: " . $queryEntry->getQueryString() . "\n";
		print "Desc        : " . $queryEntry->getDescription() . "\n";
		print "Prompting   : " . $queryEntry->getPromptingQueryXml() . "\n";
		print "Template    : " . $queryEntry->getTemplate() . "\n";
		
		print "--------------- Sub Report Entries ---------------------\n";
		
		my @subreports = $reportEntry->getSubReports();
		
		for my $subReportEntry (@subreports)
		{
			print "--------------- Sub Report Entry ---------------------\n";
			print "getName                  :" . $subReportEntry->getName() . "\n";
			print "getMainTemplate          :" . $subReportEntry->getMainTemplate() . "\n";
			print "getHeaderTemplate        :" . $subReportEntry->getHeaderTemplate() . "\n";
			print "getAttributeTemplate     :" . $subReportEntry->getAttributeTemplate() . "\n";
			print "getImageTemplate         :" . $subReportEntry->getImageTemplate() . "\n";
			print "getGroupTemplate         :" . $subReportEntry->getGroupTemplate() . "\n";
			print "getAutoAttributeTemplate :" . $subReportEntry->getAutoAttributeTemplate() . "\n";
			print "getFooterTemplate        :" . $subReportEntry->getFooterTemplate() . "\n";
			print "getGroupBy               :" . $subReportEntry->getGroupBy() . "\n";
			print "getCustomWslet           :" . $subReportEntry->getCustomWslet() . "\n";
			print "getXmlContent            :" . $subReportEntry->getXmlContent() . "\n";
			print "getSpanAttributeTemplate :" . $subReportEntry->getSpanAttributeTemplate() . "\n";
			print "getLabelTemplate         :" . $subReportEntry->getLabelTemplate() . "\n";
			print "getAutoLabelTemplate     :" . $subReportEntry->getAutoLabelTemplate() . "\n";
			print "getAttributes            :" . $subReportEntry->getAttributes() . "\n";
			print "getSortOrder             :" . $subReportEntry->getSortOrder() . "\n";
			print "getRelation              :" . $subReportEntry->getRelation() . "\n";
			print "getDefinitionType        :" . $subReportEntry->getDefinitionType() . "\n\n";
		}
	};

	if ($@)
	{
		print $@;
	}
	
  Example 2:
 
 	#Save report XML to file.
 	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "User", "\\\\machine\\ccmdb\\cm_database");

		#Construct a new Globals object.
		my $globals = new ChangeSynergy::Globals();
		
		#Export a CR report named 'My Report' from the shared preferences 
		my $reportEntry = $csapi->exportAReport($aUser, "My Report",  $globals->{PROBLEM_TYPE}, $globals->{SHARED_PROFILE});
		
		my $file = $reportEntry->getName() . ".xml";
		
		open(OUTPUT, ">$file");
		print(OUTPUT $reportEntry->toXml());
		close(OUTPUT);
	};

	if ($@)
	{
		print $@;
	}

 Example 3:
 
 	#Load saved XML results back into a L<ReporEntry> object.
 	
 	my $file = "report.xml";
 	open (INPUTFILE, "$file") or die "Could not open the file!";
	my $filecontents = "";
	my $buffer = "";
	
	while ($buffer = readline *INPUTFILE)
	{
		$filecontents .= $buffer;
	}
	
	close(INPUTFILE);
	
	my $reportEntryFactory = new ChangeSynergy::ReportEntryFactory();
	my $reportEntry = $reportEntryFactory->createReportEntryFromXml($filecontents);

=cut

##############################################################################

=item B<exportReportsFromFolder>

Export all of the CR or task reports from a named folder in either the shared preferences or a users preferences.  
The return result is an array of L<ReportEntry> classes.

 Parameters:
	apiUser aUser      : The current api user's login data.
	scalar  folderName : The name of the folder to export all report from.
	scalar  objectType : The object type for the report.
	scalar  configType : The configuration location for the report.

 Valid object types (Constants defiend in Globals.pm):
        PROBLEM_TYPE
        TASK_TYPE
        OBJECT_TYPE
 
 Valid configuration types (Constants defiend in Globals.pm):
        SHARED_PROFILE
        SYSTEM_CONFIG
        USER_PROFILE

 Returns: ReportEntry
	an array of report entry objects which contains all the information about each report.
 
 Example:
 	
 	#Print all data about a report.
 	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "User", "\\\\machine\\ccmdb\\cm_database");

		#Construct a new Globals object.
		my $globals = new ChangeSynergy::Globals();
		
		#Export all CR reports from the folder 'My Folder' from the shared preferences 
		my @reportEntries = $csapi->exportReportsFromFolder($aUser, "My Folder",  $globals->{PROBLEM_TYPE}, $globals->{SHARED_PROFILE});
		
		foreach my $reportEntry (@reportEntries)
		{
			#See the exportAReport above or the L<ReportEntry> class for how to interact with a ReportEntry object.
		}
	};
	
	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<GetAttributes>

Gets all IBM Rational Change attributes defined on the server.
A IBM Rational Change attribute is:

	[CCM_ATTRIBUTE]
		[NAME]
			The IBM Rational Change Attribute name.
		[/NAME]
		[TYPE]
			The Web visualization data type, 
			available types are: CCM_STRING, CCM_TEXT, CCM_LISTBOX,
			and CCM_VALUELISTBOX.
		[/TYPE]
		[ROLE NAME]
			Optional role based aliases.
			There can be as many role options as there are defined web roles.
			Where "ROLE NAME" and "/ROLE NAME" are the literal role name.
		[/ROLE NAME]...
		[ALIAS]
			The default alias value for the attribute. This value is returned
			if role options are not used or if the users role is not specified.

			The [ALIAS] tag set defines the default, if no [ALIAS] tag exists
			the [NAME] is returned.
		[/ALIAS]
	[/CCM_ATTRIBUTE]

The [NAME] is identified through the getName() method.
The [TYPE] is identified through the getType() method.
The [ALIAS] is identified through the getLabel() method.
The [ROLE NAME] option is not available through the api.

The return result is an instance of the L<apiObjectVector> class.

 Parameters:
	apiUser aUser: The current api user's login data.
 
 Returns: apiObjectVector
	All of the IBM Rational Change attributes defined on the server.

 Example:

	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "User", "\\\\your_hostname\\ccmdb\\cm_database");

		my $attrs = $csapi->GetAttributes($aUser);

		my $i;
		my $j = $attrs->getDataSize();

		for($i=0; $i < $j; $i++)
		{
			print $attrs->getDataObject($i)->getName() . "\n";  #[CCM_ATTRIBUTE][NAME] 
			print $attrs->getDataObject($i)->getType() . "\n";  #[CCM_ATTRIBUTE][TYPE]
			print $attrs->getDataObject($i)->getLabel() . "\n"; #[CCM_ATTRIBUTE][ALIAS]
		}
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<GetCRData>

Load the details of a Change Request into data classes in which the 
details of the Change Request can be modified. The modified data classes
can then be submitted using one of the modification api functions 
to change a Change Request. The return result is an instance of
the L<apiObjectVector> class.

Note: Current transition choices are provided with this api function call.
See L<apiTransitions> class description.

 Parameters:
	apiUser aUser        : The current api user's login data.
	scalar  problemNumber: The Change Request ID/Problem Number ID to reference.
	scalar  attributeList: A delimited list of attributes. 
	                       [attribute_name|attribute_name|attribute_name|...]

 Returns: apiObjectVector
	the details of a change request in data format.

 Example:

	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "User", "\\\\your_hostname\\ccmdb\\cm_database");

		my $tmp = $csapi->GetCRData($aUser, "100", "problem_synopsis|problem_description");

		my $tmpstr = $tmp->getXmlData();
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<GetCRDataAllTransitions>

Load the details of a Change Request into data classes in which the 
details of the Change Request can be modified. The modified data classes
can then be submitted using one of the modification api functions 
to change a Change Request. The return result is an instance of
the L<apiObjectVector> class.
The AllTransitions function includes HIDDEN transitions.

Note: Current transition choices are provided with this api function call.
See L<apiTransitions> class description.

 Parameters:
	apiUser aUser        : The current api user's login data.
	scalar  problemNumber: The Change Request ID/Problem Number ID to reference.
	scalar  attributeList: A delimited list of attributes. 
	                       [attribute_name|attribute_name|attribute_name|...]

 Returns: apiObjectVector
	the details of a change request in data format.

 Example:

	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "User", "\\\\your_hostname\\ccmdb\\cm_database");

		my $tmp = $csapi->GetCRDataAllTransitions($aUser, "100", "problem_synopsis|problem_description");

		my $tmpstr = $tmp->getXmlData();
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<GetCV>

Obtains the four part name for a compver. 
The return result is an instance of the L<apiData> class.

 Parameters:
	apiUser aUser: The current api user's login data.
	scalar  cvid : The cvid of the compver to get.

 Returns: apiData
	Four part name: [subsys/cvtype/name/version], ex: "1/admin/cs/1"
	
 Example:

	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "User", "\\\\your_hostname\\ccmdb\\cm_database");

		my $tmp = $csapi->GetCV($aUser,"10159");

		print $tmp->getResponseData(); #ex: "3/admin/special/1"

		#Note: Result will be a four part name like: "[subsys/cvtype/name/version]", in string format.
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<GetDatabases>

Get the list of IBM Rational Change databases from the IBM Rational Change server.
The return result is an instance of the L<apiListObject> class.

 Parameters:
	apiUser aUser: The current api user's login data.

 Returns: apiListObject
	a list of the all the databases on the IBM Rational Change server.
	
 Example:

	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "User", "\\\\your_hostname\\ccmdb\\cm_database");

		my $tmp = $csapi->GetDatabases($aUser);

		my $tmpstr = $tmp->getXmlData();
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<GetCentralCrDatabase>

Gets the Central CR database path if server is in central server mode 
else returns an empty string.

 Parameters:
	apiUser aUser: The current api user's login data.

 Returns: apiData
	Central CR database path wrapped in apiData object.
	
 Example:

	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "User", "\\\\your_hostname\\ccmdb\\cm_database");

		my $tmp = $csapi->GetCentralCrDatabase($aUser);

		my $tmpstr = $tmp->getResponseData();
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<GetDatabaseSettings>

Gets the current settings for all database, including disabled databases.

 Parameters:
	apiUser user: The current API user's login data.

 Returns: List of hash references where each hash represents a database.
	Each hash has these keys: path, enabled, description, max_sessions, min_sessions,
	and users_per_session. All values are strings, except 'enabled', which is a truthy/falsey value.
 
 Example:
 
	my @databases = $csapi->GetDatabaseSettings($user);

	foreach my $db (@databases)
	{
		print "Path:          $db->{path} \n";
		print "Enabled:       " . ($db->{enabled} ? "yes\n" : "no\n");
		print "Label:         $db->{label} \n";
		print "Description:   $db->{description} \n";
		print "Max Sessions:  $db->{max_sessions} \n";
		print "Min Sessions:  $db->{min_sessions} \n";
		print "Users/Session: $db->{users_per_session} \n\n";
	}

=cut

##############################################################################

=item B<GetDataListBox>

Get the contents of a DataListbox.
The return result is an instance of the L<apiListObject> class.

 Parameters:
	apiUser aUser     : The current api user's login data.
	scalar  listObject: The DataListbox to obtain.

 Returns: apiListObject
	the contents of the DataListbox.
 
 Example:

	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "User", "\\\\your_hostname\\ccmdb\\cm_database");

		my $list = $csapi->GetDataListBox($aUser, "CRQUERYREPORTPREDEFINED");

		for(my $i=0; $i < $list->getListboxSize(); $i++)
		{
			my $label = $list->getLabel($i);
			my $value = $list->getValue($i);

			print "List label $i: " . $label . "\n";
			print "List value $i: " . $value . "\n";
		}
	};

	if ($@)
	{
		print $@;
	}

=cut

#############################################################################

=item B<GetDataListBox>

Get the contents of a DataListbox.
The return result is an instance of the L<apiListObject> class.

 Parameters:
	apiUser aUser     : The current api user's login data.
	scalar  listObject: The DataListbox to obtain.
	scalar  configType: The config entry to search for the list in.  
	
	Valid Config Types: These are defined in the Globals class.
        $self->{ALL}       		// User, Shared and System. Returns the first one found.
        $self->{USER_PROFILE}	// A single users profile data.
        $self->{SHARED_PROFILE} // The shared profile data.
	    $self->{SYSTEM_CONFIG}  // The system config data.

 Returns: apiListObject
	the contents of the DataListbox.
 
 Example:

	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $globals = new ChangeSynergy::Globals();

		my $aUser = $csapi->Login("u00001", "u00001", "User", "\\\\your_hostname\\ccmdb\\cm_database");

		my $list = $csapi->GetDataListBox($aUser, "CRQUERYREPORTUSERDEFINED", $globals->{USER_PROFILE});

		for(my $i=0; $i < $list->getListboxSize(); $i++)
		{
			my $label = $list->getLabel($i);
			my $value = $list->getValue($i);

			print "List label $i: " . $label . "\n";
			print "List value $i: " . $value . "\n";
		}
	};

	if ($@)
	{
		print $@;
	}

=cut

#############################################################################

=item B<GetDOORSAttribute>

Get a DOORS attribute tag value from a DOORS attachment object.

 Parameters:
	apiUser aUser          : A pointer to the current api user's login data.
	scalar  cvid           : The cvid of the source object to retrieve.
	scalar  attributeValue : The DOORS_ATTR:NAME value of the desired DOORS attribute.
	scalar  attributeTag   : The name of the tag to get information from 
	                         [NAME|TYPE|RANGE|VALUE|DEFAULT_AR|USER|GROUP].
	scalar  objectType     : The xml root tag [DYNAMIC_ATTRS_ORIG|DYNAMIC_ATTRS_NEW].
	scalar  charSet        : The character set to use. ie: "UTF-16LE", "iso-8859-1"

 Returns: apiData
	the return message from the server.
 
 Example:
	
	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "User", "\\\\your_hostname\\ccmdb\\cm_database");

		my $tmpstr = $csapi->GetDOORSAttribute($aUser, "10126", "the name", "VALUE", "DYNAMIC_ATTRS_ORIG", "UTF-16LE");
	};

	if ($@)
	{
		print $@;
	}

=cut

#############################################################################

=item B<GetDOORSAttribute52>

Get a DOORS attribute tag value from a DOORS attachment object.

 Parameters:
	apiUser aUser          : A pointer to the current api user's login data.
	scalar  cvid           : The cvid of the source object to retrieve.
	scalar  attributeValue : The DOORS_ATTR:NAME value of the desired DOORS attribute.
	scalar  attributeTag   : The name of the tag to get information from 
	                         [NAME|TYPE|RANGE|VALUE|DEFAULT_AR|USER|GROUP].
	scalar  objectType     : The xml root tag [DYNAMIC_ATTRS_ORIG|DYNAMIC_ATTRS_NEW].
	scalar  objectId       : The id of the requirement to find the attribute.
	scalar  charSet        : The character set to use. ie: "UTF-16LE", "iso-8859-1"

 Returns: apiData
	the return message from the server.
 
 Example:
	
	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "User", "\\\\your_hostname\\ccmdb\\cm_database");

		my $tmpstr = $csapi->GetDOORSAttribute($aUser, "10126", "the name", "VALUE", "DYNAMIC_ATTRS_ORIG", "98_req0000002d_1", "UTF-16LE");
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<getFolderSecurityRule>

Gets the folder security information for a given folder. The folder security information
consists of the name of the folder, the read security members and the write security members.
The return result is an instance of the L<FolderSecurityRule> class.

 Parameters:
	apiUser aUser      : The current api user's login data.
	scalar  folderName : The name of the folder to get the security for.
	scalar  objectType : The object type for the folder.
	scalar  formatType : The format type of the folder: report, query or report format.
	scalar  configType : The configuration location for the report.

 Returns: FolderSecurityRule
	a FolderSecurityRule object that represents the rule.
 
 Example:
 
	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "User", "\\\\angler\\ccmdb\\cm_database");
		my $globals = new ChangeSynergy::Globals();
		
		#Get the folder security rule for the "all" CR Shared query folder.
		my $folderRule = $csapi->getFolderSecurityRule($aUser, "", $globals->{PROBLEM_TYPE}, $globals->{QUERY},
						 $globals->{SHARED_PROFILE});
		
		print "Folder Name: " . $folderRule->getFolderName() . "\n";
		
		my @readMembers = $folderRule->getReadMembers();
	
		print "Current readers \n";
		
		foreach my $member (@readMembers)
		{
			print "Reader: '$member'\n";
		}
		
		print "Finished printing readers: \n";
		
		my @writeMembers = $folderRule->getWriteMembers();
	
		print "Current writers: \n";
		
		foreach my $member (@writeMembers)
		{
			print "Writer: '$member'\n";
		}
		
		print "Finished printing writers: \n";
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<GetHosts>

Get the list of IBM Rational Change hosts.
The return result is an instance of the L<apiListObject> class.

 Parameters:
	apiUser aUser: The current api user's login data.

 Returns: apiListObject
	a list of all the hosts on the IBM Rational Change server
 
 Example:
 
	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "User", "\\\\your_hostname\\ccmdb\\cm_database");

		my $tmp = $csapi->GetHosts($aUser);

		my $tmpstr = $tmp->getXmlData();
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<GetHostSettings>

Gets the current settings for all hosts, including disabled hosts.

 Parameters:
	apiUser user: The current API user's login data.

 Returns: List of hash references where each hash represents a host.
	Each hash has these keys: hostname, type, enabled, description, max_sessions, priority,
	and threshold. All values are strings, except 'enabled', which is a truthy/falsey value.
	Host types are "NT" or "UNIX".
 
 Example:
 
	my @hosts = $csapi->GetHostSettings($user);
	
	foreach my $host (@hosts)
	{
		print "Hostname:     $host->{hostname} \n";
		print "Type:         $host->{type} \n";
		print "Enabled:      " . ($host->{enabled} ? "yes\n" : "no\n");
		print "Description:  $host->{description} \n";
		print "Max Sessions: $host->{max_sessions} \n";
		print "Priority:     $host->{priority} \n";
		print "Threshold:    $host->{threshold} \n\n";
	}

=cut

##############################################################################

=item B<GetList>

Get the contents of a List.
The return result is an instance of the L<apiListObject> class.

 Parameters:
	apiUser aUser     : The current api user's login data.
	scalar  listObject: The List to obtain.

 Returns: apiListObject
	the contents of the List.
 
 Example:

	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "User", "\\\\your_hostname\\ccmdb\\cm_database");

		my $list = $csapi->GetList($aUser, "CRQueryReportPreDefined");

		for(my $i=0; $i < $list->getListboxSize(); $i++)
		{
			my $label = $list->getLabel($i);
			my $value = $list->getValue($i);

			print "List label $i: " . $label . "\n";
			print "List value $i: " . $value . "\n";
		}
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<GetList>

Get the contents of a List.
The return result is an instance of the L<apiListObject> class.

 Parameters:
	apiUser aUser     : The current api user's login data.
	scalar  listObject: The List to obtain.
	scalar  configType: The config entry to search for the list in.  
	
	Valid Config Types: These are defined in the Globals class.
        $self->{ALL}       		// User, Shared and System. Returns the first one found.
        $self->{USER_PROFILE}	// A single users profile data.
        $self->{SHARED_PROFILE} // The shared profile data.
	    $self->{SYSTEM_CONFIG}  // The system config data.

 Returns: apiListObject
	the contents of the List.
 
 Example:

	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $globals = new ChangeSynergy::Globals();

		my $aUser = $csapi->Login("u00001", "u00001", "User", "\\\\your_hostname\\ccmdb\\cm_database");

		my $list  = $csapi->GetList($aUser, "CRQUERYUSERDEFINED", $globals->{USER_PROFILE});

		for(my $i=0; $i < $list->getListboxSize(); $i++)
		{
			my $label = $list->getLabel($i);
			my $value = $list->getValue($i);

			print "List label $i: " . $label . "\n";
			print "List value $i: " . $value . "\n";
		}
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<GetListBox>

Get the contents of a Listbox.
The return result is an instance of the L<apiListObject> class.

 Parameters:
	apiUser aUser     : The current api user's login data.
	scalar  listObject: The Listbox to obtain.

 Returns: apiListObject
	the contents of the Listbox.
 
 Example:

	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "User", "\\\\your_hostname\\ccmdb\\cm_database");

		my $list  = $csapi->GetListBox($aUser, "severity");

		for(my $i=0; $i < $list->getListboxSize(); $i++)
		{
			my $label = $list->getLabel($i);
			my $value = $list->getValue($i);

			print "Listbox label $i: " . $label . "\n";
			print "Listbox value $i: " . $value . "\n";
		}
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<GetListBox>

Get the contents of a Listbox.
The return result is an instance of the L<apiListObject> class.

 Parameters:
	apiUser aUser     : The current api user's login data.
	scalar  listObject: The Listbox to obtain.
	scalar  configType: The config entry to search for the listbox in.  
	
	Valid Config Types: These are defined in the Globals class.
        $self->{ALL}       		// User, Shared and System. Returns the first one found.
        $self->{USER_PROFILE}	// A single users profile data.
        $self->{SHARED_PROFILE} // The shared profile data.
	    $self->{SYSTEM_CONFIG}  // The system config data.

 Returns: apiListObject
	the contents of the Listbox.
 
 Example:

	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $globals = new ChangeSynergy::Globals();

		my $aUser = $csapi->Login("u00001", "u00001", "User", "\\\\your_hostname\\ccmdb\\cm_database");

		my $tmp = $csapi->GetListBox($aUser, "severity", $globals->{USER_PROFILE});

		for(my $i=0; $i < $list->getListboxSize(); $i++)
		{
			my $label = $list->getLabel($i);
			my $value = $list->getValue($i);

			print "Listbox label $i: " . $label . "\n";
			print "Listbox value $i: " . $value . "\n";
		}
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<GetListBoxDefaultValue>

Get the Listbox Default Value.
The return result is an instance of the L<apiData> class.

 Parameters:
	apiUser aUser   : The current api user's login data.              

 Returns: apiData
 	The Listbox default value set in the configuration file.

 Example:

	my $csapi = new ChangeSynergy::csapi();

     eval
     {
            $csapi->setUpConnection("http://your_hostname:port/your_context");

            my $aUser = $csapi->Login("u00001", "u00001", "User", "\\\\your_hostname\\ccmdb\\cm_database"); 

            my $tmpStr = $csapi->GetListBoxDefaultValue($aUser);

            print $tmpStr->getResponseData();
      };

      if ($@)
      {
            print $@;
      }

=cut

##############################################################################

=item B<GetNewCV>

Given a four part name, returns the cvid of the compver. 
The return result is an instance of the L<apiData> class.

 Parameters:
	apiUser aUser   : The current api user's login data.
	scalar  subsys  : The subsys value of the desired four part compver name.
	scalar  cvtype  : The cvtype value of the desired four part compver name.
	scalar  name    : The name value of the desired four part compver name.
	scalar  version : The version value of the desired four part compver name.

 Returns: apiData
	Cvid string value: "CV: 5_digit_integer_value_of_compver", ex: "CV: 12345"
	
 Example:

	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "User", "\\\\your_hostname\\ccmdb\\cm_database");

		my $tmp = $csapi->GetNewCV($aUser, "3", "admin", "special", "1");

		print $tmp->getResponseData(); #ex: "CV: 12345"

		#Note: Result will be like: "CV: 5_digit_integer_value_of_compver", in string format.
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<GetObjectData>

Load the details of a compver into data classes in which the details of the
compver can be modified or displayed. The modified data classes can be
submitted using one of the modification api functions.  The return
result is an instance of the L<apiObjectVector> class.

 Parameters:
	apiUser aUser     : The current api user's login data.
	scalar  cvid      : The cvid of a compver.
	scalar  AttrList  : A delimited list of attributes. [attribute_name|attribute_name|attribute_name|...]

Returns: apiObjectVector
	The contents of the attributes requested.

 Example:

	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "User", "\\\\your_hostname\\ccmdb\\cm_database");

		my $objVector = $csapi->GetObjectData($aUser, $cv1, "create_time|cvtype|is_asm|is_model|is_versioned|modify_time|name|owner|status|subsystem|version");

		my $i;
		my $j = $objVector->getDataSize();

		for($i=0; $i < $j; $i++)
		{
			print "Name : " . $objVector->getDataObject($i)->getName() . "\n";
			print "Value: " . $objVector->getDataObject($i)->getValue() . "\n";
		}
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<GetQuery>

Get the contents of a Query.
The return result is an instance of the L<apiListObject> class.

 Parameters:
	apiUser aUser     : The current api user's login data.
	scalar  listObject: The Query to obtain.

 Returns: apiListObject
	the contents of the Query.
 
 Example:

	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "User", "\\\\your_hostname\\ccmdb\\cm_database");

		my $query = $csapi->GetQuery($aUser, "All CRs");

		print "getName       : " . $query->getName() . "\n";
		print "getQueryString: " . $query->getQueryString() . "\n";
		print "getDateLastRun: " . $query->getDateLastRun() . "\n";
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<GetQuery>

Get the contents of a Query.
The return result is an instance of the L<apiListObject> class.

 Parameters:
	apiUser aUser     : The current api user's login data.
	scalar  listObject: The Query to obtain.
	scalar  configType: The config entry to search for the query in.  
	
	Valid Config Types: These are defined in the Globals class.
		$self->{ALL}       		// User, Shared and System. Returns the first one found.
		$self->{USER_PROFILE}	// A single users profile data.
		$self->{SHARED_PROFILE} // The shared profile data.
		$self->{SYSTEM_CONFIG}  // The system config data.

 Returns: apiListObject
	the contents of the Query.
 
 Example:

	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $globals = new ChangeSynergy::Globals();

		my $aUser = $csapi->Login("u00001", "u00001", "User", "\\\\your_hostname\\ccmdb\\cm_database");

		my $query = $csapi->GetQuery($aUser, "Test Query", $globals->{USER_PROFILE});

		print "getName       : " . $query->getName() . "\n";
		print "getQueryString: " . $query->getQueryString() . "\n";
		print "getDateLastRun: " . $query->getDateLastRun() . "\n";

	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<GetReport>

Get the contents of a Report.
The return result is an instance of the L<apiListObject> class.

 Parameters:
	apiUser aUser     : The current api user's login data.
	scalar  listObject: The Report to obtain.

 Returns: apiListObject
	the contents of the Report.
 
 Example:

	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "User", "\\\\your_hostname\\ccmdb\\cm_database");

		my $report = $csapi->GetReport($aUser, "Basic Summary");

		print "getName        : " . $report->getName()        . "\n";
		print "getExportForm  : " . $report->getExportForm () . "\n";
		print "getQueryName   : " . $report->getQueryName()   . "\n";
		print "getQueryString : " . $report->getQueryString() . "\n";
		print "getDateLastRun : " . $report->getDateLastRun() . "\n";
	
		for(my $i = 0; $i < $report->getSubreportSize(); $i++)
		{
			print "   Subreport $i \n";
			print "		getSubreportName    : "  . $report->getSubreportName($i)     . "\n";
			print "		getSubreportRelation: "  . $report->getSubreportRelation($i) . "\n";
			print "		getSubreportType    : "  . $report->getSubreportType($i)     . "\n";
		}
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<GetReport>

Get the contents of a Report.
The return result is an instance of the L<apiListObject> class.

 Parameters:
	apiUser aUser     : The current api user's login data.
	scalar  listObject: The Report to obtain.
	scalar  configType: The config entry to search for the report in.  
	
	Valid Config Types: These are defined in the Globals class.
        $self->{ALL}       		// User, Shared and System. Returns the first one found.
        $self->{USER_PROFILE}	// A single users profile data.
        $self->{SHARED_PROFILE} // The shared profile data.
	    $self->{SYSTEM_CONFIG}  // The system config data.

 Returns: apiListObject
	the contents of the Report.
 
 Example:

	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $globals = new ChangeSynergy::Globals();

		my $aUser = $csapi->Login("u00001", "u00001", "User", "\\\\your_hostname\\ccmdb\\cm_database");

		my $report = $csapi->GetReport($aUser, "Test Format", $globals->{USER_PROFILE});

		print "getName        : " . $report->getName()        . "\n";
		print "getExportForm  : " . $report->getExportForm () . "\n";
		print "getQueryName   : " . $report->getQueryName()   . "\n";
		print "getQueryString : " . $report->getQueryString() . "\n";
		print "getDateLastRun : " . $report->getDateLastRun() . "\n";
	
		for(my $i = 0; $i < $report->getSubreportSize(); $i++)
		{
			print "   Subreport $i \n";
			print "		getSubreportName    : "  . $report->getSubreportName($i)     . "\n";
			print "		getSubreportRelation: "  . $report->getSubreportRelation($i) . "\n";
			print "		getSubreportType    : "  . $report->getSubreportType($i)     . "\n";
		}
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<GetTaskData>

Load the details of a Task into data classes in which the details of
the Task can be modified. The modified data classes can then be
submitted using one of the modification api functions to change a Task.
The return result is an instance of the L<apiObjectVector> class.

 Parameters:
	apiUser aUser        : The current api user's login data.
	scalar  taskNumber   : The Task ID to reference.
	scalar  attributeList: A delimited list of attributes. 
	                       [attribute_name|attribute_name|attribute_name|...]

 Returns: apiObjectVector
	the details of a task in data format.

 Example:

	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "User", "\\\\your_hostname\\ccmdb\\cm_database");

		my $tmp = $csapi->GetTaskData($aUser, "10", "task_synopsis|task_description|priority");

		my $tmpstr = $tmp->getXmlData();
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################


=item B<GetUserPreference>

Get a user preference or profile value for a specified user.
The return result is an instance of the L<apiData> class.

 Defined User Preference Attributes:
	user_name                : The users full name.
	user_first_name          : The users first name.
	user_last_name           : The users last name.
	user_address             : The address listed for the user.
	user_company             : The company the user works for.
	user_email               : The email address for the user.
	user_fax                 : The fax number for the user
	user_phone               : The telelphone number for the user.
	user_fontsize            : The fontsize the user has defined.
	user_read_security_value : The read security value for the user.

 Parameters:
	apiUser aUser     : The current api user's login data.
	scalar  userName  : The name of the user to get information on.
	scalar  prefName  : The name of the preference to retrieve.

 Returns: apiData
	the value of the user preference requested.
 
 Example:

	my $csapi = new ChangeSynergy::csapi();
	
	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "User", "\\\\your_hostname\\ccmdb\\cm_database");


		my $tmp = $csapi->GetUserPreference($aUser, "u00001", "user_email");
	
		my $tmpstr = $tmp->getResponseData();
	};

	if ($@)
	{
		print $@;
	}

=cut


##############################################################################

=item B<GetValueListBox>

Get the contents of a ValueListbox.
The return result is an instance of the L<apiListObject> class.

 Parameters:
	apiUser aUser     : The current api user's login data.
	scalar  listObject: The ValueListbox to obtain.

 Returns: apiListObject
	the contents of the valuelistbox.
 
 Example:

	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "User", "\\\\your_hostname\\ccmdb\\cm_database");

		my $list = $csapi->GetValueListBox($aUser, "date_keywords");

		for(my $i=0; $i < $list->getListboxSize(); $i++)
		{
			my $label = $list->getLabel($i);
			my $value = $list->getValue($i);

			print "GetValueListBox label $i: " . $label . "\n";
			print "GetValueListBox value $i: " . $value . "\n";		
		}
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<GetValueListBox>

Get the contents of a ValueListbox.
The return result is an instance of the L<apiListObject> class.

 Parameters:
	apiUser aUser     : The current api user's login data.
	scalar  listObject: The ValueListbox to obtain.
	scalar  configType: The config entry to search for the valueListbox in.  
	
	Valid Config Types: These are defined in the Globals class.
        $self->{ALL}       		// User, Shared and System. Returns the first one found.
        $self->{USER_PROFILE}	// A single users profile data.
        $self->{SHARED_PROFILE} // The shared profile data.
	    $self->{SYSTEM_CONFIG}  // The system config data.

 Returns: apiListObject
	the contents of the valuelistbox.
 
 Example:

	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $globals = new ChangeSynergy::Globals();

		my $aUser = $csapi->Login("u00001", "u00001", "User", "\\\\your_hostname\\ccmdb\\cm_database");

		my $list = $csapi->GetValueListBox($aUser, "user_defined_valuelistbox", $globals->{USER_PROFILE});

		for(my $i=0; $i < $list->getListboxSize(); $i++)
		{
			my $label = $list->getLabel($i);
			my $value = $list->getValue($i);

			print "GetValueListBox label $i: " . $label . "\n";
			print "GetValueListBox value $i: " . $value . "\n";		
		}
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<ImmediateQueryHtml>

Run a IBM Rational Change report, and wait for it to complete. This
api does not respond with a polling template. This api should
be used for running small reports. The return result is an 
instance of the L<apiData> class.

 Note: The return value is a complete HTML page. <HTML>...</HTML>
	   The return value can be saved as a .html file, or loaded
	   into a browser window/control.

 Parameters:
	apiUser aUser      : The current api user's login data.
	scalar  reportName : A IBM Rational Change report name 
						 (CCM_REPORT][NAME]report name[/NAME]...[/CCM_REPORT]).
	scalar  queryString: A valid IBM Rational Synergy query string. 
	scalar  queryName  : A IBM Rational Change query name 
						 ([CCM_QUERY][NAME]query name[/NAME]...[/CCM_QUERY]).
	scalar  reportTitle: A title for this instance of the report.

 Returns: apiData
	the requested immediate query as an HTML page.

 Example:

	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "User", "\\\\your_hostname\\ccmdb\\cm_database");
	
		my $tmpstr = $csapi->ImmediateQueryHtml($aUser, "Basic Summary", 
												"(submitter='cschuffe') and (cvtype='problem')",
												 undef, undef);
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<ImmediateReportHtml>

Run a IBM Rational Change report, and wait for it to complete. This
api does not respond with a polling template. This api should
be used for running small reports. The return result is an 
instance of the L<apiData> class.

 Note: The return value is a complete HTML page. <HTML>...</HTML>
	   The return value can be saved as a .html file, or loaded
	   into a browser window/control.

 Parameters:
	apiUser aUser      : The current api user's login data.
	scalar  reportName : A IBM Rational Change report name 
						 ([CCM_REPORT][NAME]report name[/NAME]...[/CCM_REPORT]).
	scalar  reportTitle: A title for this instance of the report.

 Returns: apiData
	the requested immediate query as an HTML page.

 Example:

	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "User", "\\\\your_hostname\\ccmdb\\cm_database");
	
		my $tmpstr = $csapi->ImmediateReportHtml($aUser, "Basic Summary", "Basic Summary Report");
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<importAReport>

Import a Change report that was exported using either the exportAReport or exportReportsFromFolder
APIs. If the name of the report to import already exists on the server then this method will fail and
throw an exception.
The return result is an instance of the L<apiData> class.

 Parameters:
	apiUser aUser          : The current api user's login data.
	ReportEntry reportEntry: A report entry that contains all the information about a report.
	scalar  objectType     : The object type for the report.
	scalar  configType     : The configuration location for the report, valid types are user and shared only.

 Valid object types (Constants defiend in Globals.pm):
        PROBLEM_TYPE
        TASK_TYPE
        OBJECT_TYPE
 
 Valid configuration types (Constants defiend in Globals.pm):
        SHARED_PROFILE
        USER_PROFILE

 Returns: apiData
	information on if the import was successful or not.
 
 Example 1:

	#Create a copy of an existing report and change the query.
	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "User", "\\\\machine\\ccmdb\\cm_database");
		my $globals = new ChangeSynergy::Globals();
		
		#Export the 'Column' report from the system config data.
		my $reportEntry = $csapi->exportAReport($aUser, "Column",  $globals->{PROBLEM_TYPE}, $globals->{SYSTEM_CONFIG});
		
		#Change the name
		$reportEntry->setName("My column report");
		
		#Set a new query string in the query entry.
		$reportEntry->getQueryEntry->setQueryString("(cvtype='problem') and (crstatus='assigned')");
		
		#Get the subReports from the report entry.
		my @subReports = $reportEntry->getSubReports();
		
		#The column output only has a single subreport definition, CCM_PROBLEM.
		my $subReport = $subReports[0];
		
		#Get the original attributes and append submitter and severity as new attributes, must be in config file format.
		$subReport->setAttributes($subReport->getAttributes() . "|submitter:3:false|severity:4:false");
	
		#Import the report back to the server.
		my $result = $csapi->importAReport($aUser, $reportEntry, $globals->{PROBLEM_TYPE}, $globals->{SHARED_PROFILE});
	};

	if ($@)
	{
		print $@;
	}
	
Example 2:

	#Import a report from a file.
	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "User", "\\\\machine\\ccmdb\\cm_database");

		#Open a file named 'report.xml' and read in all the contents.
		my $file = "report.xml";
	 	open (INPUTFILE, "$file") or die "Could not open the file!";
		my $filecontents = "";
		my $buffer = "";
		
		while ($buffer = readline *INPUTFILE)
		{
			$filecontents .= $buffer;
		}
		
		close(INPUTFILE);
		
		#Create a new instance of the ReportEntryFactory so we can create our new data from the XML data read from file.
		my $reportEntryFactory = new ChangeSynergy::ReportEntryFactory();
		my $reportEntry = $reportEntryFactory->createReportEntryFromXml($filecontents);
		
		#Import the report back to the server.
		my $result = $csapi->importAReport($aUser, $reportEntry, $globals->{PROBLEM_TYPE}, $globals->{SHARED_PROFILE});
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<InstallAPackage>

Install a IBM Rational Change package. The return result is an 
instance of the L<apiData> class.

 Parameters:
	apiUser aUser       : The current api user's login data.
	scalar  packageName : The name of the package to install.

 Returns: apiData
	the results only if the package install was successful.

 Example:

	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "Admin", "\\\\your_hostname\\ccmdb\\cm_database");
	
		my $results = $csapi->InstallAPackage($aUser, "dev_process");
		
		print $results->getResponseData();
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<LoadAllConfigurationFiles>

Loads all configuration data files on the IBM Rational Change server.
The return result is an instance of the L<apiData> class.

 Parameters:
	apiUser aUser: The current api user's login data.

 Returns: apiData
	the return message from the server.
 
 Example:

	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "Admin", "\\\\your_hostname\\ccmdb\\cm_database");

		my $tmpstr = $csapi->LoadAllConfigurationFiles($aUser);
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<LoadConfigurationData>

Load configuration data on the IBM Rational Change server.
The return result is an instance of the L<apiData> class.

 Parameters:
	apiUser aUser: The current api user's login data.

 Returns: apiData
	the return message from the server.
 
 Example:

	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "Admin", "\\\\your_hostname\\ccmdb\\cm_database");

		my $tmpstr = $csapi->LoadConfigurationData($aUser);
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<LoadConfigurationFile>

Loads the specified configuration data file on the IBM Rational Change server.
The pt.cfg, admin_framework.cfg, user_framework.cfg, and task_framework.cfg
configuration files are not allowed. The specified file must reside
in the "CHANGE_APP_HOME/WEB-INF/wsconfig" directory.
The return result is an instance of the L<apiData> class.

 Parameters:
	apiUser aUser: The current api user's login data.

 Returns: apiData
	the return message from the server.
 
 Example:

	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "Admin", "\\\\your_hostname\\ccmdb\\cm_database");

		my $tmpstr = $csapi->LoadConfigurationFile($aUser, "my_config_file.cfg");
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<LoadDatabaseListboxes>

All listboxes that get their values from a database will be reloaded.
The return result is an instance of the L<apiData> class.

 Parameters:
	apiUser aUser: The current api user's login data.

 Returns: apiData
	the return message from the server.
 
 Example:

	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "Admin", "\\\\your_hostname\\ccmdb\\cm_database");

		my $tmpstr = $csapi->LoadDatabaseListboxes($aUser);
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<listFolders>

Returns a list of all query, report format or report folders under a top level folder.
The return result is an instance of the L<apiListObject> class.

 Parameters:
	apiUser aUser        : The current api user's login data.
	scalar  objectType   : The object type for the root folder.
	scalar  formatType   : The format type of the root folder: report, query or report format.
	scalar  configType   : The configuration location for the root folder.

 Valid object types (Constants defiend in Globals.pm):
        PROBLEM_TYPE
        TASK_TYPE
        OBJECT_TYPE

 Valid format types (Constants defiend in Globals.pm):
 		QUERY
        REPORT
        REPORT_FORMAT
 
 Valid configuration types (Constants defiend in Globals.pm):
        SHARED_PROFILE
        SYSTEM_CONFIG
        USER_PROFILE
        
 Returns: apiListObject
	the list of folders under a root folder.
 
 Example:
	
	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "Admin", "\\\\machine\\ccmdb\\cm_database");
		
		my $globals = new ChangeSynergy::Globals();
		
		#Get a list of all the shared CR report folders.
		my $folders = $csapi->listFolders($aUser, $globals->{PROBLEM_TYPE}, $globals->{REPORT}, $globals->{SHARED_PROFILE});

		for (my $i = 0; $i < $folders->getListSize(); $i++)
		{
			print $folders->getLabel($i) . "\n";
		}
	};
	
	if ($@)
	{
		print $@;
	}

=cut

#############################################################################

=item B<LoadFormHtml>

Load any IBM Rational Change template that does not require any other data
other than the template name and type. The return result is an instance 
of the L<apiData> class.

 Note: The return value is a complete HTML page. <HTML>...</HTML>
       The return value can be saved as a .html file, or loaded into 
	   a browser window/control.

 Parameters:
	apiUser aUser       : The current api user's login data.
	scalar  templateName: The name of the IBM Rational Change template to load 
	                      ([CCM_TEMPLATE][NAME]template name[/NAME]...[/CCM_TEMPLATE]).
	scalar  templateType: The type ([ONLOAD_ACTION]type[/ONLOAD_ACTION]) of the 
	                      IBM Rational Change template to load.
 
 Returns: apiData
	the html template from the server.

 Example

	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "User", "\\\\your_hostname\\ccmdb\\cm_database");

		my $tmpstr = $csapi->LoadFormHtml($aUser, "SearchTipsWindow", "workspace_form");
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<LoadFormUrl>

Load any IBM Rational Change template that does not require any other data 
other than the template name and type. The return result is an instance of 
the L<apiData> class.

 Note: The return value is a complete URL address.
       The return value can be saved as a link, or loaded
       into a browser window/control.

 Parameters:
	apiUser aUser       : The current api user's login data.
	scalar  templateName: The name of the IBM Rational Change template to load 
	                      ([CCM_TEMPLATE][NAME]template name[/NAME]...[/CCM_TEMPLATE]).
	scalar  templateType: The type ([ONLOAD_ACTION]type[/ONLOAD_ACTION]) of the 
	                      IBM Rational Change template to load.
 
 Returns: apiData
	the URL address for the desired template.

 Example

	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "User", "\\\\your_hostname\\ccmdb\\cm_database");

		my $tmpstr = $csapi->LoadFormUrl($aUser, "SearchTipsWindow", "workspace_form");
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<LoadFrameSetHtml>

Load a IBM Rational Change "frameset_form" template. The IBM Rational Change server
parses the template name that was provided. The other function variables
are available to URLs contained in the frameset form definition.
The return result is an instance of the L<apiData> class.

 Note: The return value is a complete HTML page. <HTML>...</HTML>
	   The return value can be saved as a .html file, or loaded
	   into a browser window/control.

 Parameters:
	apiUser aUser       : The current api user's login data.
	scalar templateName : The name of the IBM Rational Change template to load
						  ([CCM_TEMPLATE][NAME]template name[/NAME]...[/CCM_TEMPLATE]).
	scalar taskNumber   : The Task ID to reference.
	scalar taskStatus   : The referenced Task's status value.
	scalar problemNumber: The Change Request ID/Problem Number ID to reference.
	scalar problemStatus: The referenced CR's crstatus value.
	scalar cvid         : The CVID of a object to reference.
	scalar externalData : A string of XML data to pass to a submit request.

 Format of External Data XML:
 
 <EXTERNAL_CONTEXT_DATA>
 	<ATTRIBUTE NAME="attribute_name">your value</ATTRIBUTE>
 	<ATTRIBUTE NAME="attribute_name">your value</ATTRIBUTE>
 	<ATTRIBUTE NAME="attribute_name">your value</ATTRIBUTE>
 	.
 	.
 	.
 </EXTERNAL_CONTEXT_DATA>
 
 Returns: apiData
	the requested frameset as an HTML page.

 Example:

	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "User", "\\\\your_hostname\\ccmdb\\cm_database");

		my $tmpstr = $csapi->LoadFrameSetHtml($aUser, "ChangeSynergyShowDetails", undef, 
											  undef, "1347", undef, undef, undef);
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<LoadFrameSetUrl>

Load a IBM Rational Change "frameset_form" template. The IBM Rational Change server
parses the template name that was provided. The other function variables
are available to URLs contained in the frameset form definition.
The return result is an instance of the L<apiData> class.

 Note: The return value is a complete URL address.
	   The return value can be saved as a link, or loaded
	   into a browser window/control.

 Parameters:
	apiUser aUser       : The current api user's login data.
	scalar templateName : The name of the IBM Rational Change template to load
						  ([CCM_TEMPLATE][NAME]template name[/NAME]...[/CCM_TEMPLATE]).
	scalar taskNumber   : The Task ID to reference.
	scalar taskStatus   : The referenced Task's status value.
	scalar problemNumber: The Change Request ID/Problem Number ID to reference.
	scalar problemStatus: The referenced CR's crstatus value.
	scalar cvid         : The CVID of a object to reference.
	scalar externalData : A string of XML data to pass to a submit request.

 Format of External Data XML:
 
 <EXTERNAL_CONTEXT_DATA>
 	<ATTRIBUTE NAME="attribute_name">your value</ATTRIBUTE>
 	<ATTRIBUTE NAME="attribute_name">your value</ATTRIBUTE>
 	<ATTRIBUTE NAME="attribute_name">your value</ATTRIBUTE>
 	.
 	.
 	.
 </EXTERNAL_CONTEXT_DATA>
 
 Returns: apiData
	the requested frameset as URL.

 Example:

	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "User", "\\\\your_hostname\\ccmdb\\cm_database");

		my $tmpstr = $csapi->LoadFrameSetUrl($aUser, "ChangeSynergyShowDetails", undef, 
											  undef, "1347", undef, undef, undef);
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<LoadMergeConfigurationFiles>

Loads all configuration data files from the [CFG_MERGE][/CFG_MERGE] on the IBM Rational Change server.
The return result is an instance of the L<apiData> class.

 Parameters:
	apiUser aUser: The current api user's login data.

 Returns: apiData
	the return message from the server.
 
 Example:

	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "Admin", "\\\\your_hostname\\ccmdb\\cm_database");

		my $tmpstr = $csapi->LoadMergeConfigurationFiles($aUser);
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<Login>

Login to a IBM Rational Change server as a specific user and connect to a 
specific IBM Rational Synergy database. The return result is an instance of the L<apiUser> class.

 Parameters:
	scalar user    : The name of the user.
	scalar password: The password for the user.
	scalar role    : The role for the user.
	scalar database: The IBM Rational Synergy database path for the user.

 Returns: apiUser
	a new instance of a apiUser class with the specified information.

 Example:

	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "User", "\\\\your_hostname\\ccmdb\\cm_database");
	};

	if ($@)
	{
		print $@;
	}

=cut

###############################################################################

=item B<Logout>

Logs out a user by releasing their checked out license immediately 
(without any license linger time).

 Parameters:
	apiUser aUser        : The current api user's login data.
 
 Returns: apiData
	the return message from the server.

 Example:

	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "User", "\\\\your_hostname\\ccmdb\\cm_database");

		my $tmp = $csapi->Logout($aUser);
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<ModifyCR>

Apply the modified Change Request data. Only data objects that have been
flagged as modified are submitted to the IBM Rational Change server.
The attributes problem_number, modify_time, and cvid, should not be
altered. The api classes will automatically process these attributes when needed.
The return result is an instance of the L<apiData> class.

Note: The apiObjectData's member method setValue("") will automatically set
the modified flag when invoked.

 Parameters:
	apiUser         aUser: The current api user's login data.
	apiObjectVector data : The data to be processed by the api function.

 Returns: apiData
	results only if the modify was successful
 
 Example:
 
	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "User", "\\\\your_hostname\\ccmdb\\cm_database");

		my $tmp = $csapi->AttributeModifyCRData($aUser, "100", "crstatus");
		or
		my $tmp = $csapi->AttributeModifyCRData($aUser, "100");
		or
		my $tmp = $csapi->ModifyCRData($aUser, "100", "CRDetail");
		or
		my $tmp = $csapi->GetCRData($aUser, "100", "problem_synopsis|problem_description|keyword");
		
		$tmp->getDataObjectByName("problem_synopsis")->setValue("I modified the synopsis through the csapi...");
		$tmp->getDataObjectByName("problem_description")->setValue("I modified the description through the csapi...");
		$tmp->getDataObjectByName("keyword")->setValue("csapi");

		my $tmpstr = $csapi->ModifyCR($aUser, $tmp);

	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<ModifyCRData>

Load the details of a Change Request into data classes in which the 
details of the Change Request can be modified. The modified data classes
can then be submitted using one of the modification api functions 
to change a Change Request. The return result is an instance of
the L<apiObjectVector> class.


Note: Current transition choices are provided with this api function call.
See L<apiTransitions> class description.

 Parameters:
	apiUser aUser        : The current api user's login data.
	scalar  problemNumber: The Change Request ID/Problem Number ID to reference.
	scalar  templateName : The name of the IBM Rational Change template to load 
	                       ([CCM_TEMPLATE][NAME]template name[/NAME]...[/CCM_TEMPLATE]).

 Returns: apiObjectVector
	the details of a change request in data format.

 Example:

	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "User", "\\\\your_hostname\\ccmdb\\cm_database");

		my $tmp = $csapi->ModifyCRData($aUser, "100", "CRDetail");

		my $tmpstr = $tmp->getXmlData();
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<ModifyObjectAttributes>

Modifies existing attribute(s) of compver with name "your name value." The value(s) given
to the attribute must be provided. This operation also updates the compver's modify_time 
attribute. The return result is an instance of the L<apiData> class.

 Parameters:
	apiUser         aUser       : The current api user's login data.
	scalar          cvidList    : A "|" pipe delimited list of cvids to be affected, or a single cvid.
	apiObjectVector attrData    : The data to be processed by the api function.
 
 Returns: apiData
	The return message from the server.

 Example:

	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "User", "\\\\your_hostname\\ccmdb\\cm_database");

		my $attrData = new ChangeSynergy::apiObjectVector();

		my $objData = new ChangeSynergy::apiObjectData();
		$objData->setName("attribute_a");
		$objData->setValue("Linux");
		$attrData->addDataObject($objData);

		my $objData = new ChangeSynergy::apiObjectData();
		$objData->setName("attribute_b");
		$objData->setValue("true");
		$attrData->addDataObject($objData);

		my $objData = new ChangeSynergy::apiObjectData();
		$objData->setName("attribute_c");
		$objData->setValue("777");
		$attrData->addDataObject($objData);

		my $tmp = $csapi->ModifyObjectAttributes($aUser, "10156|10157|10158|10159|10160", $attrData)

		print $tmp->getResponseData();
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<ModifyTask>

Apply the modified Task data. Only data objects that have been flagged
as modified are submitted to the IBM Rational Change server. The attributes
task_number, modify_time, and cvid, should not be altered. The api
classes will automatically process these attributes when needed.
The return result is an instance of the L<apiData> class.

Note: The L<apiObjectData>'s member method setValue("") will automatically set
the modified flag when invoked.

 Parameters:
	apiUser         aUser: The current api user's login data.
	apiObjectVector data : The data to be processed by the api function.

 Returns: apiData
	results only if the modify was successful

 Example:
 
	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "User", "\\\\your_hostname\\ccmdb\\cm_database");

		my $tmp = $csapi->ModifyTaskData($aUser, "10", "TaskDetails");
		or
		my $tmp = $csapi->GetTaskData($aUser, "10", "task_synopsis|task_description|priority");
		
		$tmp->getDataObjectByName("task_synopsis")->setValue("I modified the synopsis through the csapi...");
		$tmp->getDataObjectByName("task_description")->setValue("I modified the description through the csapi...");
		$tmp->getDataObjectByName("priority")->setValue("high");

		my $tmpstr = $csapi->ModifyTask($aUser, $tmp);
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<ModifyTaskData>

Load the details of a Task into data classes in which the details of
the Task can be modified. The modified data classes can then be 
submitted using one of the modification api functions to change a Task.
The return result is an instance of the L<apiObjectVector> class.


 Parameters:
	apiUser aUser       : The current api user's login data.
	scalar  taskNumber  : The Task ID to reference.
	scalar  templateName: The name of the IBM Rational Change template to load
	                      ([CCM_TEMPLATE][NAME]template name[/NAME]...[/CCM_TEMPLATE]).
 
 Returns: apiObjectVector
	the details of a task in data format

 Example:

	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "User", "\\\\your_hostname\\ccmdb\\cm_database");

		my $tmp = $csapi->ModifyTaskData($aUser, "10", "TaskDetails");

		my $tmpstr = $tmp->getXmlData();
	};

	if ($@)
	{
		print $@;
	}

=cut

#############################################################################

=item B<moveFolderMembers>

Moves members of a query, report format or report folder to a new folder of the same type. The server
will find the current folder the reports are a member of an move them to the newly specified folder. All
members in the list must exist for any move to be completed.
The return result is an instance of the L<apiData> class.

 Parameters:
	apiUser aUser        : The current api user's login data.
	scalar  folderName   : The name of the folder to move the report too.
	scalar  memberList   : A pipe delimited list of reports to move from one folder to another.
	scalar  objectType   : The object type for the folder.
	scalar  formatType   : The format type of the folder: report, query or report format.
	scalar  configType   : The configuration location for the report.

 Valid object types (Constants defiend in Globals.pm):
        PROBLEM_TYPE
        TASK_TYPE
        OBJECT_TYPE

 Valid format types (Constants defiend in Globals.pm):
 		QUERY
        REPORT
        REPORT_FORMAT
 
 Valid configuration types (Constants defiend in Globals.pm):
        SHARED_PROFILE
        SYSTEM_CONFIG
        USER_PROFILE
        
 Returns: apiData
	the return message from the server.
 
 Example:
	
	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "Admin", "\\\\machine\\ccmdb\\cm_database");
		
		my $globals = new ChangeSynergy::Globals();
		
		#Moves the reports 'API Test 1' and 'API Test 2' to the folder 'API Folder'.
		my $moveResults = $csapi->moveFolderMembers($aUser, "API Folder", "API Test 1|API Test 2", $globals->{PROBLEM_TYPE}, $globals->{REPORT}, $globals->{SHARED_PROFILE});
		print $moveResults->getResponseData() . "\n";
	};

	if ($@)
	{
		print $@;
	}

=cut

#############################################################################

=item B<PreferenceNameSubstitutionForAllUsers>

Performs a substitution within the name of a preference for all users. For example a users
reports and queries are stored in the _USER_CFG_%username_%databasepath entry. 
This could be _USER_CFG_jsmith_\\your_hostnameA\ccmdb\cm_database. If the database
moves from your_hostnameA to your_hostnameB then this method can make the subsitution.
It finds and replaces all occurrences of one string for another string. Find
"\\your_hostnameA\ccmdb\cm_database" and replace it with "\\your_hostnameB\ccmdb\cm_database".
The return result is an instance of the L<apiData> class.

Note: It is not possible to change or add user profile values.  These values
are the users first names, last names, email addresses, fax numbers, telephone
numbers and addresses.

 Parameters:
	apiUser aUser   : The current api user's login data.
	scalar  keyValue: The value to search for when doing a replacement.
	scalar  subValue: The replacement value, the value to be added.

 Returns: apiData
	the return message from the server.
 
 Example:
	
	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "Admin", "\\\\your_hostnameB\\ccmdb\\cm_database");

		$tmpData = $csapi->PreferenceNameSubstitutionForAllUsers($aUser, "\\\\your_hostnameA\\ccmdb\\cm_database", "\\\\your_hostnameB\\ccmdb\\cm_database");
	
		print $tmpData->getResponseData();

	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<PreferenceNameSubstitutionForAUser>

Performs a substitution within the name of a preference for a single user. For example a users
reports and queries are stored in the _USER_CFG_%username_%databasepath entry. 
This could be _USER_CFG_jsmith_\\your_hostnameA\ccmdb\cm_database. If the database
moves from your_hostnameA to your_hostnameB then this method can make the subsitution.
It finds and replaces all occurrences of one string for another string. Find
"\\your_hostnameA\ccmdb\cm_database" and replace it with "\\your_hostnameB\ccmdb\cm_database".
The return result is an instance of the L<apiData> class.

Note: It is not possible to change or add user profile values.  These values
are the users first names, last names, email addresses, fax numbers, telephone
numbers and addresses.

 Parameters:
	apiUser aUser   : The current api user's login data.
	scalar  username: The name of the user's preferences to edit.
	scalar  keyValue: The value to search for when doing a replacement.
	scalar  subValue: The replacement value, the value to be added.

 Returns: apiData
	the return message from the server.
 
 Example:
	
	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "Admin", "\\\\your_hostnameB\\ccmdb\\cm_database");

		$tmpData = $csapi->PreferenceNameSubstitutionForAUser($aUser, "u00001", "\\\\your_hostnameA\\ccmdb\\cm_database", "\\\\your_hostnameB\\ccmdb\\cm_database");
	
		print $tmpData->getResponseData();

	};

	if ($@)
	{
		print $@;
	}

=cut

#############################################################################

=item B<PreferenceSubstitutionForAUser>

Performs a substitution within the value of a preference for a single user. 
Given a user preference, find and replace all occurrences of one string
for another string. This is helpful when you need to change a user's config
entry to replace one report name (problem_review) for another report name (cr_review)
throughout their _USER_CFG_ entry. The return result is an instance of the L<apiData> class

Note: It is not possible to change or add user profile values.  These values
are the users first names, last names, email addresses, fax numbers, telephone
numbers and addresses.

 Parameters:
	apiUser aUser   : The current api user's login data.
	scalar  username: The name of the user's preferences to edit.
	scalar  keyName : The name of the preference to edit.
	scalar  keyValue: The value to search for when doing a replacement.
	scalar  subValue: The replacement value, the value to be added.
	scalar  allDBs  : true or false, should the add take place for all databases
						or just the one that the current api user is logged into.

 Returns: apiData
	the return message from the server.
 
 Example:
	
	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "Admin", "\\\\your_hostname\\ccmdb\\cm_database");
		
		$tmpData = $csapi->PreferenceSubstitutionForAUser($aUser, "u00001", "_USER_CFG_", "problem_review", "cr_review", "true");
	
		print $tmpData->getResponseData();

	};

	if ($@)
	{
		print $@;
	}

=cut

#############################################################################

=item B<PreferenceSubstitutionForAllUsers>

Performs a substitution within the value of a preference for all users. 
Given a user preference, find and replace all occurrences of one string
for another string. This is helpful when you need to change a user's config
entry to replace one report name (problem_review) for another report name (cr_review)
throughout their _USER_CFG_ entry. The return result is an instance of the L<apiData> class

Note: It is not possible to change or add user profile values.  These values
are the users first names, last names, email addresses, fax numbers, telephone
numbers and addresses.

 Parameters:
	apiUser aUser   : The current api user's login data.
	scalar  keyName : The name of the preference to edit.
	scalar  keyValue: The value to search for when doing a replacement.
	scalar  subValue: The replacement value, the value to be added.
	scalar  allDBs  : true or false, should the add take place for all databases
						or just the one that the current api user is logged into.

 Returns: apiData
	the return message from the server.
 
 Example:
	
	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "Admin", "\\\\your_hostname\\ccmdb\\cm_database");
		
		$tmpData = $csapi->PreferenceSubstitutionForAllUsers($aUser, "_USER_CFG_", "problem_review", "cr_review", "true");
	
		print $tmpData->getResponseData();

	};

	if ($@)
	{
		print $@;
	}

=cut

#############################################################################


=item B<ProcessEmailSubmitForms>

Process email submit forms on the IBM Rational Change server.
The return result is an instance of the L<apiData> class.

 Parameters:
	apiUser aUser: The current api user's login data.

 Returns: apiData
	the return message from the server.
 
 Example:

	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "Admin", "\\\\your_hostname\\ccmdb\\cm_database");

		my $tmpstr = $csapi->ProcessEmailSubmitForms($aUser);
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<QueryData>

Run a IBM Rational Change report, and respond with XML data only.
The return result is an instance of the L<apiQueryData> class.

Note: The return value is the complete contents of the report represented as data only.

 Parameters:
	apiUser aUser       : The current api user's login data.
	scalar  reportName  : A ChangeSynergy report name 
	                      ([CCM_REPORT][NAME]report name[/NAME]...[/CCM_REPORT]).
	scalar  queryString : A valid IBM Rational Synergy query string. 
	scalar  queryName   : A ChangeSynergy query name 
	                      ([CCM_QUERY][NAME]query name[/NAME]...[/CCM_QUERY]).
	scalar  reportTitle : A title for this instance of the report.
	scalar  templateName: The name of the ChangeSynergy template to load
	                      ([CCM_TEMPLATE][NAME]template name[/NAME]...[/CCM_TEMPLATE]).
	

 Returns: apiQueryData
	the XML data that represents the report data.

 Example:

	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "User", "\\\\your_hostname\\ccmdb\\cm_database");

		my $tmp = $csapi->QueryData($aUser, "Basic Summary", "(submitter='cschuffe') and (cvtype='problem')", 
                                    undef, undef, undef);
	};

	if ($@)
	{
		print $@;
	}

=cut

#############################################################################

=item B<QueryData>

Run a ChangeSynergy report, and respond with XML data only.
The return result is an instance of the L<apiQueryData> class.

Note: The return value is the complete contents of the report represented as data only.

 Parameters:
	apiUser aUser        : The current api user's login data.
	scalar  reportName   : A ChangeSynergy report name 
	                       ([CCM_REPORT][NAME]report name[/NAME]...[/CCM_REPORT]).
	scalar  queryString  : A valid IBM Rational Synergy query string. 
	scalar  queryName    : A ChangeSynergy query name 
	                       ([CCM_QUERY][NAME]query name[/NAME]...[/CCM_QUERY]).
	scalar  reportTitle  : A title for this instance of the report.
	scalar  templateName : The name of the ChangeSynergy template to load
	                       ([CCM_TEMPLATE][NAME]template name[/NAME]...[/CCM_TEMPLATE]).
	scalar  attributeList: A piped list of attributes "problem_number|crstatus|assigner...".
	

 Returns: apiQueryData
	the XML data that represents the report data.

 Example:

	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "User", "\\\\your_hostname\\ccmdb\\cm_database");

		my $tmp = $csapi->QueryData($aUser, "Basic Summary", "(submitter='cschuffe') and (cvtype='problem')", 
                                    undef, undef, undef, "problem_number|crstatus");
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<QueryHtml>

Run a ChangeSynergy report, it will return either the results or the polling template (if the results aren't ready yet).

This api should be used for running large reports. The return result 
is an instance of the L<apiData> class.

 Note: The return value is a complete HTML page. <HTML>...</HTML>
       The return value can be saved as an .html file, or loaded
       into a browser window/control.

 Parameters:
	apiUser aUser       : The current api user's login data.
	scalar  reportName  : A ChangeSynergy report name 
	                      ([CCM_REPORT][NAME]report name[/NAME]...[/CCM_REPORT]).
	scalar  queryString : A valid IBM Rational Synergy query string. 
	scalar  queryName   : A ChangeSynergy query name 
	                      ([CCM_QUERY][NAME]query name[/NAME]...[/CCM_QUERY]).
	scalar  reportTitle : A title for this instance of the report.
	scalar  templateName: The name of the ChangeSynergy template to load 
	                      ([CCM_TEMPLATE][NAME]template name[/NAME]...[/CCM_TEMPLATE]).

 Returns: apiData
 	the requested immediate query as an HTML page or 
	the polling template for the query which was run.  This is an HTML page.

 Example:

	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "User", "\\\\your_hostname\\ccmdb\\cm_database");

		my $tmpstr = $csapi->QueryHtml($aUser, "Basic Summary", 
                                       "(submitter='cschuffe') and (cvtype='problem')",
                                       undef, "Basic Summary Report");
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<QueryNameData>

Run a ChangeSynergy report, and respond with XML data only.
The return result is an instance of the L<apiQueryData> class.

Note: The return value is the complete contents of the report represented as data only.

 Parameters:
	apiUser aUser        : The current api user's login data.
	scalar  reportName   : A ChangeSynergy report name 
	                       ([CCM_REPORT][NAME]report name[/NAME]...[/CCM_REPORT]).
	scalar  queryName    : A ChangeSynergy query name 
	                       ([CCM_QUERY][NAME]query name[/NAME]...[/CCM_QUERY]).
	scalar  attributeList: A piped list of attributes "problem_number|crstatus|assigner...".
	

 Returns: apiQueryData
	the XML data that represents the report data.

 Example:

	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "User", "\\\\your_hostname\\ccmdb\\cm_database");

		my $tmp = $csapi->QueryNameData($aUser, "Basic Summary", "All CRs", "problem_number|crstatus");
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<QueryStringData>

Run a ChangeSynergy report, and respond with XML data only.
The return result is an instance of the L<apiQueryData> class.

Note: The return value is the complete contents of the report represented as data only.

 Parameters:
	apiUser aUser        : The current api user's login data.
	scalar  reportName   : A ChangeSynergy report name 
	                       ([CCM_REPORT][NAME]report name[/NAME]...[/CCM_REPORT]).
	scalar  queryString  : A valid IBM Rational Synergy query string. 
	scalar  attributeList: A piped list of attributes "problem_number|crstatus|assigner...".
	

 Returns: apiQueryData
	the XML data that represents the report data.

 Example:

	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "User", "\\\\your_hostname\\ccmdb\\cm_database");

		my $tmp = $csapi->QueryStringData($aUser, "Basic Summary", "(submitter='cschuffe') and (cvtype='problem')", 
                                    "problem_number|crstatus");
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<RefreshUsers>

Attention: As of IBM Rational Change 5.2, this method is not very useful. IBM Rational
Change can now automatically detect changes made through the "ccm users" command,
eliminating the need to call this--the refresh will happen on-the-fly no matter
what. This will not cause problems, but may be doing unnecessary work.

Causes all backend sessions to refresh their security settings and
reload all user information. This is needed if new users are added to
IBM Rational Synergy outside of IBM Rational Change. Normally, these changes will only be
seen when new sessions are started; existing sessions will continue to use
the stale data. This function forces all sessions to refresh
themselves and immediately see such changes.

Requires the user login with the Admin role.

IBM Rational Change will not recognize users without an entry in its LDAP server.
Simply adding users to IBM Rational Synergy and calling this function will not
allow those users to log on to IBM Rational Change. This function is only useful
during advanced user customization.

 Parameters:
	apiUser aUser        : The current API user's login data.

 Returns: scalar
	a return message from the server.

 Example:

	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "Admin", "\\\\your_hostname\\ccmdb\\cm_database");

		$csapi->RefreshUsers($aUser);
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<renameFolder>

Renames a query, report format or report folder on the server.
The return result is an instance of the L<apiData> class.

 Parameters:
	apiUser aUser        : The current api user's login data.
	scalar  folderName   : The current name of the folder.
	scalar  newFolderName: The new name for the folder.
	scalar  objectType   : The object type for the folder.
	scalar  formatType   : The format type of the folder: report, query or report format.
	scalar  configType   : The configuration location for the report.

 Valid object types (Constants defiend in Globals.pm):
        PROBLEM_TYPE
        TASK_TYPE
        OBJECT_TYPE

 Valid format types (Constants defiend in Globals.pm):
 		QUERY
        REPORT
        REPORT_FORMAT
 
 Valid configuration types (Constants defiend in Globals.pm):
        SHARED_PROFILE
        SYSTEM_CONFIG
        USER_PROFILE
        
 Returns: apiData
	the return message from the server.
 
 Example:
	
	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "Admin", "\\\\machine\\ccmdb\\cm_database");
		
		my $globals = new ChangeSynergy::Globals();
		
		#Renames a shared CR Report folder called 'API Folder' to 'API Folder Renamed'
		my $renameResults = $csapi->renameFolder($aUser, "API Folder", "API Folder Renamed", $globals->{PROBLEM_TYPE}, $globals->{REPORT}, $globals->{SHARED_PROFILE});
		print $renameResults->getResponseData();
	};

	if ($@)
	{
		print $@;
	}

=cut

#############################################################################

=item B<ReloadListboxes>

The pt_listbox.cfg file will be reloaded, and all listboxes
that get their values from a database will be reloaded.
The return result is an instance of the L<apiData> class.

 Parameters:
	apiUser aUser: The current api user's login data.

 Returns: apiData
	the return message from the server.
 
 Example:

	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "Admin", "\\\\your_hostname\\ccmdb\\cm_database");

		my $tmpstr = $csapi->ReloadListboxes($aUser);
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<ReloadStringTable>

Clears and reloads the external strings table.
The return result is an instance of the L<apiData> class.

 Parameters:
	apiUser aUser: The current api user's login data.

 Returns: apiData
	the return message from the server.
 
 Example:

	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "Admin", "\\\\your_hostname\\ccmdb\\cm_database");

		my $tmpstr = $csapi->ReloadStringTable($aUser);
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<ReportData>

Run a ChangeSynergy report, and respond with XML data only.
The return result is an instance of the L<apiQueryData> class.

Note: The return value is the complete contents of the report represented as data only.

 Parameters:
	apiUser aUser        : The current api user's login data.
	scalar  reportName   : A ChangeSynergy report name 
	                       ([CCM_REPORT][NAME]report name[/NAME]...[/CCM_REPORT]).
	scalar  attributeList: A piped list of attributes "problem_number|crstatus|assigner...".

 Returns: apiQueryData
	the XML data that represents the report data.

 Example:

	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "User", "\\\\your_hostname\\ccmdb\\cm_database");

		my $tmp = $csapi->ReportData($aUser, "DRP - Summary of CRs Submitted by Me", "problem_number");
		
		$tmpstr = $tmp->getXmlData();
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<ReportData>

Run a ChangeSynergy report, and respond with XML data only.
The return result is an instance of the L<apiQueryData> class.

Note: The return value is the complete contents of the report represented as data only.

 Parameters:
	apiUser aUser       : The current api user's login data.
	scalar  reportName  : A ChangeSynergy report name 
	                      ([CCM_REPORT][NAME]report name[/NAME]...[/CCM_REPORT]).
	scalar  reportTitle : A title for this instance of the report.
	scalar  templateName: The name of the ChangeSynergy template to load 
	                      ([CCM_TEMPLATE][NAME]template name[/NAME]...[/CCM_TEMPLATE]).

 Returns: apiQueryData
	the XML data that represents the report data.

 Example:

	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "User", "\\\\your_hostname\\ccmdb\\cm_database");

		my $tmp = $csapi->ReportData($aUser, "DRP - Summary of CRs Submitted by Me", undef, undef);
		
		$tmpstr = $tmp->getXmlData();
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<ReportData>

Run a ChangeSynergy report, and respond with XML data only.
The return result is an instance of the L<apiQueryData> class.

Note: The return value is the complete contents of the report represented as data only.

 Parameters:
	apiUser aUser        : The current api user's login data.
	scalar  reportName   : A ChangeSynergy report name 
	                       ([CCM_REPORT][NAME]report name[/NAME]...[/CCM_REPORT]).
	scalar  reportTitle  : A title for this instance of the report.
	scalar  templateName : The name of the ChangeSynergy template to load 
	                       ([CCM_TEMPLATE][NAME]template name[/NAME]...[/CCM_TEMPLATE]).
	scalar  attributeList: A piped list of attributes "problem_number|crstatus|assigner...".

 Returns: apiQueryData
	the XML data that represents the report data.

 Example:

	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "User", "\\\\your_hostname\\ccmdb\\cm_database");

		my $tmp = $csapi->ReportData($aUser, "DRP - Summary of CRs Submitted by Me", undef, undef, undef);
		
		$tmpstr = $tmp->getXmlData();
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<ReportHtml>

Run a ChangeSynergy report, it will return either the results or the polling template (if the results aren't ready yet).
This api should be used for running large reports. The return result
is an instance of the L<apiData> class.

 Note: The return value is a complete HTML page. <HTML>...</HTML>
       The return value can be saved as an .html file, or loaded
       into a browser window/control.

 Parameters:
	apiUser aUser       : The current api user's login data.
	scalar  reportName  : A ChangeSynergy report name 
	                      ([CCM_REPORT][NAME]report name[/NAME]...[/CCM_REPORT]).
	scalar  reportTitle : A title for this instance of the report.
	scalar  templateName: The name of the ChangeSynergy template to load
	                      ([CCM_TEMPLATE][NAME]template name[/NAME]...[/CCM_TEMPLATE]).

 
 Returns: apiData
 	the requested immediate query as an HTML page or
	the polling template for the report which was run.  This is an HTML page.
 
 Example:

	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "User", "\\\\your_hostname\\ccmdb\\cm_database");

		my $tmpstr = $csapi->ReportHtml($aUser, "Basic Summary", "Basic Summary Report", undef);
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<ReportOnCRData>

Run a ChangeSynergy report that reports on a single Change Request.
The return result is an instance of the L<apiQueryData> class.

Note: The return value is the complete contents of the report represented as data only.

 Parameters:
	apiUser aUser        : The current api user's login data.
	scalar  problemNumber: The Change Request ID/Problem Number ID to reference.
	scalar  ReportName   : A ChangeSynergy report name
	                       ([CCM_REPORT][NAME]report name[/NAME]...[/CCM_REPORT]).
	scalar  reportTitle  : A title for this instance of the report.

 Returns: apiQueryData
	the xml data that represents the contents of the report.

 Example:

	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "User", "\\\\your_hostname\\ccmdb\\cm_database");

		my $tmp = $csapi->ReportOnCRData($aUser, "132", "DRP - Summary with Tasks and Objects", undef);
		
		my $tmpstr = $tmp->getXmlData();
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<ReportOnCRData>

Run a ChangeSynergy report that reports on a single Change Request.
The return result is an instance of the L<apiQueryData> class.

Note: The return value is the complete contents of the report represented as data only.

 Parameters:
	apiUser aUser        : The current api user's login data.
	scalar  problemNumber: The Change Request ID/Problem Number ID to reference.
	scalar  ReportName   : A ChangeSynergy report name
	                       ([CCM_REPORT][NAME]report name[/NAME]...[/CCM_REPORT]).
	scalar  reportTitle  : A title for this instance of the report.
	scalar  attributeList: A piped list of attributes "problem_number|crstatus|assigner...".

 Returns: apiQueryData
	the xml data that represents the contents of the report.

 Example:

	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "User", "\\\\your_hostname\\ccmdb\\cm_database");

		my $tmp = $csapi->ReportOnCRData($aUser, "132", "DRP - Summary with Tasks and Objects",
                                         undef, "problem_number|crstatus");
		
		my $tmpstr = $tmp->getXmlData();
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<ReportOnCRHtml>

Run a ChangeSynergy report that reports on a single Change Request.
The return result is an instance of the L<apiData> class.

 Note: The return value is a complete HTML page. <HTML>...</HTML>
       The return value can be saved as a .html file, or loaded
       into a browser window/control.

 Parameters:
	apiUser aUser        : The current api user's login data.
	scalar  problemNumber: The Change Request ID/Problem Number ID to reference.
	scalar  reportName   : A ChangeSynergy report name 
	                       ([CCM_REPORT][NAME]report name[/NAME]...[/CCM_REPORT]).
	scalar  reportTitle  : A title for this instance of the report.
 
 Returns: apiData
	the report as an HTML page.

 Example:

	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "User", "\\\\your_hostname\\ccmdb\\cm_database");

		my $tmpstr = $csapi->ReportOnCRHtml($aUser, "1347", "problemdetail", undef);
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<ReportOnObjectData>

Run a ChangeSynergy report that reports on a single Object.
The return result is an instance of the L<apiQueryData> class.

Note: The return value is the complete contents of the report represented as data only.

 Parameters:
	apiUser aUser      : The current api user's login data.
	scalar  objectId   : The CVID of the referenced object.
	scalar  reportName : A ChangeSynergy report name 
	                     ([CCM_REPORT][NAME]report name[/NAME]...[/CCM_REPORT]).
	scalar  reportTitle: A title for this instance of the report.

 Returns: apiQueryData
	the report in xml data format.

 Example:

	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "User", "\\\\your_hostname\\ccmdb\\cm_database");

		my $tmp = $csapi->ReportOnObjectData($aUser, "11753", "objectdetail", undef);
		
		my $tmpstr = $tmp->getXmlData();
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<ReportOnObjectData>

Run a ChangeSynergy report that reports on a single Object.
The return result is an instance of the L<apiQueryData> class.

Note: The return value is the complete contents of the report represented as data only.

 Parameters:
	apiUser aUser        : The current api user's login data.
	scalar  objectId     : The CVID of the referenced object.
	scalar  reportName   : A ChangeSynergy report name
	                       ([CCM_REPORT][NAME]report name[/NAME]...[/CCM_REPORT]).
	scalar  reportTitle  : A title for this instance of the report.
	scalar  attributeList: A piped list of attributes "problem_number|crstatus|assigner...".

 Returns: apiQueryData
	the report in xml data format.

 Example:

	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "User", "\\\\your_hostname\\ccmdb\\cm_database");

		my $tmp = $csapi->ReportOnObjectData($aUser, "11753", "objectdetail", undef, "problem_number");
		
		my $tmpstr = $tmp->getXmlData();
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<ReportOnObjectHtml>

Run a ChangeSynergy report that reports on a single Object.
The return result is an instance of the L<apiData> class.

 Note: The return value is a complete HTML page. <HTML>...</HTML>
       The return value can be saved as a .html file, or loaded
       into a browser window/control.

 Parameters:
	apiUser aUser      : The current api user's login data.
	scalar  objectId   : The CVID of the referenced object.
	scalar  reportName : A ChangeSynergy report name
	                     ([CCM_REPORT][NAME]report name[/NAME]...[/CCM_REPORT]).
	scalar  reportTitle: A title for this instance of the report.

 Returns: apiData
	the report as an HTML page.

 Example:

	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "User", "\\\\your_hostname\\ccmdb\\cm_database");

		my $tmpstr = $csapi->ReportOnObjectHtml($aUser, "13", "objectdetail", undef);
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<ReportOnTaskData>

Run a ChangeSynergy report that reports on a single Task.
The return result is an instance of the L<apiQueryData> class.

 Parameters:
	apiUser aUser      : The current api user's login data.
	scalar  taskNumber : The Task ID to reference.
	scalar  reportName : A ChangeSynergy report name
	                     ([CCM_REPORT][NAME]report name[/NAME]...[/CCM_REPORT]).
	scalar  reportTitle: A title for this instance of the report.

 Returns: apiQueryData
	the report in xml data format.

 Example:

	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "User", "\\\\your_hostname\\ccmdb\\cm_database");

		my $tmp = $csapi->ReportOnTaskData($aUser, "1", "taskdetail", undef);
		
		my $tmpstr = $tmp->getXmlData();
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<ReportOnTaskData>

Run a ChangeSynergy report that reports on a single Task.
The return result is an instance of the L<apiQueryData> class.

 Parameters:
	apiUser aUser        : The current api user's login data.
	scalar  taskNumber   : The Task ID to reference.
	scalar  reportName   : A ChangeSynergy report name
	                       ([CCM_REPORT][NAME]report name[/NAME]...[/CCM_REPORT]).
	scalar  reportTitle  : A title for this instance of the report.
	scalar  attributeList: A piped list of attributes "problem_number|crstatus|assigner...".

 Returns: apiQueryData
	the report in xml data format.

 Example:

	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "User", "\\\\your_hostname\\ccmdb\\cm_database");

		my $tmp = $csapi->ReportOnTaskData($aUser, "1", "taskdetail", undef, "task_number");
		
		my $tmpstr = $tmp->getXmlData();
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<ReportOnTaskHtml>

Run a ChangeSynergy report that reports on a single Task.
The return result is an instance of the L<apiData> class.

 Note: The return value is a complete HTML page. <HTML>...</HTML>
       The return value can be saved as a .html file, or loaded
       into a browser window/control.

 Parameters:
	apiUser aUser      : The current api user's login data.
	scalar  taskNumber : The Task ID to reference.
	scalar  reportName : A ChangeSynergy report name
	                     ([CCM_REPORT][NAME]report name[/NAME]...[/CCM_REPORT]).
	scalar  reportTitle: A title for this instance of the report.

 Returns: apiData
	the results of the report as an HTML page.

 Example:

	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "User", "\\\\your_hostname\\ccmdb\\cm_database");

		my $tmpstr = $csapi->ReportOnTaskHtml($aUser, "13", "taskdetail", undef);
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<ResetAdminTokens>

Logs-in the administrator user for all databases.
The return result is an instance of the L<apiData> class.

 Parameters:
	apiUser aUser: The current api user's login data.

 Returns: apiData
	the return message from the server.
 
 Example:

	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "Admin", "\\\\your_hostname\\ccmdb\\cm_database");

		my $tmpstr = $csapi->ResetAdminTokens($aUser);
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<ResetConfigurationDataLoadTime>

Resets the loaded configuration data timestamp on the IBM Rational Change server.
The return result is an instance of the L<apiData> class.

 Parameters:
	apiUser aUser: The current api user's login data.

 Returns: apiData
	the return message from the server.
 
 Example:

	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "Admin", "\\\\your_hostname\\ccmdb\\cm_database");

		my $tmpstr = $csapi->ResetConfigurationDataLoadTime($aUser);
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<ServerAPIVersion>

Get the API version number of the server.
The return result is an instance of the L<apiData> class.

 Parameters:
	apiUser aUser: The current api user's login data.

 Returns: apiData
	The version number string.
 
 Example:

	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "User", "\\\\your_hostname\\ccmdb\\cm_database");

		my $tmpstr1 = $csapi->ServerAPIVersion($aUser);
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<ServerGetFile>

Get a file object from the ChangeSynergy server.
The return result is an instance of the L<apiData> class.

 Parameters:
	apiUser aUser: The current api user's login data.
	scalar  file : The file name of the object to retrieve.

 Returns: apiData
	the byte data returned by the server.
	
 Example:

	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser      = $csapi->Login("u00001", "u00001", "User", "\\\\your_hostname\\ccmdb\\cm_database");
		my $file       = "serverFile.txt";
		my $filehandle = $csapi->ServerGetFile($aUser, $file);

		open(OUTPUTFILE, ">serverFile.txt");

		print OUTPUTFILE $filehandle->getResponseByteData();

		close OUTPUTFILE;
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<ServerSendFile>

Copy a file object to the ChangeSynergy server.
The return result is an instance of the L<apiData> class.

 Parameters:
	apiUser aUser : The current api user's login data.
	scalar  buffer: The BYTE data to send to the server.
	scalar  size  : The size of the BYTE data.

 Returns: apiData
	the return message from the server.
	
 Example:

	my $csapi  = new ChangeSynergy::csapi();
	my $buffer = "";
	my $buf    = "";
	my $size   = "";

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser      = $csapi->Login("u00001", "u00001", "User", "\\\\your_hostname\\ccmdb\\cm_database");

		open(INPUTFILE, "filename.txt") or die "Could not open up the file";

		while($buf = readline *INPUTFILE)
		{
			$buffer .= $buf;
		}

		close(INPUTFILE);
		
		$size = -s "filename.txt";

		my $filehandle = $csapi->ServerSendFile($aUser, $buffer, $size);
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<SetAttributes>

Sets/creates ChangeSynergy attributes on the server. 

This operation is not needed if all attributes referenced by your custom application are
defined in an installed CR process. The GetAttributes() api method can be used to confirm this.

The unique list of attributes provided will be stored in a ChangeSynergy configuration file with
the name provided. The "lpszCfgName" should not include a ".ext" dot extension, it should be just
a file name prefix, ex: "my_app_attrs". A ".cfg" will be added to the name by the IBM Rational Change server.
Care should be given to naming the file. The names: 'pt', 'task_framework', 'admin_framework',
'user_framework', 'users', and 'template', are reserved system configuration file names, and are not
allowed. The operation will DELETE a file of name lpszCfgName.cfg if it exists. This is so you can
overwrite your own custom attribute list. The operation will fail if the file cannot be created or deleted.

The operation will fail if any of the listed attributes exist on the server outside of any defined
in a existing lpszCfgName.cfg file name. The list of offending attributes will be returned if the
operation fails for this reason. It is recommended that the GetAttributes() api method be used to confirm
that all custom application attributes are in fact not known to the IBM Rational Change server.

Known predefined ChangeSynergy attributes (reserved, and cannot be defined):

	***************** Global CR attributes *****************
	
	[CCM_ATTRIBUTE][NAME]crstatus[/NAME][ALIAS]Status[/ALIAS][TYPE]CCM_STRING[/TYPE][/CCM_ATTRIBUTE]
	[CCM_ATTRIBUTE][NAME]problem_synopsis[/NAME][ALIAS]Synopsis[/ALIAS][TYPE]CCM_STRING[/TYPE][/CCM_ATTRIBUTE]
	[CCM_ATTRIBUTE][NAME]problem_description[/NAME][ALIAS]Problem Description[/ALIAS][TYPE]CCM_TEXT[/TYPE][/CCM_ATTRIBUTE]
	[CCM_ATTRIBUTE][NAME]problem_number[/NAME][ALIAS]CR ID[/ALIAS][TYPE]CCM_STRING[/TYPE][/CCM_ATTRIBUTE]
	[CCM_ATTRIBUTE][NAME]transition_log[/NAME][ALIAS]Log[/ALIAS][TYPE]CCM_TEXT[/TYPE][/CCM_ATTRIBUTE]
	[CCM_ATTRIBUTE][NAME]submitter[/NAME][ALIAS]Submitter[/ALIAS][TYPE]CCM_USER[/TYPE][/CCM_ATTRIBUTE]
	[CCM_ATTRIBUTE][NAME]submitter_name[/NAME][ALIAS]Name[/ALIAS][TYPE]CCM_STRING[/TYPE][/CCM_ATTRIBUTE]
	[CCM_ATTRIBUTE][NAME]submitter_phone[/NAME][ALIAS]Phone Number[/ALIAS][TYPE]CCM_STRING[/TYPE][/CCM_ATTRIBUTE]
	[CCM_ATTRIBUTE][NAME]submitter_fax[/NAME][ALIAS]Fax Number[/ALIAS][TYPE]CCM_STRING[/TYPE][/CCM_ATTRIBUTE]
	[CCM_ATTRIBUTE][NAME]submitter_address[/NAME][ALIAS]Address[/ALIAS][TYPE]CCM_STRING[/TYPE][/CCM_ATTRIBUTE]
	[CCM_ATTRIBUTE][NAME]submitter_email[/NAME][ALIAS]Email Address[/ALIAS][TYPE]CCM_STRING[/TYPE][/CCM_ATTRIBUTE]
	[CCM_ATTRIBUTE][NAME]submitter_company[/NAME][ALIAS]Employer[/ALIAS][TYPE]CCM_STRING[/TYPE][/CCM_ATTRIBUTE]
	
	 ***************** Global Task attributes *****************

	[CCM_ATTRIBUTE][NAME]task_number[/NAME][ALIAS]Task ID[/ALIAS][TYPE]CCM_STRING[/TYPE][/CCM_ATTRIBUTE]
	[CCM_ATTRIBUTE][NAME]task_synopsis[/NAME][ALIAS]Synopsis[/ALIAS][TYPE]CCM_STRING[/TYPE][/CCM_ATTRIBUTE]
	
	***************** Global Object attributes *****************
	
	[CCM_ATTRIBUTE][NAME]cvid[/NAME][ALIAS]IBM Rational Synergy ID[/ALIAS][TYPE]CCM_STRING[/TYPE][/CCM_ATTRIBUTE]
	[CCM_ATTRIBUTE][NAME]comment[/NAME][ALIAS]Object Comment[/ALIAS][TYPE]CCM_TEXT[/TYPE][/CCM_ATTRIBUTE]
	[CCM_ATTRIBUTE][NAME]description[/NAME][ALIAS]Object Description[/ALIAS][TYPE]CCM_TEXT[/TYPE][/CCM_ATTRIBUTE]
	[CCM_ATTRIBUTE][NAME]displayname[/NAME][ALIAS]Display Name[/ALIAS][TYPE]CCM_STRING[/TYPE][/CCM_ATTRIBUTE]
	[CCM_ATTRIBUTE][NAME]source[/NAME][ALIAS]Source[/ALIAS][TYPE]CCM_STRING[/TYPE][/CCM_ATTRIBUTE]
	[CCM_ATTRIBUTE][NAME]attachment_name[/NAME][ALIAS]Attachment Name[/ALIAS][TYPE]CCM_STRING[/TYPE][/CCM_ATTRIBUTE]
	[CCM_ATTRIBUTE][NAME]attachment_size[/NAME][ALIAS]Attachment Length[/ALIAS][TYPE]CCM_NUMBER[/TYPE][/CCM_ATTRIBUTE]
	
	***************** Shared Ccm/PT/System attributes *****************
	
	[CCM_ATTRIBUTE][NAME]status[/NAME][ALIAS]Status[/ALIAS][TYPE]CCM_STRING[/TYPE][/CCM_ATTRIBUTE]
	[CCM_ATTRIBUTE][NAME]database[/NAME][ALIAS]Database[/ALIAS][TYPE]CCM_STRING[/TYPE][/CCM_ATTRIBUTE]
	[CCM_ATTRIBUTE][NAME]modifiable_in[/NAME][ALIAS]Work in DB[/ALIAS][TYPE]CCM_LISTBOX[/TYPE][/CCM_ATTRIBUTE]
	[CCM_ATTRIBUTE][NAME]created_in[/NAME][ALIAS]Created in DB[/ALIAS][TYPE]CCM_LISTBOX[/TYPE][/CCM_ATTRIBUTE]
	[CCM_ATTRIBUTE][NAME]cvtype[/NAME][ALIAS]Object Type[/ALIAS][TYPE]CCM_LISTBOX[/TYPE][/CCM_ATTRIBUTE]
	[CCM_ATTRIBUTE][NAME]name[/NAME][ALIAS]Object Name[/ALIAS][TYPE]CCM_STRING[/TYPE][/CCM_ATTRIBUTE]
	[CCM_ATTRIBUTE][NAME]modify_time[/NAME][ALIAS]Last Modified Time[/ALIAS][TYPE]CCM_DATE[/TYPE][/CCM_ATTRIBUTE]
	[CCM_ATTRIBUTE][NAME]status_log[/NAME][ALIAS]Transition Log[/ALIAS][TYPE]CCM_TEXT[/TYPE][/CCM_ATTRIBUTE]
	[CCM_ATTRIBUTE][NAME]platform[/NAME][ALIAS]Platform[/ALIAS][TYPE]CCM_LISTBOX[/TYPE][/CCM_ATTRIBUTE]
	[CCM_ATTRIBUTE][NAME]creator[/NAME][ALIAS]Creator[/ALIAS][TYPE]CCM_USER[/TYPE][/CCM_ATTRIBUTE]
	[CCM_ATTRIBUTE][NAME]create_time[/NAME][ALIAS]Created Date[/ALIAS][TYPE]CCM_DATE[/TYPE][/CCM_ATTRIBUTE]
	
	***************** Special PTCLI/System Attributes *****************
	
	[CCM_ATTRIBUTE][NAME]users_roles[/NAME][ALIAS]User Roles[/ALIAS][TYPE]CCM_TEXT[/TYPE][/CCM_ATTRIBUTE]
	[CCM_ATTRIBUTE][NAME]users[/NAME][ALIAS]Users[/ALIAS][TYPE]CCM_TEXT[/TYPE][/CCM_ATTRIBUTE]
	[CCM_ATTRIBUTE][NAME]user[/NAME][ALIAS]User[/ALIAS][TYPE]CCM_STRING[/TYPE][/CCM_ATTRIBUTE]
	[CCM_ATTRIBUTE][NAME]generic_cs_attribute[/NAME][ALIAS]Do Not Use/Remove[/ALIAS][TYPE]CCM_STRING[/TYPE][/CCM_ATTRIBUTE]
	[CCM_ATTRIBUTE][NAME]dcm_dbid[/NAME][ALIAS]DCM Database ID[/ALIAS][TYPE]CCM_STRING[/TYPE][/CCM_ATTRIBUTE]
	[CCM_ATTRIBUTE][NAME]dcm_delimiter[/NAME][ALIAS]DCM Delimiter[/ALIAS][TYPE]CCM_STRING[/TYPE][/CCM_ATTRIBUTE]
	[CCM_ATTRIBUTE][NAME]pt_app[/NAME][ALIAS]DevClient Application Data[/ALIAS][TYPE]CCM_STRING[/TYPE][/CCM_ATTRIBUTE]
	[CCM_ATTRIBUTE][NAME]pt_app_role[/NAME][ALIAS]DevClient Application Role[/ALIAS][TYPE]CCM_STRING[/TYPE][/CCM_ATTRIBUTE]
	[CCM_ATTRIBUTE][NAME]all_databases[/NAME][ALIAS]All Databases[/ALIAS][TYPE]CCM_STRING[/TYPE][/CCM_ATTRIBUTE]
	[CCM_ATTRIBUTE][NAME]all_groups[/NAME][ALIAS]All Groups[/ALIAS][TYPE]CCM_LISTBOX[/TYPE][/CCM_ATTRIBUTE]
	[CCM_ATTRIBUTE][NAME]LIFECYCLES[/NAME][ALIAS]All Lifecycles[/ALIAS][TYPE]CCM_LISTBOX[/TYPE][/CCM_ATTRIBUTE]
	[CCM_ATTRIBUTE][NAME]LIFECYCLE_STATES[/NAME][ALIAS]All States in a Lifecycle[/ALIAS][TYPE]CCM_LISTBOX[/TYPE][/CCM_ATTRIBUTE]
	[CCM_ATTRIBUTE][NAME]LIFECYCLE_TRANSITIONS[/NAME][ALIAS]All Transitions in a Lifecycle[/ALIAS][TYPE]CCM_LISTBOX[/TYPE][/CCM_ATTRIBUTE]
	[CCM_ATTRIBUTE][NAME]VALID_TRANSITIONS[/NAME][ALIAS]Allowable Transitions[/ALIAS][TYPE]CCM_STRING[/TYPE][/CCM_ATTRIBUTE]
	[CCM_ATTRIBUTE][NAME]VALID_CREATES[/NAME][ALIAS]Allowable Submissions[/ALIAS][TYPE]CCM_STRING[/TYPE][/CCM_ATTRIBUTE]
	[CCM_ATTRIBUTE][NAME]VALID_CREATES_USER[/NAME][ALIAS]Allowable Submissions for User[/ALIAS][TYPE]CCM_STRING[/TYPE][/CCM_ATTRIBUTE]
	[CCM_ATTRIBUTE][NAME]CURRENT_LIFECYCLE[/NAME][ALIAS]Current Lifecycle[/ALIAS][TYPE]CCM_STRING[/TYPE][/CCM_ATTRIBUTE]
	[CCM_ATTRIBUTE][NAME]IS_ADMIN[/NAME][ALIAS]Is a Admin[/ALIAS][TYPE]CCM_STRING[/TYPE][/CCM_ATTRIBUTE]
	[CCM_ATTRIBUTE][NAME]licensed_dcmpt[/NAME][ALIAS]License Info[/ALIAS][TYPE]CCM_STRING[/TYPE][/CCM_ATTRIBUTE]
	[CCM_ATTRIBUTE][NAME]licensed_xpt[/NAME][ALIAS]License Info[/ALIAS][TYPE]CCM_STRING[/TYPE][/CCM_ATTRIBUTE]
	[CCM_ATTRIBUTE][NAME]licensed_grpsec[/NAME][ALIAS]License Info[/ALIAS][TYPE]CCM_STRING[/TYPE][/CCM_ATTRIBUTE]
	
	***************** Special ACcent Attributes *****************
	
	[CCM_ATTRIBUTE][NAME]_COMMENTS[/NAME][ALIAS]Comments[/ALIAS][TYPE]CCM_TEXT[/TYPE][/CCM_ATTRIBUTE]
	[CCM_ATTRIBUTE][NAME]_DUPLICATE[/NAME][ALIAS]Duplicate[/ALIAS][TYPE]CCM_STRING[/TYPE][/CCM_ATTRIBUTE]
	[CCM_ATTRIBUTE][NAME]_CREATE_TASK[/NAME][ALIAS]Create Task[/ALIAS][TYPE]CCM_TOGGLE[/TYPE][/CCM_ATTRIBUTE]
	[CCM_ATTRIBUTE][NAME]_IS_MODIFIABLE[/NAME][ALIAS]Object can be Modified[/ALIAS][TYPE]CCM_TOGGLE[/TYPE][/CCM_ATTRIBUTE]
	[CCM_ATTRIBUTE][NAME]IS_MODIFIABLE[/NAME][ALIAS]Object can be Modified[/ALIAS][TYPE]CCM_TOGGLE[/TYPE][/CCM_ATTRIBUTE]
	[CCM_ATTRIBUTE][NAME]has_duplicate[/NAME][ALIAS]Duplicate of[/ALIAS][TYPE]CCM_RELATION[/TYPE][/CCM_ATTRIBUTE]
	[CCM_ATTRIBUTE][NAME]attachment[/NAME][ALIAS]Attachment(s)[/ALIAS][TYPE]CCM_RELATION[/TYPE][/CCM_ATTRIBUTE]
	[CCM_ATTRIBUTE][NAME]associated_task[/NAME][ALIAS]Associated Task(s)[/ALIAS][TYPE]CCM_RELATION[/TYPE][/CCM_ATTRIBUTE]
	
	***************** Special ChangeSynergy Identifiers *****************
	
	[CCM_ATTRIBUTE][NAME]_ATTACHMENT_NAME[/NAME][TYPE]CCM_STRING[/TYPE][/CCM_ATTRIBUTE]
	[CCM_ATTRIBUTE][NAME]_ATTACHMENT_COMMENT[/NAME][TYPE]CCM_STRING[/TYPE][/CCM_ATTRIBUTE]
	[CCM_ATTRIBUTE][NAME]_ATTACHMENT_IS_BINARY[/NAME][TYPE]CCM_STRING[/TYPE][/CCM_ATTRIBUTE]
	[CCM_ATTRIBUTE][NAME]_ATTACHMENT_IS_ASCII[/NAME][TYPE]CCM_STRING[/TYPE][/CCM_ATTRIBUTE]
	[CCM_ATTRIBUTE][NAME]_ATTACHMENT_TYPE[/NAME][TYPE]CCM_STRING[/TYPE][/CCM_ATTRIBUTE]
	[CCM_ATTRIBUTE][NAME]START_HERE[/NAME][ALIAS]Submit Forms[/ALIAS][TYPE]CCM_VALUELISTBOX[/TYPE][/CCM_ATTRIBUTE]
	
	***************** Textual Replacement Variables *****************
	
	[CCM_ATTRIBUTE][NAME]ChangeRequestProcessImage[/NAME][ALIAS]no_cr_process.gif[/ALIAS][TYPE]CCM_STRING[/TYPE][/CCM_ATTRIBUTE]
	
	***************** Textual Replacement Variables *****************
	
	[CCM_ATTRIBUTE][NAME]Problem_Identifier[/NAME][ALIAS]Change Request[/ALIAS][TYPE]CCM_STRING[/TYPE][/CCM_ATTRIBUTE]
	[CCM_ATTRIBUTE][NAME]Problem_Identifier_Plural[/NAME][ALIAS]Change Requests[/ALIAS][TYPE]CCM_STRING[/TYPE][/CCM_ATTRIBUTE]
	[CCM_ATTRIBUTE][NAME]Problem_Identifier_Abbr[/NAME][ALIAS]CR[/ALIAS][TYPE]CCM_STRING[/TYPE][/CCM_ATTRIBUTE]
	
	***************** Textual Replacement Variables *****************
	
	[CCM_ATTRIBUTE][NAME]DUPLICATE[/NAME][ALIAS]Duplicate Of[/ALIAS][TYPE]CCM_STRING[/TYPE][/CCM_ATTRIBUTE]
	[CCM_ATTRIBUTE][NAME]QUERY_STRING[/NAME][ALIAS]Query String[/ALIAS][TYPE]CCM_STRING[/TYPE][/CCM_ATTRIBUTE]
	[CCM_ATTRIBUTE][NAME]cr_modifications[/NAME][ALIAS]Show Modify Events[/ALIAS][TYPE]CCM_TOGGLE[/TYPE][/CCM_ATTRIBUTE]
	[CCM_ATTRIBUTE][NAME]cr_transitions[/NAME][ALIAS]Show Transition Comments[/ALIAS][TYPE]CCM_TOGGLE[/TYPE][/CCM_ATTRIBUTE]
	[CCM_ATTRIBUTE][NAME]cr_notes[/NAME][ALIAS]Show Notes[/ALIAS][TYPE]CCM_TOGGLE[/TYPE][/CCM_ATTRIBUTE]
	
	***************** Utility *****************
	
	[CCM_ATTRIBUTE][NAME]TRANSITION_USER[/NAME][ALIAS]Transition User[/ALIAS][TYPE]CCM_LISTBOX[/TYPE][/CCM_ATTRIBUTE]
	
	***************** Profile Attributes *****************
	
	[CCM_ATTRIBUTE][NAME]report_window_target[/NAME][ALIAS]Report Window Target[/ALIAS][TYPE]CCM_VALUELISTBOX[/TYPE][/CCM_ATTRIBUTE]
	[CCM_ATTRIBUTE][NAME]report_link_target[/NAME][ALIAS]Report Link Target[/ALIAS][TYPE]CCM_VALUELISTBOX[/TYPE][/CCM_ATTRIBUTE]
	[CCM_ATTRIBUTE][NAME]fontsize[/NAME][ALIAS]Font Size[/ALIAS][TYPE]CCM_LISTBOX[/TYPE][/CCM_ATTRIBUTE]
	[CCM_ATTRIBUTE][NAME]user_default_home_page[/NAME][ALIAS]Report Link Target[/ALIAS][TYPE]CCM_LISTBOX[/TYPE][/CCM_ATTRIBUTE]
	[CCM_ATTRIBUTE][NAME]defaultReport[/NAME][ALIAS]Default Report[/ALIAS][TYPE]CCM_STRING[/TYPE][/CCM_ATTRIBUTE]
	[CCM_ATTRIBUTE][NAME]reportIncremental[/NAME][ALIAS]Incremental Report[/ALIAS][TYPE]CCM_STRING[/TYPE][/CCM_ATTRIBUTE]
	[CCM_ATTRIBUTE][NAME]reportIncrementalSize[/NAME][ALIAS]Incremental Report Size[/ALIAS][TYPE]CCM_STRING[/TYPE][/CCM_ATTRIBUTE]
	[CCM_ATTRIBUTE][NAME]object_scope[/NAME][ALIAS]Object Scope[/ALIAS][TYPE]CCM_STRING[/TYPE][/CCM_ATTRIBUTE]
	[CCM_ATTRIBUTE][NAME]object_scope_lifecycle[/NAME][ALIAS]Object Scope Lifecycle[/ALIAS][TYPE]CCM_STRING[/TYPE][/CCM_ATTRIBUTE]
	[CCM_ATTRIBUTE][NAME]cr_notes[/NAME][ALIAS]CR Notes[/ALIAS][TYPE]CCM_TOGGLE[/TYPE][/CCM_ATTRIBUTE]
	[CCM_ATTRIBUTE][NAME]cr_transitions[/NAME][ALIAS]CR Transition[/ALIAS][TYPE]CCM_TOGGLE[/TYPE][/CCM_ATTRIBUTE]
	[CCM_ATTRIBUTE][NAME]cr_modifications[/NAME][ALIAS]CR Modifications[/ALIAS][TYPE]CCM_TOGGLE[/TYPE][/CCM_ATTRIBUTE]
	[CCM_ATTRIBUTE][NAME]firstname[/NAME][ALIAS]User's first name[/ALIAS][TYPE]CCM_STRING[/TYPE][/CCM_ATTRIBUTE]
	[CCM_ATTRIBUTE][NAME]lastname[/NAME][ALIAS]User's last name[/ALIAS][TYPE]CCM_STRING[/TYPE][/CCM_ATTRIBUTE]
	
	***************** Task attributes *****************
	
	[CCM_ATTRIBUTE][NAME]task_subsys[/NAME][ALIAS]Task Sub-System[/ALIAS][TYPE]CCM_LISTBOX[/TYPE][/CCM_ATTRIBUTE]
	[CCM_ATTRIBUTE][NAME]task_description[/NAME][ALIAS]Description[/ALIAS][TYPE]CCM_TEXT[/TYPE][/CCM_ATTRIBUTE]
	[CCM_ATTRIBUTE][NAME]priority[/NAME][ALIAS]Priority[/ALIAS][TYPE]CCM_LISTBOX[/TYPE][/CCM_ATTRIBUTE]
	[CCM_ATTRIBUTE][NAME]est_completion_date[/NAME][ALIAS]Estimated Completion Date[/ALIAS][TYPE]CCM_DATE[/TYPE][/CCM_ATTRIBUTE]
	[CCM_ATTRIBUTE][NAME]est_duration[/NAME][ALIAS]Estimated Duration[/ALIAS][TYPE]CCM_STRING[/TYPE][/CCM_ATTRIBUTE]
	[CCM_ATTRIBUTE][NAME]actual_duration[/NAME][ALIAS]Actual Duration[/ALIAS][TYPE]CCM_STRING[/TYPE][/CCM_ATTRIBUTE]
	[CCM_ATTRIBUTE][NAME]registration_date[/NAME][ALIAS]Registration Date[/ALIAS][TYPE]CCM_DATE[/TYPE][/CCM_ATTRIBUTE]
	[CCM_ATTRIBUTE][NAME]completion_date[/NAME][ALIAS]Completion Date[/ALIAS][TYPE]CCM_DATE[/TYPE][/CCM_ATTRIBUTE]
	[CCM_ATTRIBUTE][NAME]asgndate_begin[/NAME][ALIAS]Assigned After[/ALIAS][TYPE]CCM_DATE[/TYPE][/CCM_ATTRIBUTE]
	[CCM_ATTRIBUTE][NAME]asgndate_end[/NAME][ALIAS]Assigned Before[/ALIAS][TYPE]CCM_DATE[/TYPE][/CCM_ATTRIBUTE]
	[CCM_ATTRIBUTE][NAME]compdate_begin[/NAME][ALIAS]Completed After[/ALIAS][TYPE]CCM_DATE[/TYPE][/CCM_ATTRIBUTE]
	[CCM_ATTRIBUTE][NAME]compdate_end[/NAME][ALIAS]Completed Before[/ALIAS][TYPE]CCM_DATE[/TYPE][/CCM_ATTRIBUTE]
	[CCM_ATTRIBUTE][NAME]completed_id[/NAME][ALIAS]Completed Identification[/ALIAS][TYPE]CCM_STRING[/TYPE][/CCM_ATTRIBUTE]
	[CCM_ATTRIBUTE][NAME]completed_in[/NAME][ALIAS]Completed In[/ALIAS][TYPE]CCM_STRING[/TYPE][/CCM_ATTRIBUTE]
	[CCM_ATTRIBUTE][NAME]assigner[/NAME][ALIAS]Assigner[/ALIAS][TYPE]CCM_USER[/TYPE][/CCM_ATTRIBUTE]
	[CCM_ATTRIBUTE][NAME]resolver[/NAME][ALIAS]Resolver[/ALIAS][TYPE]CCM_USER[/TYPE][/CCM_ATTRIBUTE]
	[CCM_ATTRIBUTE][NAME]assignment_date[/NAME][ALIAS]Assignment Date[/ALIAS][TYPE]CCM_DATE[/TYPE][/CCM_ATTRIBUTE]
	[CCM_ATTRIBUTE][NAME]release[/NAME][ALIAS]Release[/ALIAS][TYPE]CCM_LISTBOX[/TYPE][/CCM_ATTRIBUTE]
	[CCM_ATTRIBUTE][NAME]keyword[/NAME][ALIAS]Keyword[/ALIAS][TYPE]CCM_STRING[/TYPE][/CCM_ATTRIBUTE]
	
	***************** Object attributes *****************
	
	[CCM_ATTRIBUTE][NAME]owner[/NAME][ALIAS]Owner of Object[/ALIAS][TYPE]CCM_USER[/TYPE][/CCM_ATTRIBUTE]
	[CCM_ATTRIBUTE][NAME]subsystem[/NAME][ALIAS]Sub-System[/ALIAS][TYPE]CCM_STRING[/TYPE][/CCM_ATTRIBUTE]
	[CCM_ATTRIBUTE][NAME]version[/NAME][ALIAS]Object Version[/ALIAS][TYPE]CCM_STRING[/TYPE][/CCM_ATTRIBUTE]
	[CCM_ATTRIBUTE][NAME]type[/NAME][ALIAS]Object Type[/ALIAS][TYPE]CCM_STRING[/TYPE][/CCM_ATTRIBUTE]
	[CCM_ATTRIBUTE][NAME]description[/NAME][ALIAS]Folder Description[/ALIAS][TYPE]CCM_TEXT[/TYPE][/CCM_ATTRIBUTE]
	
	***************** Textual Replacement Variables *****************
	
	[CCM_ATTRIBUTE][NAME]ASSOCIATED_TASK[/NAME][ALIAS]Associated Task[/ALIAS][TYPE]CCM_STRING[/TYPE][/CCM_ATTRIBUTE]
	[CCM_ATTRIBUTE][NAME]associated_cv[/NAME][ALIAS]Associated Object(s)[/ALIAS][TYPE]CCM_RELATION[/TYPE][/CCM_ATTRIBUTE]
	[CCM_ATTRIBUTE][NAME]has_associated_task[/NAME][ALIAS]Associated CR(s)[/ALIAS][TYPE]CCM_RELATION[/TYPE][/CCM_ATTRIBUTE]
	
	***************** Utility *****************
	
	[CCM_ATTRIBUTE][NAME]TASKSTATES[/NAME][ALIAS]Task States[/ALIAS][TYPE]CCM_LISTBOX[/TYPE][/CCM_ATTRIBUTE]
	[CCM_ATTRIBUTE][NAME]TASK_DATABASE[/NAME][ALIAS]Task Database[/ALIAS][TYPE]CCM_LISTBOX[/TYPE][/CCM_ATTRIBUTE]
	[CCM_ATTRIBUTE][NAME]all_releases[/NAME][ALIAS]All Releases[/ALIAS][TYPE]CCM_LISTBOX[/TYPE][/CCM_ATTRIBUTE]
	[CCM_ATTRIBUTE][NAME]inactive_releases[/NAME][ALIAS]Inactive Releases[/ALIAS][TYPE]CCM_LISTBOX[/TYPE][/CCM_ATTRIBUTE]
	[CCM_ATTRIBUTE][NAME]active_releases[/NAME][ALIAS]Active Releases[/ALIAS][TYPE]CCM_LISTBOX[/TYPE][/CCM_ATTRIBUTE]

A ChangeSynergy attribute is:

	[CCM_ATTRIBUTE]
		[NAME]
			The ChangeSynergy Attribute name.
		[/NAME]
		[TYPE]
			The Web visualization data type, 
			available types are: CCM_STRING, CCM_TEXT, CCM_LISTBOX,
			and CCM_VALUELISTBOX.
		[/TYPE]
		[ROLE NAME]
			Optional role based aliases.
			There can be as many role options as there are defined web roles.
			Where "ROLE NAME" and "/ROLE NAME" are the literal role name.
		[/ROLE NAME]...
		[ALIAS]
			The default alias value for the attribute. This value is returned
			if role options are not used or if the users role is not specified.

			The [ALIAS] tag set defines the default, if no [ALIAS] tag exists
			the [NAME] is returned.
		[/ALIAS]
	[/CCM_ATTRIBUTE]

The [NAME] is identified through the getName() method.
The [TYPE] is identified through the getType() method.
The [ALIAS] is identified through the getLabel() method.
The [ROLE NAME] option is not available through the api.

The return result is an instance of the L<apiData> class.

 Parameters:
	apiUser         aUser   : The current api user's login data.
	apiObjectVector attrData: The data to be processed by the api function.
 
 Returns: apiData
	The return message from the server.

 Example:

	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "User", "\\\\your_hostname\\ccmdb\\cm_database");

		my $attrData = new ChangeSynergy::apiObjectVector();

		my $objData = new ChangeSynergy::apiObjectData();
		$objData->setName("cost");
		$objData->setType("CCM_STRING");
		$objData->setLabel("Cost");
		$attrData->addDataObject($objData);

		my $objData = new ChangeSynergy::apiObjectData();
		$objData->setName("customer_priority");
		$objData->setType("CCM_LISTBOX");
		$objData->setLabel("Customer Priority");
		$attrData->addDataObject($objData);

		my $objData = new ChangeSynergy::apiObjectData();
		$objData->setName("version_fixed");
		$objData->setType("CCM_STRING");
		$objData->setLabel("Version Fixed");
		$attrData->addDataObject($objData);

		$tmp = $csapi->SetAttributes($aUser, "dwarves", $tmp);

		print $tmp->getResponseData();
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<setFolderSecurityRule>

Sets the folder security information for a given folder. The folder security information
consists of the name of the folder, the read security members and the write security members. You
can also empty the rule by supplying the folder name with no readers or writers.
The return result is an instance of the L<apiData> class.

 Parameters:
	apiUser            aUser      : The current api user's login data.
	FolderSecurityrule folderRule : The folder security rule object for the folder.
	scalar             objectType : The object type for the folder.
	scalar             formatType : The format type of the folder: report, query or report format.
	scalar             configType : The configuration location for the report.

 Returns: apiData
	a apiData with a message about the success or failure of the update.
 
 Example:
 
	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "User", "\\\\angler\\ccmdb\\cm_database");
		my $globals = new ChangeSynergy::Globals();
		
		#Get the folder security rule for the "all" CR Shared query folder.
		my $folderRule = $csapi->getFolderSecurityRule($aUser, "", $globals->{PROBLEM_TYPE}, $globals->{QUERY},
						 $globals->{SHARED_PROFILE});
		
		$folderRule->addReadMember("someone");
		$folderRule->addWriteMember("someone else");
		
		my $result = $csapi->setFolderSecurityRule($aUser, $folderRule, $globals->{PROBLEM_TYPE}, $globals->{QUERY}, $globals->{SHARED_PROFILE});
		print $result->getResponseData() . "\n";
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<setQueryConfigType>

Set up the config type to use when running a query.  There are four config
types that can be specified, user, shared, system and all.  The user config type
will only search the users saved information.  The shared config type will only search
the shared config and system will only search the system config.  All will
search the user, then shared and finally the system config and run the the first
query that matches the request.

 Parameters:
	scalar configType: The config entry to search through for the query.
	
	Valid Config Types: These are defined in the Globals class.
        $self->{ALL}       		// User, Shared and System. Returns the first one found.
        $self->{USER_PROFILE}	// A single users profile data.
        $self->{SHARED_PROFILE} // The shared profile data.
	    $self->{SYSTEM_CONFIG}  // The system config data.

 Example:

	my $csapi = new ChangeSynergy::csapi();

 	eval
	{
		my $globals = new ChangeSynergy::Globals();
		
				
		#set the config type for the query.
 		$csapi->setQueryConfigType($globals->{USER_PROFILE});
 		or
 		$csapi->setQueryConfigType($globals->{SHARED_PROFILE});
 		or
 		$csapi->setQueryConfigType($globals->{SYSTEM_CONFIG});
 		or
 		$csapi->setQueryConfigType($globals->{ALL});
 		
 		#set the config type for the report format.
 		$csapi->setReportConfigType($globals->{USER_PROFILE});
 		or
 		$csapi->setReportConfigType($globals->{SHARED_PROFILE});
 		or
 		$csapi->setReportConfigType($globals->{SYSTEM_CONFIG});
 		or
 		$csapi->setReportConfigType($globals->{ALL});
	
		my $tmpstr = $csapi->ImmediateReportHtml($aUser, "Basic Summary", "Basic Summary Report");
 		
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<setReportConfigType>

Set up the config type to use when running a report.  There are four config
types that can be specified, user, shared, system and all.  The user config type
will only search the users saved information.  The shared config type will only search
the shared config and system will only search the system config.  All will
search the user, then shared and finally the system config and run the the first
report that matches the request.

 Parameters:
	scalar configType: The config entry to search through for the report.
	
	Valid Config Types: These are defined in the Globals class.
		$self->{ALL}       		// User, Shared and System. Returns the first one found.
		$self->{USER_PROFILE}	// A single users profile data.
		$self->{SHARED_PROFILE} // The shared profile data.
		$self->{SYSTEM_CONFIG}  // The system config data.

 Example:

	my $csapi = new ChangeSynergy::csapi();

 	eval
	{
		my $globals = new ChangeSynergy::Globals();
		
		$csapi->setUpConnection("http://your_hostname:port/your_context");
		my $aUser = $csapi->Login("u00001", "u00001", "User", "\\\\your_hostname\\ccmdb\\cm_database");
		
		
		#set the config type for the report.
 		$csapi->setReportConfigType($globals->{USER_PROFILE});
 		or
 		$csapi->setReportConfigType($globals->{SHARED_PROFILE});
 		or
 		$csapi->setReportConfigType($globals->{SYSTEM_CONFIG});
 		or
 		$csapi->setReportConfigType($globals->{ALL});
	
		my $tmpstr = $csapi->ImmediateReportHtml($aUser, "Basic Summary", "Basic Summary Report");
 		
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<setUpConnection>

Set up the connection information for calling API functions. This function is overloaded,
with a 1 parameter and 3 parameter version.

 Single Parameter:
	scalar URL: URL of the application

 Three Parameters (deprecated):
	scalar protocol: The Web/WWW/Internet protocol
	scalar host : The fully qualified host name. (Internet)
	The machine name. (Intranet)
	scalar port : The port number for the web site.

 NOTE: For three parameter version of API, the context "/change" will be added by default.

 Example:

	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<ShowCRHtml>

Show the details of a Change Request as an HTML web page. The IBM Rational Change
server determines which template to use. The return result is an
instance of the L<apiData> class.

 Note: The return value is a complete HTML page. <HTML>...</HTML>
       The return value can be saved as a .html file, or loaded
       into a browser window/control.

 Parameters:
	apiUser aUser        : The current api user's login data.
	scalar  problemNumber: The Change Request ID/Problem Number ID to reference.
	scalar  relationName : A valid IBM Rational Synergy/IBM Rational Change relation name.
	scalar  isModifiable : A string representation of either: ["true"|"false"].

 Returns: apiData
	the complete show form as an html page.

 Example:
 
	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "User", "\\\\your_hostname\\ccmdb\\cm_database");

		my $tmpstr = $csapi->ShowCRHtml($aUser, "1347", "child_cr", "true");
	};

	if ($@)
	{
		print $@;
	}

=cut

#############################################################################

=item B<ShowCRHtml>

Show the details of a Change Request as an HTML web page. The
IBM Rational Change server uses the template name provided. The return 
result is an instance of the L<apiData> class.

 Note: The return value is a complete HTML page. <HTML>...</HTML>
       The return value can be saved as a .html file, or loaded
       into a browser window/control.

 Parameters:
	apiUser aUser        : The current api user's login data.
	scalar  problemNumber: The Change Request ID/Problem Number ID to reference.
	scalar  templateName : The name of the IBM Rational Change template to load 
	                       ([CCM_TEMPLATE][NAME]template name[/NAME]...[/CCM_TEMPLATE]).
	scalar  relationName : A valid IBM Rational Synergy/IBM Rational Change relation name.
	scalar  isModifiable : A string representation of either: ["true"|"false"].

Returns: apiData
	the complete show form as an html page.

 Example:
 
	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "User", "\\\\your_hostname\\ccmdb\\cm_database");

		my $tmpstr = $csapi->ShowCRHtml($aUser, "1347", "CRDetail", undef, undef);
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<ShowCRUrl>

Show the details of a Change Request as an HTML web page. The IBM Rational Change
server determines which template to use. The return result is an
instance of the L<apiData> class.

 Note: The return value is a complete URL address
       The return value can be saved as a link, or loaded
       into a browser window/control.

 Parameters:
	apiUser aUser        : The current api user's login data.
	scalar  problemNumber: The Change Request ID/Problem Number ID to reference.
	scalar  relationName : A valid IBM Rational Synergy/IBM Rational Change relation name.
	scalar  isModifiable : A string representation of either: ["true"|"false"].

 Returns: apiData
	the complete show form as an html page.

 Example:
 
	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "User", "\\\\your_hostname\\ccmdb\\cm_database");

		my $tmpstr = $csapi->ShowCRUrl($aUser, "1347", "child_cr", "true");
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<ShowCRUrl>

Show the details of a Change Request as an HTML web page. The
IBM Rational Change server uses the template name provided. The return 
result is an instance of the L<apiData> class.

 Note: The return value is a complete URL address.
       The return value can be saved as a link, or loaded
       into a browser window/control.

 Parameters:
	apiUser aUser        : The current api user's login data.
	scalar  problemNumber: The Change Request ID/Problem Number ID to reference.
	scalar  templateName : The name of the IBM Rational Change template to load 
	                       ([CCM_TEMPLATE][NAME]template name[/NAME]...[/CCM_TEMPLATE]).
	scalar  relationName : A valid IBM Rational Synergy/IBM Rational Change relation name.
	scalar  isModifiable : A string representation of either: ["true"|"false"].

Returns: apiData
	the show form as a URL address.

 Example:
 
	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "User", "\\\\your_hostname\\ccmdb\\cm_database");

		my $tmpstr = $csapi->ShowCRUrl($aUser, "1347", "CRDetail", undef, undef);
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<ShowTaskHtml>

Show the details of a Task as an HTML web page. The IBM Rational Change server
determines which template to use, based on the Task's current status value.
The return result is an instance of the L<apiData> class.

 Note: The return value is a complete HTML page. <HTML>...</HTML>
       The return value can be saved as a .html file, or loaded
       into a browser window/control.

 Parameters:
	apiUser aUser       : The current api user's login data.
	scalar  taskNumber  : The Task ID to reference.
	scalar  relationName: A valid IBM Rational Synergy/IBM Rational Change relation name.
	scalar  isModifiable: A string representation of either: ["true"|"false"].

 Returns: apiData
	the show task details page as an HTML page.
 
 Example:

	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "User", "\\\\your_hostname\\ccmdb\\cm_database");

		my $tmpstr = $csapi->ShowTaskHtml($aUser, "1", undef, undef);
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<ShowTaskHtml>

Show the details of a Task as an HTML web page. The IBM Rational Change server
uses the provided template name. The return result is an instance
of the L<apiData> class.

 Note: The return value is a complete HTML page. <HTML>...</HTML>
       The return value can be saved as a .html file, or loaded
       into a browser window/control.

 Parameters:
	apiUser aUser       : The current api user's login data.
	scalar  taskNumber  : The Task ID to reference.
	scalar  templateName: The name of the IBM Rational Change template to load 
	                      ([CCM_TEMPLATE][NAME]template name[/NAME]...[/CCM_TEMPLATE]).
	scalar  relationName: A valid IBM Rational Synergy/IBM Rational Change relation name.
	scalar  isModifiable: A string representation of either: ["true"|"false"].

 Returns: apiData
	the show task details page as an HTML page.

 Example:

	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "User", "\\\\your_hostname\\ccmdb\\cm_database");

		my $tmpstr = $csapi->ShowTaskHtml($aUser, "1", "TaskDetails", undef, undef);
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<ShowTaskUrl>

Show the details of a Task as an HTML web page. The IBM Rational Change server
determines which template to use, based on the Task's current status value.
The return result is an instance of the L<apiData> class.

 Note: The return value is a complete URL address.
       The return value can be saved as a link, or loaded
       into a browser window/control.

 Parameters:
	apiUser aUser       : The current api user's login data.
	scalar  taskNumber  : The Task ID to reference.
	scalar  relationName: A valid IBM Rational Synergy/IBM Rational Change relation name.
	scalar  isModifiable: A string representation of either: ["true"|"false"].

 Returns: apiData
	the URL to the show task details page.
 
 Example:

	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "User", "\\\\your_hostname\\ccmdb\\cm_database");

		my $tmpstr = $csapi->ShowTaskUrl($aUser, "1", undef, undef);
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<ShowTaskUrl>

Show the details of a Task as an HTML web page. The IBM Rational Change server
uses the provided template name. The return result is an instance 
of the L<apiData> class.

 Note: The return value is a complete URL address.
       The return value can be saved as a link, or loaded
       into a browser window/control.

 Parameters:
	apiUser aUser       : The current api user's login data.
	scalar  taskNumber  : The Task ID to reference.
	scalar  templateName: The name of the IBM Rational Change template to load 
	                      ([CCM_TEMPLATE][NAME]template name[/NAME]...[/CCM_TEMPLATE]).
	scalar  relationName: A valid IBM Rational Synergy/IBM Rational Change relation name.
	scalar  isModifiable: A string representation of either: ["true"|"false"].

 Returns: apiData
	the URL to the show task details page.

 Example:

	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "User", "\\\\your_hostname\\ccmdb\\cm_database");

		my $tmpstr = $csapi->ShowTaskUrl($aUser, "1", "TaskDetails", undef, undef);
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<StartServerAccess>

Restart server access on the IBM Rational Change Server.

This is a low-level API that ordinarily doesn't need to be explicitly called.
Operations that need to block server access (such as updating configuration
data or managing session pools) already do so internally. However, you could
use these APIs to block server access for other reasons, such as when
database maintenance is occurring.

StartServerAccess and StopServerAccess function according to a stack model:
each StopServerAccess call should have a corresponding StartServerAccess call.
For instance, if StopServerAccess was called twice in a row, StartServerAccess
would likewise have to be called twice for server access to be restored.

The return result is an instance of the L<apiData> class.

 Parameters:
	apiUser aUser: The current api user's login data.

 Returns: apiData
	the return message from the server.
 
 Example:

	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "Admin", "\\\\your_hostname\\ccmdb\\cm_database");

		my $tmpstr = $csapi->StartServerAccess($aUser);
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<StopServerAccess>

Stop server access on the IBM Rational Change Server.

This is a low-level API that ordinarily doesn't need to be explicitly called.
Operations that need to block server access (such as updating configuration
data or managing session pools) already do so internally. However, you could
use these APIs to block server access for other reasons, such as when
database maintenance is occurring.

StartServerAccess and StopServerAccess function according to a stack model:
each StopServerAccess call should have a corresponding StartServerAccess call.
For instance, if StopServerAccess was called twice in a row, StartServerAccess
would likewise have to be called twice for server access to be restored.

The return result is an instance of the L<apiData> class.

 Parameters:
	apiUser aUser: The current api user's login data.

 Returns: apiData
	the return message from the server.
 
 Example:

	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "Admin", "\\\\your_hostname\\ccmdb\\cm_database");

		my $tmpstr = $csapi->StopServerAccess($aUser);
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<SubmitCR>

Apply the modified Change Request data. Only data objects that have 
been flagged as modified are submitted to the IBM Rational Change server. 
The attributes problem_number, modify_time, and cvid should 
not be altered. The api classes will automatically process these attributes
when needed. The return result is an instance of the L<apiData> class.

Note: The L<apiObjectData>'s member method setValue("") will automatically set
the modified flag when invoked.

 Parameters:
	apiUser         aUser: The current api user's login data.
	apiObjectVector data : The data to be processed by the api function.
 
 Returns: apiData
	results only if the submit was successful	
 
 Example:

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "User", "\\\\your_hostname\\ccmdb\\cm_database");

		my $tmp = $csapi->SubmitCRData($aUser, "START_HERE2entered");

		my $i;
		my $j = $tmp->getDataSize();

		for($i=0;$i<$j;$i++)
		{
			if($tmp->getDataObject($i)->getRequired())
			{
				$tmp->getDataObject($i)->setValue("I must supply a value here to successfully complete a submit...");
			}
		}

		$tmp->getDataObjectByName("problem_synopsis")->setValue("I submitted this through the csapi");
		$tmp->getDataObjectByName("problem_description")->setValue("Yes, isn't this great!!!!");
		$tmp->getDataObjectByName("severity")->setValue("Showstopper");
		$tmp->getDataObjectByName("product_name")->setValue("Product A");
		$tmp->getDataObjectByName("submitter")->setValue("u00001");
		$tmp->getDataObjectByName("request_type")->setValue("Defect");

		$tmp->getDataObjectByName("crstatus")->setValue($tmp->getTransitionLink(0)->getToState());
		
		my $tmpstr = $csapi->SubmitCR($aUser, $tmp);
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<SubmitCRAssocCR>

Apply the modified Change Request data. Only data objects that have been
flagged as modified are submitted to the IBM Rational Change server. The attributes
problem_number, modify_time, and cvid should not be altered. The api classes
will automatically process these attributes when needed. The return result is
an instance of the L<apiData> class.

Note: The L<apiObjectData>'s member method setValue("") will automatically set
the modified flag when invoked.

 Parameters:
	apiUser         aUser        : The current api user's login data.
	apiObjectVector data         : The data to be processed by the api function.
	scalar          relationName : A valid IBM Rational Synergy/IBM Rational Change relation name.
	scalar          problemNumber: The Change Request ID/Problem Number ID to reference.
 
 Returns: apiData
	results only if the submit and association was successful	
 
 Example 1:
 
	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "User", "\\\\your_hostname\\ccmdb\\cm_database");

		my $tmp = $csapi->SubmitCRData($aUser, "START_HERE2entered");

		my $i;
		my $j = $tmp->getDataSize();

		for($i=0;$i<$j;$i++)
		{
			if($tmp->getDataObject($i)->getRequired())
			{
				$tmp->getDataObject($i)->setValue("I must supply a value here to successfully complete a submit...");
			}
		}

		$tmp->getDataObjectByName("problem_synopsis")->setValue("I submitted this through the csapi");
		$tmp->getDataObjectByName("problem_description")->setValue("Yes, isn't this great!!!!");
		$tmp->getDataObjectByName("severity")->setValue("Showstopper");
		$tmp->getDataObjectByName("product_name")->setValue("Product A");
		$tmp->getDataObjectByName("submitter")->setValue($aUser->getUserName());
		$tmp->getDataObjectByName("request_type")->setValue("Defect");

		$tmp->getDatagetDataObjectByNameObject("crstatus")->setValue($tmp->getTransitionLink(0)->getToState());
		
		$tmpstr = $csapi->SubmitCRAssocCR($aUser, $tmp, "child_cr", "1347");
	};

	if ($@)
	{
		print $@;
	}

 Example 2:
 
	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "User", "\\\\your_hostname\\ccmdb\\cm_database");

		my $tmp = $csapi->CopyCRData($aUser, "1347", "COPY_child_cr2new_child");

		my $i;
		my $j = $tmp->getDataSize();

		for($i=0;$i<$j;$i++)
		{
			if($tmp->getDataObject($i)->getRequired())
			{
				$tmp->getDataObject($i)->setValue("I must supply a value here to successfully complete a submit...");
			}

			if($tmp->getDataObject($i)->getInherited())
			{
				$tmp->getDataObject($i)->setIsModified(TRUE);
			}
		}

		$tmp->getDataObjectByName("problem_synopsis")->setValue("I submitted this through the csapi");
		$tmp->getDataObjectByName("problem_description")->setValue("Yes, isn't this great!!!!");
		$tmp->getDataObjectByName("severity")->setValue("Showstopper");
		$tmp->getDataObjectByName("product_name")->setValue("Product A");
		$tmp->getDataObjectByName("submitter")->setValue("u00001");
		$tmp->getDataObjectByName("request_type")->setValue("Defect");

		$tmp->getDataObject("crstatus")->setValue($tmp->getTransitionLink(0)->getToState());
		
		my $tmpstr = $csapi->SubmitCRAssocCR($aUser, $tmp, $tmp->getTransitionLink(0)->getRelation(), "1347");
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<SubmitCRData>

Load the requirements of a Change Request submission into data classes
in which the details of the new Change Request can be modified. The modified
data classes can then be submitted using one of the modification api 
functions to change a Change Request. The return result is an instance
of the L<apiObjectVector> class.
 
Note: The submit "to state" is provided with this api function call.
See L<apiTransitions> class description.

 Parameters:
	apiUser aUser       : The current api user's login data.
	scalar  templateName: The name of the IBM Rational Change template to load
	                      ([CCM_TEMPLATE][NAME]template name[/NAME]...[/CCM_TEMPLATE]).

 Returns: apiObjectVector
	the requirements of a CR submission in data format
 
 Example:

	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "User", "\\\\your_hostname\\ccmdb\\cm_database");

		my $tmp = $csapi->SubmitCRData($aUser, "START_HERE2entered");

		my $tmpstr = $tmp->getXmlData();
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<SubmitCRHtml>

Load, as an HTML web page, the requirements to submit a Change Request.
The return result is an instance of the L<apiData> class.

 Note: The return value is a complete HTML page. <HTML>...</HTML>
       The return value can be saved as a .html file, or loaded
       into a browser window/control.
	   
 Parameters:
	apiUser aUser        : The current api user's login data.
	scalar  templateName : The name of the IBM Rational Change template to load
	                       ([CCM_TEMPLATE][NAME]template name[/NAME]...[/CCM_TEMPLATE]).
	scalar  problemNumber: The Change Request ID/Problem Number ID to reference.
	scalar  relationName : A valid IBM Rational Synergy/IBM Rational Change relation name.
	scalar  externalData : A string of XML data to pass to a submit request.
 
 Format of External Data XML:
 
 <EXTERNAL_CONTEXT_DATA>
 	<ATTRIBUTE NAME="attribute_name">your value</ATTRIBUTE>
 	<ATTRIBUTE NAME="attribute_name">your value</ATTRIBUTE>
 	<ATTRIBUTE NAME="attribute_name">your value</ATTRIBUTE>
 	.
 	.
 	.
 </EXTERNAL_CONTEXT_DATA>
 
 Returns: apiData
	the submit CR page requested as an html page.

 Example:

	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "User", "\\\\your_hostname\\ccmdb\\cm_database");

		my $tmpstr = $csapi->SubmitCRHtml($aUser, "CRSubmit", undef, undef, undef);
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<SubmitCRUrl>

Load, as an HTML web page, the requirements to submit a Change Request.
The return result is an instance of the L<apiData> class.

 Note: The return value is a complete URL address.
       The return value can be saved as a link, or loaded
       into a browser window/control.
	   
 Parameters:
	apiUser aUser        : The current api user's login data.
	scalar  templateName : The name of the IBM Rational Change template to load ([CCM_TEMPLATE][NAME]template name[/NAME]...[/CCM_TEMPLATE]).
	                       ([CCM_TEMPLATE][NAME]template name[/NAME]...[/CCM_TEMPLATE]).
	scalar  problemNumber: The Change Request ID/Problem Number ID to reference.
	scalar  relationName : A valid IBM Rational Synergy/IBM Rational Change relation name.
	scalar  externalData : A string of XML data to pass to a submit request.
 
 Format of External Data XML:
 
 <EXTERNAL_CONTEXT_DATA>
 	<ATTRIBUTE NAME="attribute_name">your value</ATTRIBUTE>
 	<ATTRIBUTE NAME="attribute_name">your value</ATTRIBUTE>
 	<ATTRIBUTE NAME="attribute_name">your value</ATTRIBUTE>
 	.
 	.
 	.
 </EXTERNAL_CONTEXT_DATA>
 
 Returns: apiData
	the submit CR page requested as an html page.

 Example:

	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "User", "\\\\your_hostname\\ccmdb\\cm_database");

		my $tmpstr = $csapi->SubmitCRUrl($aUser, "CRSubmit", undef, undef, undef);
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<SubmitTask>

Apply the modified Task data. Only data objects that have been flagged as
modified are submitted to the IBM Rational Change server. The attributes task_number,
modify_time, and cvid should not be altered. The api classes will automatically
process these attributes when needed. The return result is an instance of 
the L<apiData> class.

Note: The L<apiObjectData>'s member method setValue("") will automatically set
the modified flag when invoked.

 Parameters:
	apiUser         aUser: The current api user's login data.
	apiObjectVector data : The data to be processed by the api function.

 Returns: apiData
	results only if the submit was successful	

 Example 1:

	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "User", "\\\\your_hostname\\ccmdb\\cm_database");

		my $tmp = $csapi->SubmitTaskData($aUser, "TaskCreate");
		
		my $i;
		my $j = $tmp->getDataSize();

		for($i=0;$i<$j;$i++)
		{
			if($tmp->getDataObject($i)->getRequired())
			{
				$tmp->getDataObject($i)->setValue("I must supply a value here to successfully complete a submit...");
			}
		}

		$tmp->getDataObjectByName("task_synopsis")->setValue("I modified the synopsis through the csapi...");
		$tmp->getDataObjectByName("task_description")->setValue("I modified the description through the csapi...");
		$tmp->getDataObjectByName("priority")->setValue("high");
		$tmp->getDataObjectByName("resolver")->setValue($aUser->getUserName());

		my $tmpstr = $csapi->SubmitTask($aUser, $tmp);
	};


	if ($@)
	{
		print $@;
	}


 Example 2:

	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "User", "\\\\your_hostname\\ccmdb\\cm_database");

		my $tmp = $csapi->CopyTaskData($aUser, "12", "CreateTask");
		
		my $i;
		my $j = $tmp->getDataSize();

		for($i=0;$i<$j;$i++)
		{
			if($tmp->getDataObject($i)->getRequired())
			{
				if($tmp->getDataObject($i)->getValue() == NULL)
					$tmp->getDataObject($i)->setValue("I must supply a value here to successfully complete a submit...");
			}
		}

		$tmp->getDataObjectByName("task_synopsis")->setValue("I modified the synopsis through the csapi...");
		$tmp->getDataObjectByName("task_description")->setValue("I modified the description through the csapi...");
		$tmp->getDataObjectByName("priority")->setValue("high");
		$tmp->getDataObjectByName("resolver")->setValue($aUser->getUserName());

		my $tmpstr = $csapi->SubmitTask($aUser, $tmp);
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<SubmitTaskAssocCR>

Apply the modified Task data. Only data objects that have been flagged as
modified are submitted to the IBM Rational Change server. The attributes task_number, 
modify_time, and cvid should not be altered. The api classes will automatically
process these attributes when needed. The return result is an instance of the 
L<apiData> class.

Note: The L<apiObjectData>'s member method setValue("") will automatically set
the modified flag when invoked.

 Parameters:
	apiUser         aUser        : The current api user's login data.
	apiObjectVector data         : The data to be processed by the api function.
	scalar          relationName : A valid IBM Rational Synergy/IBM Rational Change relation name.
	scalar          problemNumber: The Change Request ID/Problem Number ID to reference.

 Returns: apiData
	results only if the submit and association was successful	

 Example:

	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "User", "\\\\your_hostname\\ccmdb\\cm_database");

		my $tmp = $csapi->SubmitTaskData($aUser, "TaskCreate");
		
		my $i;
		my $j = $tmp->getDataSize();

		for($i=0;$i<$j;$i++)
		{
			if($tmp->getDataObject($i)->getRequired())
			{
				$tmp->getDataObject($i)->setValue("I must supply a value here to successfully complete a submit...");
			}
		}

		$tmp->getDataObjectByName("task_synopsis")->setValue("I modified the synopsis through the csapi...");
		$tmp->getDataObjectByName("task_description")->setValue("I modified the description through the csapi...");
		$tmp->getDataObjectByName("priority")->setValue("high");
		$tmp->getDataObjectByName("resolver")->setValue($aUser->getUserName());

		my $tmpstr = $csapi->SubmitTaskAssocCR($aUser, $tmp, "associated_task", "1355");
	};


	if ($@)
	{
		print $@;
	}

=cut

##############################################################################


=item B<SubmitTaskData>

Load the requirements of a Task submission into data classes in which 
the details of the new Task can be modified. The modified data classes
can then be submitted using one of the modification api functions 
to change a Task. The return result is an instance of the L<apiObjectVector> class.

 Parameters:
 	apiUser aUser       : The current api user's login data.
	scalar  templateName: The name of the IBM Rational Change template to load
	                      ([CCM_TEMPLATE][NAME]template name[/NAME]...[/CCM_TEMPLATE]).

 Returns: apiObjectVector
	the requirements of a task submission in data format.

 Example:
 
	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "User", "\\\\your_hostname\\ccmdb\\cm_database");

		my $tmp = $csapi->SubmitTaskData($aUser, "CreateTask");

		my $tmpstr = $tmp->getXmlData();
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<SubmitTaskHtml>

Load, as an HTML web page, the requirements to submit a Task.
The return result is an instance of the L<apiData> class.

 Note: The return value is a complete HTML page. <HTML>...</HTML>
       The return value can be saved as a .html file, or loaded
       into a browser window/control.

 Parameters:
	apiUser aUser       : The current api user's login data.
	scalar  templateName: The name of the IBM Rational Change template to load 
	                      ([CCM_TEMPLATE][NAME]template name[/NAME]...[/CCM_TEMPLATE]).

 Returns: apiData
	the submit task page requested as an html page.

 Example:

	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "User", "\\\\your_hostname\\ccmdb\\cm_database");

		my $tmpstr = $csapi->SubmitTaskHtml($aUser, "TaskCreate");
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<SubmitTaskUrl>

Load, as an HTML web page, the requirements to submit a Task.
The return result is an instance of the L<apiData> class.

 Note: The return value is a complete URL address.
       The return value can be saved as a link, or loaded
       into a browser window/control.

 Parameters:
	apiUser aUser       : The current api user's login data.
	scalar  templateName: The name of the IBM Rational Change template to load 
	                      ([CCM_TEMPLATE][NAME]template name[/NAME]...[/CCM_TEMPLATE]).

 Returns: apiData
	the URL for the submit Task page.

 Example:

	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "User", "\\\\your_hostname\\ccmdb\\cm_database");

		my $tmpstr = $csapi->SubmitTaskUrl($aUser, "TaskCreate");
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<SwitchUser>

Allows the local admin user to switch to an arbitrary user.
The return result is an instance of the L<apiUser> class.

 Parameters:
    apiUser localAdminUser: The login data of the local admin user.
	scalar targetUserName : The name of the target user.
	scalar targetRole     : The role for the target user.
	scalar targetDatabase : The IBM Rational Synergy database path for the user.

 Returns: apiUser
	a new instance of a apiUser class with the specified information.

 Example:

	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $localAdminUser = $csapi->Login("admin", "localAdminPassword", "Admin", "\\\\your_hostname\\ccmdb\\cm_database");
		
		my $aTargetUser = $csapi->SwitchUser($localAdminUser, "u00002", "User", "\\\\your_hostname\\ccmdb\\cm_database");
	};

	if ($@)
	{
		print $@;
	}

=cut

###############################################################################

=item B<SyncDatabase>

In central server mode, waits for the central server to finish syncing
all its CRs into a particular database. This call is never required,
since central CRs are automatically synced to all other databases,
but this allows you to wait for all pending updates to complete.

For example, if a script quickly modifies a large number of CRs, it may take
a while for these changes to be synced. If subsequent actions in the script
depend on a particular database being in sync with the the central database,
the script can call this function to wait for all those changes to sync.
Once up-to-date, this call function will return and the script can proceed.
Changes made after this function call--even while this is waiting--are ignored.

Times out if the database is online, but hasn't synced any CRs in a while.
 
 Parameters:

	apiUser user:     The current API user's login data.
	scalar  database: The database to sync and wait for. Must be online.
 
 Returns: 
	Nothing. Returns silently once the sync has completed. If no updates
	are pending, returns immediately.

=cut

##############################################################################

=item B<TaskFullName>

Construct a four part name for a task. The actual existance of the task is not
checked; this only constructs the four part name.
 
 Parameters:

	apiUser aUser:      The current api user's login data.
	scalar  taskNumber: The task number.
 
 Returns: scalar
	The four part name.

=cut

##############################################################################

=item B<ToggleDebug>

Toggle the debug flag on the IBM Rational Change server.
The return result is an instance of the L<apiData> class.

 Parameters:
	apiUser aUser:  The current api user's login data.
	scalar  enable: "true" to enable debugging and "false" to disable debugging, this 
	                parameter is optional, if not specified debugging will be toggled
	                to the opposite of it's current, e.g. from on to off, or off to on.

 Returns: apiData
	the return message from the server.
 
 Example:

	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "Admin", "\\\\your_hostname\\ccmdb\\cm_database");

		my $debugString = $csapi->ToggleDebug($aUser);
		or
		my $debugString = $csapi->ToggleDebug($aUser, "true");
		or
		my $debugString = $csapi->ToggleDebug($aUser, "false");
		
		print $debugString->getResponseData() . "\n";
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<TransitionCR>

Apply the modified Change Request data. Only data objects that have been
flagged as modified are submitted to the IBM Rational Change server. The attributes
problem_number, modify_time, and cvid should not be altered. The api classes 
will automatically process these attributes when needed. The return result is
an instance of the L<apiData> class.
 
Note: The apiObjectData's member method setValue("") will automatically set
the modified flag when invoked.

 Parameters:
	apiUser         aUser: The current api user's login data.
	apiObjectVector data : The data to be processed by the api function.

 Returns: apiData
	results only if the transition was successful
 
 Example:
 
	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "User", "\\\\your_hostname\\ccmdb\\cm_database");

		my $tmp1 = $csapi->AttributeModifyCRData($aUser, "100", "crstatus");
		or
		my $tmp1 = $csapi->AttributeModifyCRData($aUser, "100");
		or
		my $tmp1 = $csapi->ModifyCRData($aUser, "100", "CRDetail");
		or
		my $tmp1 = $csapi->GetCRData($aUser, "100", "problem_synopsis|problem_description|keyword");
		
		my $tmp2 = $csapi->TransitionCRData($aUser, "100", $tmp1->getTransitionLink(1)->getTransition());

		$tmp2->getDataObjectByName("problem_synopsis")->setValue("I modified the synopsis through the csapi...");
		$tmp2->getDataObjectByName("problem_description")->setValue("I modified the description through the csapi...");
		$tmp2->getDataObjectByName("keyword")->setValue("csapi");

  		$tmp2->getDataObjectByName("crstatus")->setValue($tmp1->getTransitionLink(1)->getToState());

		my $tmpstr = $csapi->TransitionCR($aUser, $tmp2);
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<TransitionCRData>

Load the details of a Change Request into data classes in which the 
details of the Change Request can be modified. The modified data classes
can then be submitted using one of the modification api functions 
to change a Change Request. The return result is an instance of the
L<apiObjectVector> class.

Note: The transition's "from state" and "to state" are provided with this api function call.
See L<apiTransitions> class description.

 Parameters:
	apiUser aUser        : The current api user's login data.
	scalar  problemNumber: The Change Request ID/Problem Number ID to reference.
	scalar  templateName : The name of the IBM Rational Change template to load
	                       ([CCM_TEMPLATE][NAME]template name[/NAME]...[/CCM_TEMPLATE]).

 Returns: apiObjectVector
	the details of a change request in data format.

 Example:

	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "User", "\\\\your_hostname\\ccmdb\\cm_database");

		my $tmp = $csapi->TransitionCRData($aUser, "100", "assigned2resolved");

		my $tmpstr = $tmp->getXmlData();
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<TransitionTask>

Apply the modified Task data. Only data objects that have been flagged
as modified are submitted to the IBM Rational Change server. The attributes 
task_number, modify_time, and cvid should not be altered. The api classes
will automatically process these attributes when needed.

Note: The L<apiObjectData>'s member method setValue("") will automatically set
the modified flag when invoked.

 Parameters:
	apiUser         aUser: The current api user's login data.
	apiObjectVector data : The data to be processed by the api function.

 Returns: apiData
	results only if the transition was successful

 Example:
 
	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "User", "\\\\your_hostname\\ccmdb\\cm_database");

		my $tmp = $csapi->ModifyTaskData($aUser, "10", "TaskDetails");
		or
		my $tmp = $csapi->GetTaskData($aUser, "10", "task_synopsis|task_description|priority");
		or
		my $tmp = $csapi->TransitionTaskData($aUser, "10", "TaskDetails");
		
		$tmp->getDataObjectByName("task_synopsis")->setValue("I modified the synopsis through the csapi...");
		$tmp->getDataObjectByName("task_description")->setValue("I modified the description through the csapi...");
		$tmp->getDataObjectByName("priority")->setValue("high");

		$tmp->getDataObjectByName("status")->setValue("completed");

		my $tmpstr = $csapi->TransitionTask($aUser, $tmp);
	};


	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<TransitionTaskData>

Load the details of a Task into data classes in which the details
of the Task can be modified. The modified data classes can then 
be submitted using one of the modification api functions to change a Task.
The return result is an instance of the L<apiObjectVector> class.

 Parameters:
	apiUser aUser       : The current api user's login data.
	scalar  taskNumber  : The Task ID to reference.
	scalar  templateName: The name of the IBM Rational Change template to load
	                      ([CCM_TEMPLATE][NAME]template name[/NAME]...[/CCM_TEMPLATE]).

 Returns: apiObjectVector
	the details of a task in data format.	

 Example:
 
	my $csapi = new ChangeSynergy::csapi();
	
	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "User", "\\\\your_hostname\\ccmdb\\cm_database");

		my $tmp = $csapi->TransitionTaskData($aUser, "4", "TaskDetails");

		my $tmpstr = $tmp->getXmlData();
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<UninstallAPackage>

Uninstall a IBM Rational Change package. The return result is an 
instance of the L<apiData> class.

 Parameters:
	apiUser aUser       : The current api user's login data.
	scalar  packageName : The name of the package to uninstall.

 Returns: apiData
	the results only if the package uninstall was successful.

 Example:

	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "Admin", "\\\\your_hostname\\ccmdb\\cm_database");
	
		my $results = $csapi->UninstallAPackage($aUser, "dev_process");
		
		print $results->getResponseData();
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<UpdateIndex>

Update the search index on the IBM Rational Change Server.
The return result is an instance of the L<apiData> class.

 Parameters:
	apiUser aUser: The current api user's login data.

 Returns: apiData
	the return message from the server.
 
 Example:

	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "Admin", "\\\\your_hostname\\ccmdb\\cm_database");

		my $tmpstr = $csapi->UpdateIndex($aUser);
	};

	if ($@)
	{
		print $@;
	}

=cut

##############################################################################

=item B<ValidateLicense>

Validate if this license can be obtained.

 Parameters:
	apiUser aUser        : The current api user's login data.
	scalar  licenseString: The license identifier to be validated.
 
 Returns: scalar
	true or false

 Example:

	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "Admin", "\\\\your_hostname\\ccmdb\\cm_database");

		my $tmp = $csapi->ValidateLicense($aUser, "pt");
	};

	if ($@)
	{
		print $@;
	}

=cut

###############################################################################

=item B<VerifySignatures>

Verifies a Change Request's electronic signatures on a specified CCM_E_SIGNATURE
attribute.

 Parameters:
	apiUser aUser        : The current api user's login data.
	scalar  problemNumber: The problem number to verify.
	scalar  attributeName: The eleectronic signature attribute name.
 
 Returns: scalar
	true or false

 Example:

	my $csapi = new ChangeSynergy::csapi();

	eval
	{
		$csapi->setUpConnection("http://your_hostname:port/your_context");

		my $aUser = $csapi->Login("u00001", "u00001", "User", "\\\\your_hostname\\ccmdb\\cm_database");

		my $tmp = $csapi->VerifySignatures($aUser, "1", "myEig");
	};

	if ($@)
	{
		print $@;
	}

=cut
###############################################################################
