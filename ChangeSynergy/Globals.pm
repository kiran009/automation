package ChangeSynergy::Globals;

sub new
{
	# Initialize data as an empty hash
	my $self = {};

	$self->{CSAPI_CV_ATTR_CREATE} = 0;
	$self->{CSAPI_CV_ATTR_MODIFY} = 1;
	$self->{CSAPI_CV_ATTR_DELETE} = 2;

	$self->{BGN_CSAPI_CV_ATTR_DATA}                 = "<csapi_cv_attribute>";
	$self->{END_CSAPI_CV_ATTR_DATA}                 = "</csapi_cv_attribute>";

	$self->{BGN_CSAPI_CV_NAME_DATA}                  =  "<csapi_cv_name>";
	$self->{END_CSAPI_CV_NAME_DATA}                 =  "</csapi_cv_name>";

	$self->{BGN_CSAPI_CV_TYPE_DATA}                 =  "<csapi_cv_type>";
	$self->{END_CSAPI_CV_TYPE_DATA}                 =  "</csapi_cv_type>";

	$self->{BGN_CSAPI_CV_VALUE_DATA}                =  "<csapi_cv_value>";
	$self->{END_CSAPI_CV_VALUE_DATA}                =  "</csapi_cv_value>";

	$self->{BGN_CSAPI_SECTION}						=  "<csapi_section>";
	$self->{END_CSAPI_SECTION}						=  "</csapi_section>";

	$self->{BGN_CSAPI_LISTBOX_VALUE}				=  "<csapi_listbox_value>";
	$self->{END_CSAPI_LISTBOX_VALUE}				=  "</csapi_listbox_value>";

	$self->{BGN_CSAPI_LISTBOX_LABEL}				=  "<csapi_listbox_label>";
	$self->{END_CSAPI_LISTBOX_LABEL}				=  "</csapi_listbox_label>";

	$self->{BGN_CSAPI_QRY_STRING}					=  "<csapi_qry_string>";
	$self->{END_CSAPI_QRY_STRING}					=  "</csapi_qry_string>";

	$self->{BGN_CSAPI_QRY_NAME}						=  "<csapi_qry_name>";
	$self->{END_CSAPI_QRY_NAME}						=  "</csapi_qry_name>";

	$self->{BGN_CSAPI_DATE_LAST_RUN}				=  "<csapi_date_last_run>";
	$self->{END_CSAPI_DATE_LAST_RUN}				=  "</csapi_date_last_run>";

	$self->{BGN_CSAPI_NAME}							=  "<csapi_name>";
	$self->{END_CSAPI_NAME}							=  "</csapi_name>";

	$self->{BGN_CSAPI_SUBREPORTS}					=  "<csapi_subreports>";
	$self->{END_CSAPI_SUBREPORTS}					=  "</csapi_subreports>";

	$self->{BGN_CSAPI_SUBREPORT}					=  "<csapi_subreport>";
	$self->{END_CSAPI_SUBREPORT}					=  "</csapi_subreport>";

	$self->{BGN_CSAPI_SUBREPORT_NAME}				=  "<csapi_subreport_name>";
	$self->{END_CSAPI_SUBREPORT_NAME}				=  "</csapi_subreport_name>";

	$self->{BGN_CSAPI_RELATION_NAME}				=  "<csapi_relation_name>";
	$self->{END_CSAPI_RELATION_NAME}				=  "</csapi_relation_name>";

	$self->{BGN_CSAPI_RELATION_TYPE}				=  "<csapi_relation_type>";
	$self->{END_CSAPI_RELATION_TYPE}				=  "</csapi_relation_type>";

	$self->{BGN_CSAPI_EXPORT_FORM}					=  "<csapi_export_form>";
	$self->{END_CSAPI_EXPORT_FORM}					=  "</csapi_export_form>";

	$self->{BGN_CSAPI_COBJECT_DATA}					=  "<csapi_cobject_data>";
	$self->{END_CSAPI_COBJECT_DATA}					=  "</csapi_cobject_data>";

	$self->{BGN_CSAPI_CVID}							=  "<csapi_cvid>";
	$self->{END_CSAPI_CVID}							=  "</csapi_cvid>";

	$self->{BGN_CSAPI_COBJECT_DATA_SIZE}			=  "<csapi_cobject_data_size>";
	$self->{END_CSAPI_COBJECT_DATA_SIZE}			=  "</csapi_cobject_data_size>";

	$self->{BGN_CSAPI_COBJECT_DATA_NAME}			=  "<csapi_cobject_data_name>";
	$self->{END_CSAPI_COBJECT_DATA_NAME}			=  "</csapi_cobject_data_name>"; 

	$self->{BGN_CSAPI_COBJECT_DATA_LABEL}			=  "<csapi_cobject_data_label>";
	$self->{END_CSAPI_COBJECT_DATA_LABEL}			=  "</csapi_cobject_data_label>";

	$self->{BGN_CSAPI_COBJECT_DATA_VALUE}			=  "<csapi_cobject_data_value>";
	$self->{END_CSAPI_COBJECT_DATA_VALUE}			=  "</csapi_cobject_data_value>";

	$self->{BGN_CSAPI_COBJECT_DATA_TYPE}			=  "<csapi_cobject_data_type>";
	$self->{END_CSAPI_COBJECT_DATA_TYPE}			=  "</csapi_cobject_data_type>";

	$self->{BGN_CSAPI_COBJECT_DATA_DATE}			=  "<csapi_cobject_data_date>";
	$self->{END_CSAPI_COBJECT_DATA_DATE}			=  "</csapi_cobject_data_date>";
	
	$self->{BGN_CSAPI_COBJECT_DATA_USERNAME}     	= "<csapi_cobject_data_username>";
	$self->{END_CSAPI_COBJECT_DATA_USERNAME}     	= "</csapi_cobject_data_username>";

	$self->{BGN_CSAPI_COBJECT_DATA_READONLY}		=  "<csapi_cobject_data_readonly>";
	$self->{END_CSAPI_COBJECT_DATA_READONLY}		=  "</csapi_cobject_data_readonly>";

	$self->{BGN_CSAPI_COBJECT_DATA_REQUIRED}		=  "<csapi_cobject_data_required>";
	$self->{END_CSAPI_COBJECT_DATA_REQUIRED}		=  "</csapi_cobject_data_required>";

	$self->{BGN_CSAPI_COBJECT_DATA_IS_MODIFIED}		=  "<csapi_cobject_data_is_modified>";
	$self->{END_CSAPI_COBJECT_DATA_IS_MODIFIED}		=  "</csapi_cobject_data_is_modified>";

	$self->{BGN_CSAPI_COBJECT_DATA_INHERITED}		=  "<csapi_cobject_data_inherited>";
	$self->{END_CSAPI_COBJECT_DATA_INHERITED}		=  "</csapi_cobject_data_inherited>";

	$self->{BGN_CSAPI_COBJECT_DATA_DEFAULT}			=  "<csapi_cobject_data_default>";
	$self->{END_CSAPI_COBJECT_DATA_DEFAULT}			=  "</csapi_cobject_data_default>";

	$self->{BGN_CSAPI_COBJECT_VECTOR}				=  "<csapi_cobject_vector_";
	$self->{END_CSAPI_COBJECT_VECTOR}				=  "</csapi_cobject_vector_";

	$self->{BGN_CSAPI_SHOW_COBJECT_VECTOR}			=  "<csapi_cobject_vector>";
	$self->{END_CSAPI_SHOW_COBJECT_VECTOR}			=  "</csapi_cobject_vector>";

	$self->{BGN_CSAPI_COBJECT_VECTOR_SIZE}			=  "<csapi_cobject_vector_size>";
	$self->{END_CSAPI_COBJECT_VECTOR_SIZE}			=  "</csapi_cobject_vector_size>";

	$self->{BGN_CSAPI_COBJECT_VECTOR_TYPE}			=  "<csapi_cobject_vector_type>";
	$self->{END_CSAPI_COBJECT_VECTOR_TYPE}			=  "</csapi_cobject_vector_type>";

	$self->{BGN_CSAPI_COBJECT_VECTOR_POSITION}		=  "<csapi_cobject_vector_position>";
	$self->{END_CSAPI_COBJECT_VECTOR_POSITION}		=  "</csapi_cobject_vector_position>";

	$self->{BGN_CSAPI_COBJECT_VECTOR_TRANSITIONS}	= "<csapi_cobject_vector_transitions>";
	$self->{END_CSAPI_COBJECT_VECTOR_TRANSITIONS}	= "</csapi_cobject_vector_transitions>";

	$self->{BGN_CSAPI_COBJECT_VECTOR_ASSOC}			= "<csapi_cobject_vector_assoc>";
	$self->{END_CSAPI_COBJECT_VECTOR_ASSOC}			= "</csapi_cobject_vector_assoc>";

	$self->{BGN_CSAPI_CQUERY_DATA}					= "<csapi_cquery_data>";
	$self->{END_CSAPI_CQUERY_DATA}					= "</csapi_cquery_data>";
	
	#
	# CCM_SUBSCRIPTION XML TAGS
	#
	$self->{BGN_SUBSCRIPTION}						= "<subscription>";
	$self->{END_SUBSCRIPTION}						= "</subscription>";
	
	$self->{BGN_SUBSCRIBER}							= "<subscriber>";
	$self->{END_SUBSCRIBER}							= "</subscriber>";
	
	$self->{BGN_SUB_USERNAME}						= "<username>";
	$self->{END_SUB_USERNAME}						= "</username>";
	
	$self->{BGN_SUB_REALNAME}						= "<realname>";
	$self->{END_SUB_REALNAME}						= "</realname>";
	
	$self->{BGN_SUB_EMAIL}							= "<email>";
	$self->{END_SUB_EMAIL}							= "</email>";
	
	#
	# CCM_E_SIGNATURE XML TAGS
	#
	$self->{BGN_ESIG_E_SIGNATURES}					= "<e_signatures>";
	$self->{END_ESIG_E_SIGNATURES}					= "</e_signatures>";
	
	$self->{BGN_ESIG_E_SIGNATURE}					= "<e_signature>";
	$self->{END_ESIG_E_SIGNATURE}					= "</e_signature>";
	
	$self->{BGN_ESIG_MESSAGE}						= "<message>";
	$self->{END_ESIG_MESSAGE}						= "</message>";
	
	$self->{BGN_ESIG_FULLNAME}						= "<fullname>";
	$self->{END_ESIG_FULLNAME}						= "</fullname>";
	
	$self->{BGN_ESIG_USERNAME}						= "<username>";
	$self->{END_ESIG_USERNAME}						= "</username>";
	
	$self->{BGN_ESIG_DATE}							= "<date>";
	$self->{END_ESIG_DATE}							= "</date>";

	$self->{BGN_ESIG_PURPOSE}						= "<purpose>";
	$self->{END_ESIG_PURPOSE}						= "</purpose>";
	
	$self->{BGN_ESIG_COMMENT}						= "<comment>";
	$self->{END_ESIG_COMMENT}						= "</comment>";
	$self->{BGN_END_ESIG_COMMENT}					= "<comment/>";
	
	$self->{BGN_ESIG_ATTRIBUTE}						= "<attribute>";
	$self->{END_ESIG_ATTRIBUTE}						= "</attribute>";
	
	$self->{BGN_ESIG_CVID}							= "<cvid>";
	$self->{END_ESIG_CVID}							= "</cvid>";
	
	$self->{BGN_ESIG_CREATE_TIME}					= "<create_time>";
	$self->{END_ESIG_CREATE_TIME}					= "</create_time>";
	
	$self->{BGN_ESIG_DIGEST}						= "<digest>";
	$self->{END_ESIG_DIGEST}						= "</digest>";
	
	$self->{BGN_ESIG_DIGEST_ALGORITHM}				= "<digest_algorithm>";
	$self->{END_ESIG_DIGEST_ALGORITHM}				= "</digest_algorithm>";
	
	$self->{BGN_ESIG_VERSION}						= "<version>";
	$self->{END_ESIG_VERSION}						= "</version>";

	#Codes used in the apiQueryData class
	$self->{PROBLEM_TYPE}	= 17;
	$self->{TASK_TYPE}		= 18;
	$self->{OBJECT_TYPE}	= 19;

	#Subreport types used in the apiListObject class
	$self->{PROBLEM_REPORT}	= "PROBLEM_TYPE";
	$self->{TASK_REPORT}	= "TASK_TYPE";
	$self->{OBJECT_REPORT}	= "OBJECT_TYPE";

	#Object codes used in the apiListObject class.
	$self->{VALUELISTBOX_TYPE}	= 0;
	$self->{LISTBOX_TYPE}		= 1;
	$self->{LIST_TYPE}			= 2;
	$self->{DATALISTBOX_TYPE}	= 3;
	$self->{REPORT_TYPE}		= 4;
	$self->{QUERY_TYPE}			= 5;

	#Object codes used in the apiListObject class.
	$self->{QUERY_SECTION}			= 0;
	$self->{REPORT_SECTION}			= 1;
	$self->{LISTBOX_SECTION}		= 2;
	$self->{LIST_SECTION}			= 3;
	$self->{VALUELISTBOX_SECTION}	= 4;
	
	#Object codes used for configuring which config entries to search
	$self->{ALL}        			= 0;
	$self->{USER_PROFILE}			= 1;
	$self->{SHARED_PROFILE} 		= 2;
	$self->{SYSTEM_CONFIG}			= 3;
	
	#Codes used for CCM_SUBSCRIPTION feature
	$self->{UNCHANGED}              = -1;
	$self->{DELETED}				= 0;
	$self->{ADDED}					= 1;
	$self->{MODIFIED}				= 2;

	#The CreateRelation()/DeleteRelation() function calls use these defines
	$self->{CCM_PROBLEM_PROBLEM}	= "problem_problem";
	$self->{CCM_PROBLEM_TASK}		= "problem_task";
	$self->{CCM_PROBLEM_OBJECT}		= "problem_object";
	$self->{CCM_TASK_PROBLEM}		= "task_problem";
	$self->{CCM_TASK_TASK}			= "task_task";
	$self->{CCM_TASK_OBJECT}		= "task_object";
	$self->{CCM_OBJECT_PROBLEM}		= "object_problem";
	$self->{CCM_OBJECT_TASK}		= "object_task";
	$self->{CCM_OBJECT_OBJECT}		= "object_object";
	
	#Globals for user preference editting.
	$self->{DELETE}	          = "DELETE";
	$self->{EDIT}             = "EDIT";
	$self->{ADD}              = "ADD";
	$self->{DUMPPROFILE}      = "DUMPPROFILE";
	$self->{NAMECHANGE}       = "namechange";
	$self->{SUBSTITUTION}     = "substitution";
	$self->{NAMESUBSTITUTION} = "namesubstitution";
	
	#Codes used to determine if an item is for queries, report formats or reports
	$self->{QUERY}			= 0;
	$self->{REPORT}			= 1;
	$self->{REPORT_FORMAT}	= 2;

	bless $self;

	return $self;
}

1;

__END__

=head1 Name

ChangeSynergy::Globals

=head1 Description

The ChangeSynergy::Globals class holds the global parameters used
with the Perl API.

 Codes used in the apiQueryData class
  PROBLEM_TYPE = 17  - This is a change request
  TASK_TYPE    = 18  - This is a task
  OBJECT_TYPE  = 19  - This is an object

 Subreport types used in the apiListObject class
  PROBLEM_REPORT = "PROBLEM_TYPE"  - This is a Change Request Report
  TASK_REPORT    = "TASK_TYPE"     - This is a Task Report
  OBJECT_REPORT  = "OBJECT_TYPE"   - This is an Object Report

 Object codes used in the apiListObject class.
  VALUELISTBOX_TYPE = 0  - This is a Value Listbox
  LISTBOX_TYPE      = 1  - This is a Listbox
  LIST_TYPE         = 2  - This is a List
  DATALISTBOX_TYPE  = 3  - This is a Data Listbox
  REPORT_TYPE       = 4  - This is a Report
  QUERY_TYPE        = 5  - This is a Query

 Object codes used in the apiListObject class.
  QUERY_SECTION        = 0  - This is a Query item
  REPORT_SECTION       = 1  - This is a Report item
  LISTBOX_SECTION      = 2  - This is a Listbox item
  LIST_SECTION         = 3  - This is a List item
  VALUELISTBOX_SECTION = 4  - This is a Valuelistbox item
  
 Object codes used for subscription lists.
  UNCHANGED = -1;
  DELETED	= 0;
  ADDED		= 1;
  MODIFIED	= 2;
  

 The CreateRelation()/DeleteRelation() function calls use these defines
  CCM_PROBLEM_PROBLEM = "problem_problem" - Create a Change Request to Change Request relation
  CCM_PROBLEM_TASK    = "problem_task"    - Create a Change Request to Task relation
  CCM_PROBLEM_OBJECT  = "problem_object"  - Create a Change Request to Object relation
  CCM_TASK_PROBLEM    = "task_problem"    - Create a Task to Change Request relation 
  CCM_TASK_TASK       = "task_task"       - Create a Task to Task relation
  CCM_TASK_OBJECT     = "task_object"     - Create a Task to Object relation
  CCM_OBJECT_PROBLEM  = "object_problem"  - Create a Object to Change Request relation 
  CCM_OBJECT_TASK     = "object_task"     - Create a Object to Task relation
  CCM_OBJECT_OBJECT   = "object_object"   - Create a Object to Object relation
  
 Object codes used to get items from user or shared profile entries. 
 (e.g. reports, queries, lists, listboxes, valuelistboxes, datalistboxes)
  ALL             = 0 - Search in the user profile, then the shared and finally the system.
  USER_PROFILE    = 1 - Search in the users profile only.
  SHARED_PROFILE  = 2 - Search in the shared profile only.
  SYSTEM_CONFIG   = 3 - Search in the system configuration only.

Usage: $globals->{I<variable to get>};

 Ex: $relation = $globals->{CCM_PROBLEM_PROBLEM};
     $relation would then equal "problem_problem".

=head1 Methods

The following methods are available:

=over 4

=cut

##############################################################################

=item B<new>

 sub new()

Initializes a newly created ChangeSynergy::Globals class.  Gain access to all of 
the global parameters used throughout the rest of the api.

 my $globals = new ChangeSynergy::Globals();

=cut

##############################################################################

