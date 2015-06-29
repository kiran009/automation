#!/usr/bin/perl
# Tertio 7.5 Build Script
use Cwd;
use File::Path;
use File::Find;
use File::Basename;
use Switch;
use Getopt::Long;
use File::Copy;

#/************ Setting Environment Variables *******************/
$ENV{'CCM_HOME'}="/opt/ccm71";
$ENV{'PATH'}="$ENV{'CCM_HOME'}/bin:$ENV{'PATH'}";
$CCM="$ENV{'CCM_HOME'}/bin/ccm";
$database="/data/ccmdb/provident/";
$dbbmloc="/data/ccmbm/provident/";
$result=GetOptions("crnumber=s"=>\$crnumber,"devproject=s"=>\$devprojectname);
if(!$result)
{
	print "Please provide crnumber, devprojectname \n";
	exit;
}
if(!$devprojectname)
{
	print "Projectname is mandatory \n";
	exit;
}
my @PatchFiles;
my @files;
my $patch_number;
my $problem_number;
my @CRS;
my @crs;
my @tasks;
my $CRlist;
my $PatchReleaseVersion;
my $projectName;
my $platformlist;
my $hostname;
my @platforms;
my $workarea;
my @op;
# # $mailto='kiran.daadhi@evolving.com hari.annamalai@evolving.com Srikanth.Bhaskar@evolving.com Girish.Desai@evolving.com Pradeep.Kumar@evolving.com';
my $mailto='kiran.daadhi@evolving.com';
my %hash;
my $readmeIssue;

# 1. CR number as an input
# 2. Identify its parent CR
# 3. Fetch the task/tasks out of the CR found in (2)
# 4. Affected binary list ( Ideally should be fetched from README for the CR, but I don’t see README updated for the current or its parent CR)
# 5. Add the tasks to Prep Project( 5-9 should be repeated per platform )
# 6. Reconfigure the Dev Project
# 7. Do make(gmake clean all)
# 8. Modify the README for the patch ?  
   #              >>> What are the changes needed in README
      #           update the superseded and pre-req section of readme . This can be done manually/run a script “updatePatchREADME.ksh” in /data/ccmbm/final_script/imdad_copy (Currently build scripts take care about this)
# 9. Create the patch tar bundles 
# 10. Changes to Platform.mk 
# 11. Move patches to Release Area
# 12. CR transition to Patch_Test
# 13. Send e-mail to the stakeholders about patch's availability

# Job1:

# 1. CR number(fetch tasknumbers about PROV) =>Get the parent CR(fetch TOME tasks from the README)
# 2. fetch the binary list

# Provident_Dev-patch_linAS5_7.6.0
# ccm rp -show all_tasks Provident_Dev-patch_linAS5_7.6.0:project:1
# ccm query "project match 'Provident_Dev-patch_linAS5_7.6.0'" -f "%objectname %release"
# Provident_Dev-patch_sol10_7.6.0
# ccm query "(is_member_of('Provident_Dev-patch_sol10_7.6.0'))" > /tmp/list_objects_solaris.txt
# ccm query "project match 'Provident_Dev-patch_linAS5_7.6.2'"  -f "%objectname %release"
# ccm query "(is_member_of('Provident_Dev-patch_linAS5_7.6.2'))"
# ccm query "(is_member_of('Provident_Dev))"
# ccm create -t project 'Provident_Dev-patch_linAS5_7.6.2' -c 'Project Provident_Dev-patch_linAS5_7.6.2' -release 'Tertio/7.6.2' -task 10839 -purpose 'Patch Generation'
# ccm query "(is_member_of('TMNI_NI~i4.0_int:project:dennt#1')"
# ccm query -type task "is_associated_task_of('4610:problem:probtrac')" 
#  ccm query "is_patch_dev_child_of( problem_number='125')" 
#  ccm query "has_patch_dev_child(cvtype='problem' and problem_number='126')
#  ccm query "is_associated_task_of(cvtype='problem' and problem_number='4601')"  
#  ccm query "is_associated_object_of('10207:task:probtrac')"  

# /* Global Environment Variables ******* /
sub main()
{
	start_ccm();
    fetch_task_info();
	
	#reconfigure_del_project();
	#delivery();
	#send_email();
	#create_childcrs();
	#move_cr_status();
	ccm_stop();
	exit;
}
sub fetch_task_info()
{
	#ccm query "is_associated_task_of(cvtype='problem' and problem_number='4601')" -u -f "%task_number"
	#10777
	$parentcr=`$CCM query "has_patch_dev_child(cvtype='problem' and problem_number='$crnumber')" -u -f %problem_number`;		
    print "Parent CR is: $parentcr \n";
    $parentcr=~ s/^\s+|\s+$//g;	
	@tasknumbers=`$CCM query "is_associated_task_of(cvtype='problem' and problem_number='$parentcr')" -u -f "%task_number"`;
	print "List of tasks in it's parent cr: @tasknumbers \n";
}

sub reconfigure_dev_proj_and_compile()
{	
	$ccmworkarea=`$CCM wa -show -recurse $devprojectname`;
	($temp,$workarea)=split(/'/,$ccmworkarea);
	$workarea=~ s/^\s+|\s+$//g;
	print "***************CCM WorkArea is: $workarea***************\n";
	#`$CCM folder -modify -add_task @tasks 2>&1 1>/dev/null`;
	#`$CCM reconfigure -rs -r -p $devprojectname`;
	$devprojectname=~ s/^\s+|\s+$//g;
	print "Dev project name is :$devprojectname\n";
	`$CCM reconfigure -rs -r -p $devprojectname 2>&1 1>/tmp/reconfigure_devproject_$devprojectname.log`;
	open OP, "< /tmp/reconfigure_devproject_$devprojectname.log";
	@op=<OP>;
	close OP;
	print "Contents of gmake.log for development project is: @op \n";	
	if($devprojectname =~ /Java/)
	{
		chdir "$workarea/Provident_Java";
	}
	else
	{
		print "Perfect \n";
	    chdir "$workarea/Provident_Dev";
	}
	#`/usr/bin/rsh $hostname 'cd $workarea/DSA_FUR_Dev; /usr/bin/gmake clean all'`;
	#`/usr/bin/rsh $hostname 'cd $workarea/DSA_FUR_Dev; /usr/bin/gmake clean all 2>&1 1>/tmp/gmake_$platform.log'`;
	`/usr/bin/gmake clean all 2>&1 1>/tmp/gmake_$devprojectname.log`;
	open OP, "< /tmp/gmake_$devprojectname.log";
	@op=<OP>;
	close OP;
	print "Contents of gmake.log for development project is: @op \n";	
}
sub reconfigure_del_project()
{
	print "*************** Delivery devprojectname is: $delprojectname  ***************\n";
	$ccmworkarea=`$CCM wa -show -recurse $delprojectname`;
	($temp,$workarea)=split(/'/,$ccmworkarea);
	print "***************CCM WorkArea of Delivery Project is: $workarea ***************\n";	
	`$CCM reconfigure -rs -r -p $delprojectname 2>&1 1>/tmp/reconfigure_$delprojectname.log`;
	open OP, "< /tmp/reconfigure_$delprojectname.log";
	@op=<OP>;
	close OP;
	print "Contents of gmake.log for delivery project is: @op \n";
	$delprojectname=~ s/^\s+|\s+$//g;
	if($delprojectname =~ /Java/)
	{
		chdir "$workarea/Provident_Java";
	}
	else
	{
	    chdir "$workarea/Provident_Delivery";
	}
	# Execute gmake clean delivery
	$ENV{'PATH'}="$workarea/Provident_Delivery/:./:$ENV{'PATH'}";
	`/usr/bin/gmake clean deliver 2>&1 1>/tmp/gmake_$delprojectname.log`;
	open OP, "< /tmp/gmake_$delprojectname.log";
	@op=<OP>;
	close OP;
	print "Contents of gmake.log for delivery project is: @op \n";
}

sub delivery()
{
  print "Delivering binaries for the platform";
  if($delprojectname =~ /Java/)
  {
	$delroot="$dbbmloc/$delprojectname/Provident_Delivery";
  }
  else
  {
  	$delroot="$dbbmloc/$delprojectname/Provident_Delivery/build";
  }
  copy("$delroot/tertio.tar","/u/kkdaadhi/Tertio_Deliverable") or die("Couldn't able to copy tertio.tar \n");
  copy("$delroot/Version.txt","/u/kkdaadhi/Tertio_Deliverable") or die("Couldn't able to copy tertio.txt \n");
  copy("$delroot/CoreZSLPackage_1-0-0.Z","/u/kkdaadhi/Tertio_Deliverable") or die("Couldn't able to copy CoreZSLPackage_1-0-0.Z \n");
  copy("$delroot/gpsretrieve","/u/kkdaadhi/Tertio_Deliverable") or die("Couldn't able to copy gpsretrieve \n");
  copy("$delroot/adk.tar","/u/kkdaadhi/Tertio_Deliverable") or die("Couldn't able to copy adk.tar \n");
  copy("$delroot/testbench.tar","/u/kkdaadhi/Tertio_Deliverable") or die("Couldn't able to copy testbench.tar \n");
  $adkdir="/u/kkdaadhi/tertio_adk/";
  mkdir("$adkdir/7.7.0_build11",0755);
  chdir("$adkdir/7.7.0_build11");
 `tar -xf /data/ccmbm/provident/Provident_Delivery-RHEL6_7.7.0/Provident_Delivery/build/adk.tar`;
 `mv tertio-adk-7.7.0/* ../`;
 `rm -rf tertio-adk-7.7.0`;
 send_email("Tertio 7.7 build","/tmp/gmake_$delprojectname.log");
}

sub start_ccm()
{
	print "In Start CCM \n";
	open(ccm_addr,"$ENV{'CCM_HOME'}/bin/ccm start -d $database -m -q -r build_mgr -h ccmuk1 -nogui |");
	$ENV{'CCM_ADDR'}=<ccm_addr>;
	close(ccm_addr);
}

sub ccm_stop()
{
	print "In Stop CCM \n";
	open(ccm_addr,"$ENV{'CCM_HOME'}/bin/ccm stop |");
	close(ccm_addr);
}
sub send_email()
{
	($subject,$attachment)=@_;
	print "\$attachment value is: $attachment \n";
	system("/usr/bin/mutt -s '$subject' $mailto < $attachment");
}
main();