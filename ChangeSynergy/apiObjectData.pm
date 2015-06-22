###########################################################
## apiObjectData Class
###########################################################

package ChangeSynergy::apiObjectData;

use strict;
use warnings;
use Carp;
use ChangeSynergy::Globals;
use ChangeSynergy::util;
use ChangeSynergy::apiESignatures;
use ChangeSynergy::apiSubscription;

#apiObjectData(copy) is not supported in PERL API.
sub new
{
	shift; #take off the apiObjectData which is passed in, this is the class name.

	# Initialize data as an empty hash
	my $self = {};

	# Initialize data for this object
	$self->{mName}			= undef;
	$self->{mValue}			= undef;
	$self->{mLabel}			= undef;
	$self->{mType}			= undef;
	$self->{mDate}			= undef;
	$self->{mReadOnly}		= undef;
	$self->{mRequired}		= undef;
	$self->{mInherited}		= undef;
	$self->{mIsModified}	= "false";
	$self->{mDefault}		= undef;
	$self->{mFormattedName} = undef;
	$self->{eSigData}       = undef;
	$self->{subData}        = undef;
	$self->{globals}		= new ChangeSynergy::Globals();

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
		die "Invalid XML Data: apiObjectData: " . $@;
	}

	return $self;
}

sub getXmlData
{
	my $self = shift;
	return $self->{xmlData};
}

sub toXml()
{
	my $self	= shift;
	my $xmlData = "";

	if((defined($self->{mName})) && (defined($self->{mValue})))
	{
		$xmlData .= $self->{globals}->{BGN_CSAPI_COBJECT_DATA};

			$xmlData .= $self->{globals}->{BGN_CSAPI_COBJECT_DATA_NAME};
			$xmlData .= $self->{mName};
			$xmlData .= $self->{globals}->{END_CSAPI_COBJECT_DATA_NAME};

			#Do not use &getValue($self) as it will truncate date attributes.
			$xmlData .= $self->{globals}->{BGN_CSAPI_COBJECT_DATA_VALUE};
			$xmlData .= $self->{mValue};
			$xmlData .= $self->{globals}->{END_CSAPI_COBJECT_DATA_VALUE};

			$xmlData .= $self->{globals}->{BGN_CSAPI_COBJECT_DATA_IS_MODIFIED};
			$xmlData .= &getIsModifiedStr($self);
			$xmlData .= $self->{globals}->{END_CSAPI_COBJECT_DATA_IS_MODIFIED};

		$xmlData .= $self->{globals}->{END_CSAPI_COBJECT_DATA};
	}

	return $xmlData;
}

sub toAttributeXml()
{
	my $self	= shift;
	my $xmlData = "";

	if((defined($self->{mName})) && (defined($self->{mType})) && (defined($self->{mLabel})))
	{
		$xmlData .= $self->{globals}->{BGN_CSAPI_CV_ATTR_DATA};

			$xmlData .= $self->{globals}->{BGN_CSAPI_COBJECT_DATA_NAME};
			$xmlData .= $self->{mName};
			$xmlData .= $self->{globals}->{END_CSAPI_COBJECT_DATA_NAME};

			$xmlData .= $self->{globals}->{BGN_CSAPI_COBJECT_DATA_LABEL};
			$xmlData .= $self->{mLabel};
			$xmlData .= $self->{globals}->{END_CSAPI_COBJECT_DATA_LABEL};

			$xmlData .= $self->{globals}->{BGN_CSAPI_COBJECT_DATA_TYPE};
			$xmlData .= $self->{mType};
			$xmlData .= $self->{globals}->{END_CSAPI_COBJECT_DATA_TYPE};

		$xmlData .= $self->{globals}->{END_CSAPI_CV_ATTR_DATA};
	}

	return $xmlData;
}

sub toObjectXml()
{
	my $self	= shift;
	my $iType   = shift;
	my $xmlData = "";

	if(defined($self->{mName}))
	{
		$xmlData .= $self->{globals}->{BGN_CSAPI_CV_ATTR_DATA};

		if($iType == $self->{globals}->{CSAPI_CV_ATTR_CREATE})
		{
			if((defined($self->{mName})) && (defined($self->{mType})))
			{
				$xmlData .= $self->{globals}->{BGN_CSAPI_CV_NAME_DATA};
				$xmlData .= $self->{mName};
				$xmlData .= $self->{globals}->{END_CSAPI_CV_NAME_DATA};

				$xmlData .= $self->{globals}->{BGN_CSAPI_CV_TYPE_DATA};
				$xmlData .= $self->{mType};
				$xmlData .= $self->{globals}->{END_CSAPI_CV_TYPE_DATA};

				$xmlData .= $self->{globals}->{BGN_CSAPI_CV_VALUE_DATA};
				$xmlData .= $self->{mValue};
				$xmlData .= $self->{globals}->{END_CSAPI_CV_VALUE_DATA};
			}
		}
		elsif($iType ==  $self->{globals}->{CSAPI_CV_ATTR_MODIFY})
		{
			if(defined($self->{mValue}))
			{
				$xmlData .= $self->{globals}->{BGN_CSAPI_CV_NAME_DATA};
				$xmlData .= $self->{mName};
				$xmlData .= $self->{globals}->{END_CSAPI_CV_NAME_DATA};

				$xmlData .= $self->{globals}->{BGN_CSAPI_CV_VALUE_DATA};
				$xmlData .= $self->{mValue};
				$xmlData .= $self->{globals}->{END_CSAPI_CV_VALUE_DATA};
			}
		}
		elsif($iType ==  $self->{globals}->{CSAPI_CV_ATTR_DELETE})
		{
				$xmlData .= $self->{globals}->{BGN_CSAPI_CV_NAME_DATA};
				$xmlData .= $self->{mName};
				$xmlData .= $self->{globals}->{END_CSAPI_CV_NAME_DATA};
		}

		$xmlData .= $self->{globals}->{END_CSAPI_CV_ATTR_DATA};
	}

	return $xmlData;
}

sub getIsModified
{
	my $self = shift;
	return $self->{mIsModified};
}

sub getIsShowModified()
{
	my $self = shift;
	my $tmp  = &getName($self);

	my $compare1 = $tmp cmp "problem_number";
	my $compare2 = $tmp cmp "task_number";
	my $compare3 = $tmp cmp "modify_time";

	if(
		($compare1 == 0)
		||
		($compare2 == 0)
		||
		($compare3 == 0)
	)
	{
		return 1;
	}

	my $compare4 = $self->{mIsModified} cmp "false";

	return $compare4
}

sub getIsSubmitModified()
{
	my $self = shift;
	return ($self->{mIsModified} eq "true");
}

sub getIsModifiedStr()
{
	my $self = shift;
	my $tmp  = &getName($self);

	my $compare1 = $tmp cmp "problem_number";
	my $compare2 = $tmp cmp "task_number";
	my $compare3 = $tmp cmp "modify_time";

	if(
		($compare1 == 0)
		||
		($compare2 == 0)
		||
		($compare3 == 0)
	)
	{
		return "true";
	}

	my $compare4 = $self->{mIsModified} cmp "false";

	return($compare4 ? "true" : "false");
}

sub getName
{
	my $self = shift;
	return $self->{mName};
}

sub getValue
{
	my $self = shift;
	
	if((defined($self->{mType})) && ($self->{mType} eq "CCM_DATE"))
	{
		if(length($self->{mValue}) == 0)
		{
			return $self->{mValue};
		}
		
		return ($self->{mValue} / 1000);
	}
	else
	{
		return $self->{mValue};
	}
}

sub getLabel
{
	my $self = shift;
	return $self->{mLabel};
}

sub getESignatures
{
	my $self = shift;
	return $self->{eSigData};
}

sub getSubscription
{
	my $self = shift;
	return $self->{subData};
}

sub getType
{
	my $self = shift;
	return $self->{mType};
}

sub getFormattedUserName
{
	my $self = shift;
	return $self->{mFormattedName};	
}

sub getDate
{
	my $self = shift;
	return $self->{mDate};
}

sub getReadOnlyStr
{
	my $self = shift;
	return $self->{mReadOnly};
}

sub getRequiredStr
{
	my $self = shift;
	return $self->{mRequired};
}

sub getInheritedStr
{
	my $self = shift;
	return $self->{mInherited};
}

sub getDefault
{
	my $self = shift;
	return $self->{mDefault};
}

sub getReadOnly
{
	my $self = shift;
	return ("\L$self->{mReadOnly}" eq "true");
}

sub getRequired
{
	my $self  = shift;
	return ("\L$self->{mRequired}" eq "true");
}

sub getInherited
{
	my $self = shift;
	return ("\L$self->{mInherited}" eq "true");
}

sub setIsModified
{
	my $self = shift;
	my $val  = shift;

	$self->{mIsModified} = $val;
}

sub setName
{
	my $self = shift;
	my $val  = shift;

	$self->{mName} = $val;
}

sub setValue
{
	my $self = shift;
	my $val  = shift;

	&setIsModified($self, "true");
	
	if((defined($self->{mType})) && ($self->{mType} eq "CCM_DATE"))
	{
		$self->{mValue} = $val * 1000;
	}
	else
	{
		$self->{mValue} = ChangeSynergy::util::xmlEncode($val);
	}
}

sub setLabel
{
	my $self = shift;
	my $val  = shift;

	$self->{mLabel} = $val;
}

#subroutine is marked 'deprecated'
sub setXMLEncodedValue
{
	my $self = shift;
	my $val  = shift;

	$self->setValue($val);
	carp "warning: API 'setXMLEncodedValue' is marked 'deprecated'. Use API 'setValue' instead.";
}	

sub setType
{
	my $self = shift;
	my $val  = shift;

	$self->{mType} = $val;
}


#
#
#<csapi_cquery_data>
#	<csapi_cobject_vector_size>number of objects</csapi_cobject_vector_size>
#	<csapi_cobject_vector_type>type of objects</csapi_cobject_vector_type>
#	<csapi_cobject_vector_position>relational report level</csapi_cobject_vector_position>
#
#	<csapi_cobject_vector>
#		<csapi_cobject_data_size>number of objects</csapi_cobject_data_size>
#		<csapi_cobject_vector_transitions>transition link data</csapi_cobject_vector_transitions>
#
#		<csapi_cobject_vector_assoc>
#			<csapi_cquery_data>
#			.
#			.
#			.
#			</csapi_cquery_data>
#		</csapi_cobject_vector_assoc>
#
#		<csapi_cobject_data>
#			<csapi_cobject_data_name>attribute name</csapi_cobject_data_name>
#
#			<csapi_cobject_data_value>attribute value</csapi_cobject_data_value>
#           or (if csapi_cobject_data_type is CCM_E_SIGNATURE)
#				<csapi_cobject_data_value>
#					<e_signatures>
# 						<e_signature>
#							<message>
#								<fullname>user's first and last name</fullname>
#								<username>operating system login name</username>
#								<date>the date when a signature was created</date>
#								<purpose>a definable enumerated list</purpose>
#								<comment>optional comment</comment>
#								<attribute>the signature attribute</attribute>
#								<cvid>CR's:cvid is required execpt on submit and copy operations</cvid>
#								<create_time>the time that the CR was created</create_time>
#							</message>
#						<digest>the encoded digital signature</digest>
#						<digest_algorithm>optionally specify the digest algorithm: [MD5|MD2|SHA]</digest_algorithm>
#						</e_signature>
#					</e_signatures>
#				<csapi_cobject_data_value>
#			or (if csapi_cobject_data_type is CCM_SUBSCRIPTION)
#				<csapi_cobject_data_value>
#					<subscription>
# 						<subscriber>
#						<username>a user name for a subscribed user</username>
#						<email>e-mail address of the subscribed user</email>
#						<realname>the real name for a subscribed user</realname>
#						</subscriber>
#					</subscription>
#				<csapi_cobject_data_value>
#
#			<csapi_cobject_data_type>web type</csapi_cobject_data_type>
#			<csapi_cobject_data_readonly>true|false</csapi_cobject_data_readonly>
#			<csapi_cobject_data_required>true|false</csapi_cobject_data_required>
#			<csapi_cobject_data_inherited>true|false</csapi_cobject_data_inherited>
#			<csapi_cobject_data_default>default value for this attribute</csapi_cobject_data_default>
#			<csapi_cobject_data_date>formatted date</csapi_cobject_data_date>
#			<csapi_cobject_data_username>formatted username</csapi_cobject_data_username>
#		</csapi_cobject_data>
#		.
#		.
#		.
#
#	</csapi_cobject_vector>
#	.
#	.
#	.
#
#</csapi_cquery_data>
#

sub parseXml
{
	my $self = shift;

	if(!defined($self->{xmlData}))
	{
		die "Cannot parse object data, undef";
	}

	if(length($self->{xmlData}) == 0)
	{
		die "Cannot parse object data, 0 length";
	}

	my $xmlData = $self->{xmlData};

	my $iStart = index($xmlData, $self->{globals}->{BGN_CSAPI_COBJECT_DATA});
	my $iEnd   = index($xmlData, $self->{globals}->{END_CSAPI_COBJECT_DATA});

	if(($iStart < 0) || ($iEnd < 0))
	{
		die "Cannot parse object data.";
	}

	$iStart += length($self->{globals}->{BGN_CSAPI_COBJECT_DATA});

	if(($iStart == $iEnd) || ($iStart > $iEnd))
	{
		die "Cannot parse object data.";
	}

	eval
	{
		&xmlSetName($self);
	};

	if($@)
	{

		die "Cannot parse object data: xmlSetName() \n $@";
	}
	
	eval
	{
		&xmlSetType($self);
	};

	if($@)
	{
		die "Cannot parse object data: xmlSetType() \n $@";
	}

	eval
	{
		&xmlSetLabel($self);
	};

	if($@)
	{
		die "Cannot parse object data: xmlSetLabel() \n $@";
	}

	eval
	{
		&xmlSetValue($self);
	};

	if($@)
	{
		die "Cannot parse object data: xmlSetValue() \n $@";
	}

	eval
	{
		&xmlSetDate($self);
	};

	if($@)
	{
		die "Cannot parse object data: xmlSetDate() \n $@";
	}

	eval
	{
		&xmlSetReadOnly($self);
	};

	if($@)
	{
		die "Cannot parse object data: xmlSetReadOnly() \n $@";
	}

	eval
	{
		&xmlSetRequired($self);
	};

	if($@)
	{
		die "Cannot parse object data: xmlSetRequried() \n $@";
	}

	eval
	{
		&xmlSetInherited($self);
	};

	if($@)
	{
		die "Cannot parse object data: xmlSetInherited() \n $@";
	}

	eval
	{
		&xmlSetDefault($self);
	};

	if($@)
	{
		die "Cannot parse object data: xmlSetDefault() \n $@";
	}
	
	eval
	{
		&xmlSetFormattedName($self);
	};

	if($@)
	{
		die "Cannot parse object data: xmlSetFormattedName() \n $@";
	}
}

sub xmlSetName
{
	my $self = shift;

	if(!defined($self->{xmlData}))
	{
		die "Cannot parse object data";
	}

	my $xmlData = $self->{xmlData};

	my $iStart = index($xmlData, $self->{globals}->{BGN_CSAPI_COBJECT_DATA_NAME});
	my $iEnd   = index($xmlData, $self->{globals}->{END_CSAPI_COBJECT_DATA_NAME});

	if(($iStart < 0) || ($iEnd < 0))
	{
		die "Cannot parse object data";
	}

	$iStart += length($self->{globals}->{BGN_CSAPI_COBJECT_DATA_NAME});

	if($iStart > $iEnd)
	{
		die "Cannot parse object data";
	}

	$self->{mName} = ChangeSynergy::util::xmlDecode(substr($xmlData, $iStart, $iEnd - $iStart));
}

sub xmlSetValue
{
	my $self = shift;

	if(!defined($self->{xmlData}))
	{
		die "Cannot parse object data";
	}

	my $xmlData = $self->{xmlData};

	my $iStart = index($xmlData, $self->{globals}->{BGN_CSAPI_COBJECT_DATA_VALUE});
	my $iEnd   = index($xmlData, $self->{globals}->{END_CSAPI_COBJECT_DATA_VALUE});

	if(($iStart < 0) || ($iEnd < 0))
	{
		die "Cannot parse object data";
	}

	$iStart += length($self->{globals}->{BGN_CSAPI_COBJECT_DATA_VALUE});

	if($iStart > $iEnd)
	{
		die "Cannot parse object data";
	}

	$self->{mValue} = ChangeSynergy::util::xmlDecode(substr($xmlData, $iStart, $iEnd - $iStart));

	if($self->{mType} eq "CCM_E_SIGNATURE")
	{
		eval
		{
			&xmlSetESignatures($self);
		};

		if($@)
		{
			die $@;
		}
	}
	
	if($self->{mType} eq "CCM_SUBSCRIPTION")
	{
		eval
		{
			&xmlSetSubscription($self);
		};

		if($@)
		{
			die $@;
		}
	}
}

sub xmlSetESignatures
{
	my $self = shift;
	
	if(!defined($self->{mValue}))
	{
		die "Cannot parse electronic signature data, undef";
	}
	
	if(defined($self->{eSigData}))
	{
		$self->{eSigData} = undef;
	}

	my $temp = $self->{mValue};
	
	if((!defined($temp)) || (length($temp) == 0))
	{
		return;
	}

	eval
	{
		$self->{eSigData} = new ChangeSynergy::apiESignatures($temp);
	};

	if($@)
	{
		die "Failed to create Esignatures: " . $@;
	}
}

sub xmlSetSubscription
{
	my $self = shift;
	
	if(!defined($self->{mValue}))
	{
		die "Cannot parse subscription data, undef";
	}
	
	if(defined($self->{subData}))
	{
		$self->{subData} = undef;
	}

	my $temp = $self->{mValue};
	
	if(!defined($temp))
	{
		return;
	}
	
	if((length($temp) == 0))
	{
		eval
		{
			$self->{subData} = new ChangeSynergy::apiSubscription();
		};
		
		if($@)
		{
			die "Failed to create Subscription: " . $@;
		}
		
		return;
	}

	eval
	{
		$self->{subData} = new ChangeSynergy::apiSubscription($temp);
	};

	if($@)
	{
		die "Failed to create Subscription: " . $@;
	}
}

sub xmlSetType
{
	my $self = shift;

	if(!defined($self->{xmlData}))
	{
		die "Cannot parse object data";
	}

	my $xmlData = $self->{xmlData};

	my $iStart = index($xmlData, $self->{globals}->{BGN_CSAPI_COBJECT_DATA_TYPE});
	my $iEnd   = index($xmlData, $self->{globals}->{END_CSAPI_COBJECT_DATA_TYPE});

	if(($iStart < 0) || ($iEnd < 0))
	{
		die "Cannot parse object data";
	}

	$iStart += length($self->{globals}->{BGN_CSAPI_COBJECT_DATA_TYPE});

	if($iStart > $iEnd)
	{
		die "Cannot parse object data";
	}

	$self->{mType} = substr($xmlData, $iStart, $iEnd - $iStart);
}

sub xmlSetLabel
{
	my $self = shift;

	if(!defined($self->{xmlData}))
	{
		die "Cannot parse object data";
	}

	my $xmlData = $self->{xmlData};

	my $iStart = index($xmlData, $self->{globals}->{BGN_CSAPI_COBJECT_DATA_LABEL});
	my $iEnd   = index($xmlData, $self->{globals}->{END_CSAPI_COBJECT_DATA_LABEL});

	if(($iStart < 0) || ($iEnd < 0))
	{
		return;
	}

	$iStart += length($self->{globals}->{BGN_CSAPI_COBJECT_DATA_LABEL});

	if($iStart > $iEnd)
	{
		die "Cannot parse object data";
	}

	$self->{mLabel} = ChangeSynergy::util::xmlDecode(substr($xmlData, $iStart, $iEnd - $iStart));
}

sub xmlSetDate
{
	my $self = shift;

	if(!defined($self->{xmlData}))
	{
		die "Cannot parse object data";
	}

	if($self->{mType} ne "CCM_DATE")
	{
		$self->{mDate} = "";
		return;
	}

	my $xmlData = $self->{xmlData};

	my $iStart = index($xmlData, $self->{globals}->{BGN_CSAPI_COBJECT_DATA_DATE});
	my $iEnd   = index($xmlData, $self->{globals}->{END_CSAPI_COBJECT_DATA_DATE});

	if(($iStart < 0) || ($iEnd < 0))
	{
		die "Cannot parse object data";
	}

	$iStart += length($self->{globals}->{BGN_CSAPI_COBJECT_DATA_DATE});

	if($iStart > $iEnd)
	{
		die "Cannot parse object data";
	}

	$self->{mDate} = substr($xmlData, $iStart, $iEnd - $iStart);
}

sub xmlSetReadOnly
{
	my $self = shift;

	if(!defined($self->{xmlData}))
	{
		die "Cannot parse object data";
	}

	my $xmlData = $self->{xmlData};

	my $iStart = index($xmlData, $self->{globals}->{BGN_CSAPI_COBJECT_DATA_READONLY});
	my $iEnd   = index($xmlData, $self->{globals}->{END_CSAPI_COBJECT_DATA_READONLY});

	if(($iStart < 0) || ($iEnd < 0))
	{
		die "Cannot parse object data";
	}

	$iStart += length($self->{globals}->{BGN_CSAPI_COBJECT_DATA_READONLY});

	if($iStart > $iEnd)
	{
		die "Cannot parse object data";
	}

	$self->{mReadOnly} = substr($xmlData, $iStart, $iEnd - $iStart);
}

sub xmlSetRequired
{
	my $self = shift;

	if(!defined($self->{xmlData}))
	{
		die "Cannot parse object data";
	}

	my $xmlData = $self->{xmlData};

	my $iStart = index($xmlData, $self->{globals}->{BGN_CSAPI_COBJECT_DATA_REQUIRED});
	my $iEnd   = index($xmlData, $self->{globals}->{END_CSAPI_COBJECT_DATA_REQUIRED});

	if(($iStart < 0) || ($iEnd < 0))
	{
		die "Cannot parse object data";
	}

	$iStart += length($self->{globals}->{BGN_CSAPI_COBJECT_DATA_REQUIRED});

	if($iStart > $iEnd)
	{
		die "Cannot parse object data";
	}

	$self->{mRequired} = substr($xmlData, $iStart, $iEnd - $iStart);
}

sub xmlSetInherited
{
	my $self = shift;

	if(!defined($self->{xmlData}))
	{
		die "Cannot parse object data";
	}

	my $xmlData = $self->{xmlData};

	my $iStart = index($xmlData, $self->{globals}->{BGN_CSAPI_COBJECT_DATA_INHERITED});
	my $iEnd   = index($xmlData, $self->{globals}->{END_CSAPI_COBJECT_DATA_INHERITED});

	if(($iStart < 0) || ($iEnd < 0))
	{
		die "Cannot parse object data";
	}

	$iStart += length($self->{globals}->{BGN_CSAPI_COBJECT_DATA_INHERITED});

	if($iStart > $iEnd)
	{
		die "Cannot parse object data";
	}

	$self->{mInherited} = substr($xmlData, $iStart, $iEnd - $iStart);
	
	#If the value is inherited then set it to modified so it will get submitted.
	if (&getInherited($self))
	{
		&setIsModified($self, "true");
	}
}

sub xmlSetDefault
{
	my $self = shift;

	if(!defined($self->{xmlData}))
	{
		die "Cannot parse object data";
	}

	my $xmlData = $self->{xmlData};

	my $iStart = index($xmlData, $self->{globals}->{BGN_CSAPI_COBJECT_DATA_DEFAULT});
	my $iEnd   = index($xmlData, $self->{globals}->{END_CSAPI_COBJECT_DATA_DEFAULT});

	if(($iStart < 0) || ($iEnd < 0))
	{
		die "Cannot parse object data";
	}

	$iStart += length($self->{globals}->{BGN_CSAPI_COBJECT_DATA_DEFAULT});

	if($iStart > $iEnd)
	{
		die "Cannot parse object data";
	}

	$self->{mDefault} = ChangeSynergy::util::xmlDecode(substr($xmlData, $iStart, $iEnd - $iStart));
}

sub xmlSetFormattedName
{
	my $self = shift;

	if(!defined($self->{xmlData}))
	{
		die "Cannot parse object data";
	}

	if($self->{mType} ne "CCM_USER")
	{
		$self->{mFormattedName} = "";
		return;
	}

	my $xmlData = $self->{xmlData};

	my $iStart = index($xmlData, $self->{globals}->{BGN_CSAPI_COBJECT_DATA_USERNAME});
	my $iEnd   = index($xmlData, $self->{globals}->{END_CSAPI_COBJECT_DATA_USERNAME});

	if(($iStart < 0) || ($iEnd < 0))
	{
		die "Cannot parse object data";
	}

	$iStart += length($self->{globals}->{BGN_CSAPI_COBJECT_DATA_USERNAME});

	if($iStart > $iEnd)
	{
		die "Cannot parse object data";
	}

	$self->{mFormattedName} = ChangeSynergy::util::xmlDecode(substr($xmlData, $iStart, $iEnd - $iStart));
}


1;

__END__

=head1 Name

ChangeSynergy::apiObjectData

=head1 Description

The ChangeSynergy::apiObjectData object is used to represent the details of
one attribute for any given object. The XML format used to construct
a instance of this class is as follows:

 <csapi_cobject_data>
	<csapi_cobject_data_name>attribute name</csapi_cobject_data_name>
	<csapi_cobject_data_value>attribute value</csapi_cobject_data_value>
	<csapi_cobject_data_type>web type</csapi_cobject_data_type>
	<csapi_cobject_data_readonly>true|false</csapi_cobject_data_readonly>
	<csapi_cobject_data_required>true|false</csapi_cobject_data_required>
	<csapi_cobject_data_inherited>true|false</csapi_cobject_data_inherited>
	<csapi_cobject_data_default>default value for this attribute</csapi_cobject_data_default>
	<csapi_cobject_data_date>formatted date</csapi_cobject_data_date>
 </csapi_cobject_data>

This object is used generically in both reporting and data show api operations.
Some data elements will not have values depending on the usage. Data elements
will always be undef if not set.

=head1 Methods

The following methods are available:

=over 4

=cut

##############################################################################

=item B<new>

 sub new(xmlData)

Initializes a newly created ChangeSynergy::apiObjectData class so that it 
represents the xml data passed in.

 my $apiObject = new ChangeSynergy::objectData($xmlData);
 
 Parameters:
	xmlData  - the XML data that needs to be parsed into a usable form.

 Throws:
	die - if unable to parse the xml data

=cut

##############################################################################

=item B<getDate>

Gets the attribute date value property. Returns the time in the human readable
Show date format by default MM/dd/yyyy H:mm:ss.

my $date = $apiObject->getDate();

print $date . "\n"; #ex. 02/08/2006 13:27:49

 Returns: scalar
	the attribute date property.

=cut

##############################################################################

=item B<getDefault>

Gets the default value for this attribute.

my $default = $apiObject->getDefault()

 Returns: scalar
	the default value for this attribute. The value is set in the Lifecycle editor.

=cut

##############################################################################

=item B<getESignatures>

Get the Electronic Signatures associated with this object.  Will be undefined if
none are set. The return result is an instance of the L<apiESignatures> class.

my $eSigs = $apiObject->getESignatures()

 Returns: apiESignatures
	the Electronic Signatures for this object.

=cut

##############################################################################

=item B<getFormattedUserName>

Gets the formatted user name property.  This will return the users display
name or if not a CCM_USER attribute an empty string.  This value will be the 
same as the getValue method unless the Username Display feature has been
set to something besides just user id.

my $date = $apiObject->getFormattedUserName();

 Returns: scalar
	the formatted display user name.

=cut

##############################################################################

=item B<getInherited>

Gets the attribute is inherited property, 0 is false, 1 is true.

my $inherited = $apiObject->getInherited()

 Returns: scalar
	the attribute is inherited property.

=cut

##############################################################################

=item B<getInheritedStr>

Gets the attribute is inherited property as a string, true or false.

my $inheritedStr = $apiObject->getInheritedStr()

 Returns: scalar
	the attribute inherited property as a string

=cut

##############################################################################

=item B<getIsModified>

Gets the attribute is modified property, 0 is false, 1 is true.

my $isModified = $apiObject->getIsModified()

 Returns: scalar
	if the attribute has been modified or not.

=cut

##############################################################################

=item B<getIsModifiedStr>

Gets the attribute is modified property as a string, true or false.

my $isModifiedStr = $apiObject->getIsModifiedStr()

 Returns: scalar
	if the attribute has been modified or not property as a string.

=cut

##############################################################################

=item B<getIsShowModified>

Gets the attribute is modified property, 0 is false, 1 is true.

my $isShowModified = $apiObject->getIsShowModified()

 Returns: scalar
	if the attribute has been modified or not.

=cut

##############################################################################

=item B<getIsSubmitModified>

Gets the attribute is modified property, 0 is false, 1 is true.

my $isSubmitModified = $apiObject->getIsSubmitModified()

 Returns: scalar
	if the attribute has been modified or not.

=cut

##############################################################################

=item B<getLabel>

Gets the attribute label property

my $value = $apiObject->getLabel()

 Returns: scalar
	the attribute label property.

=cut

##############################################################################

=item B<getName>

Gets the attribute name property.

my $name = $apiObject->getName()

 Returns: scalar
	the attribute name property.

=cut

##############################################################################

=item B<getReadOnly>

Gets attribute read only property, 0 is false, 1 is true.

my $readOnly = $apiObject->getReadOnly()

 Returns: scalar
	the attribute read only property.

=cut

##############################################################################

=item B<getReadOnlyStr>

Gets the attribute read only property as a string, true or false.

my $readOnlyStr = $apiObject->getReadOnlyStr()

 Returns: scalar
	the attribute read only property as a string

=cut

##############################################################################

=item B<getRequired>

Gets attribute required property, 0 is false, 1 is true 

my $required = $apiObject->getRequired()

 Returns: scalar
	the attribute required property.

=cut

##############################################################################

=item B<getRequiredStr>

Gets the attribute required property as a string, true or false

my $requiredStr = $apiObject->getRequiredStr()

 Returns: scalar
	the attribute required property as a string

=cut

##############################################################################

=item B<getSubscription>

Get the subscription information associated with this object.  Will be empty object if
none are set. The return result is an instance of the L<apiSubscription> class.

my $subscription = $apiObject->getSubscription()

 Returns: apiSubscription
	the subscription information for this object.

 Example:
 
	use ChangeSynergy::csapi;

	my $csapi = new ChangeSynergy::csapi();

	eval
	{	
		$csapi->setUpConnection("http", "your_hostname", 8600);

		my $aUser     = $csapi->Login("u00001", "u00001", "Admin", "\\\\your_hostname\\ccmdb\\cm_database");

		#Show problem 22
		my $problem   = $csapi->AttributeModifyCRData ($aUser, "22"); 
		
		#Get the CCM_SUBSCRIPTION attribute called subscription1.
		my $attribute = $problem->getDataObjectByName("subscription1");

		#Get the actual subscription data.  The real value is XML.
		my $subscription = $attribute->getSubscription();
		
		eval
		{
			#Modify the user jsmith to change his real name.
			my $subscriber = $subscription->getSubscriberByUserName("jsmith");
			$subscriber->setRealName("John Smith");
		};
		
		if($@)
		{
			#Print the error message if there is one.
			print $@;
		}
		
		#Add a new user.
		$subscription->addSubscriber("cscott", "Chris Scott", "chris.scott\@company.com");
		
		#set the new XML value for subscription1.
		$problem->getDataObjectByName("subscription1")->setValue($subscription->toSubmitXml());
		
		#Modify the CR with the changes to the subscription list.
		my $ret_val = $csapi->ModifyCR($aUser, $problem);

		#Print the response from calling ModifyCR.
		print "\n" . $ret_val->getResponseData();	
	};
	
	if($@)
	{
		die "Failed to modify subscription list: " . $@;
	}

=cut

##############################################################################


=item B<getType>

Get the attribute web type property.

my $type = $apiObject->getType()

 Returns: scalar
	the attribute web type property.
	
	Can be one of the following:
      CCM_STRING
	  CCM_TEXT
	  CCM_DATE
	  CCM_USER
	  CCM_NUMBER
	  CCM_READONLY
	  CCM_LISTBOX
	  CCM_VALUELISTBOX
	  CCM_TOGGLE
	  CCM_RELATION
	  CCM_HIDDEN
	  CCM_E_SIGNATURE
	  CCM_SUBSCRIPTION

=cut

##############################################################################

=item B<getValue>

Gets the attribute value property. If the attribute is a CCM_DATE the returned value
is the time in seconds since 1970 or an empty string if the attribute does not have
a date currently defined.

my $value = $apiObject->getValue();

print $value . "\n"; #ex. 1139434069 for a CCM_DATE

 Returns: scalar
	the attribute value property.

=cut

##############################################################################

=item B<getXmlData>

Gets the XML data used to constuct this object. 

Note: This is intended for debugging only.

my $xmlData = $apiObject->getXmlData()

 Returns: scalar
	the XML data used to constuct this object, useful for debugging purposes. 

=cut

##############################################################################

=item B<setIsModified>

Sets the "isModified" property for the class instance.

$apiObject->setIsModified($value)

 Parameters:
	value - the new value for isModified (true or false)

=cut

##############################################################################

=item B<setLabel>

Sets the "label" property for the class instance.

$apiObject->setLabel($value)

 Parameters:
	value - the new value for label

=cut

##############################################################################

=item B<setName>

Sets the "name" property for the class instance.

$apiObject->setName($value)

 Parameters:
	value - the new value for name

=cut

##############################################################################

=item B<setType>

Sets the "type" property for the class instance.

$apiObject->setType($value)

 Parameters:
	value - the new value for type

=cut

##############################################################################

=item B<setValue>

Sets the "value" property for the class instance.

$apiObject->setValue($value)

Also must be used when setting date values to be submitted to the server.
The date values must be set in seconds since 1970.  PERL dates are
in seconds since 1970.

Apart from setting the value, api encodes the value if needed. 

Example for setting the current time:

  #Get the current time.
  my $time = time;
  $apiObject->setValue($time);

Example for setting a time in the future or past:

  use Time::Local;

  # 5/10/2004 (mm/dd/yyyy)
  #timelocal($seconds, $minutes, $hours, $day of month, $month, $year);
  $seconds = timelocal(0, 0, 0, 10, 5, 2004);
  
  $apiObject->setValue($seconds);
  
Converting the above time back to a human readable format:  
  
  #Must add 1900 to the year to get the correct year.
  ($seconds, $minutes, $hours, $day_of_month, $month, $year, $wday, $yday, $isdst) = localtime($seconds);

  print "Reconverted Date: " . $month  . "/" . $day_of_month  . "/" . ($year + 1900);
  #Should print 5/10/2004

 Parameters:
	value - the new value for value

=cut

##############################################################################

=item B<setXMLEncodedValue>

Deprecated. Use setValue instead.
 
Sets the "value" property for the class instance.
XML encodes the value for the user, so that it does
not need to be externally done.

$apiObject->setXMLEncodedValue($value)

 Parameters:
	value - the new value for value

=cut

##############################################################################

=item B<toAttributeXml>

Get XML data used to send to the IBM Rational Change server.

Used by api functions to construct the XML strings that will be submitted to the
IBM Rational Change server.

my $xmlData = $apiObject->toAttributeXml()

 Returns: scalar
	the XML data to be submitted to the IBM Rational Change server.  This function
	will take all the current information in the object and translate it into XML.

=cut

##############################################################################

=item B<toObjectXml>

Get XML data used to send to the IBM Rational Change server.

Used by api functions to construct the XML strings that will be submitted to the
IBM Rational Change server.

my $xmlData = $apiObject->toObjectXml()

 Returns: scalar
	the XML data to be submitted to the IBM Rational Change server.  This function
	will take all the current information in the object and translate it into XML.

=cut


##############################################################################

=item B<toXml>

Get XML data used to send to the IBM Rational Change server.

Used by api functions to construct the XML strings that will be submitted to the
IBM Rational Change server.

my $xmlData = $apiObject->toXml()

 Returns: scalar
	the XML data to be submitted to the IBM Rational Change server.  This function
	will take all the current information in the object and translate it into XML.

=cut

