#!/usr/bin/perl
# DSA CreateReadme script
use Cwd;
use File::Path;
use File::Find;
use File::Basename;
use Switch;
use Getopt::Long;
use File::Copy;
use FindBin qw($Bin);
use lib "$Bin/../lib";
use Sys::Hostname;

#/************ Setting Environment Variables *******************/
my $hostname = hostname;
my $hostplatform;
# if($hostname =~ /pesthp2/)
# {
# 	$ENV{'PATH'}="/usr/contrib/bin:$ENV{'PATH'}";
# }
 if($hostname !~ /pesthp2/)
 {
 	# On HPUX, CCM client doesn't exist, ignore setting this environment there
 	$ENV{'CCM_HOME'}="/opt/ccm71";
 	$ENV{'PATH'}="$ENV{'CCM_HOME'}/bin:$ENV{'PATH'}";
 	$CCM="$ENV{'CCM_HOME'}/bin/ccm";
 }
my $result=GetOptions("database=s"=>\$db,"buildnumber=s"=>\$build_number,"folderset=s"=>\$folderset,"readmefile=s"=>\$readmefile,"prereq=s"=>\$prereq,"supersed=s"=>\$supersed);
if(!$result)
{
	print "Please provide coreprojectname \n";
	exit;
}
if(!$db)
{
	print "You need to supply database name \n";
	exit;
}
if(!$folderset)
{
  print "You need to provide the folderset \n";
  exit;
}
if(!$readmefile)
{
  print "You need to provide the readmefile \n";
  exit;
}
if(!$prereq)
{
  print "You need to provide the prereq \n";
  exit;
}
if(!$supersed)
{
  print "You need to provide the supersed \n";
  exit;
}
my $database="/data/ccmdb/$db";
my $dbbmloc="/data/ccmbm/$db";
my @PatchFiles;
my @files;
my $patch_number;
my $problem_number;
my @crs;
my @tasks;
my $tasklist;
my $CRlist;
my $PatchReleaseVersion;
my $projectName;
my $platformlist;
my @op;
my @file_list;
my $mrnumber;
my @location_explode;
my %hash;
my $readmeIssue;
@months = qw( Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec );
my @days = qw(Sun Mon Tue Wed Thu Fri Sat Sun);
my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();
$year+=1900;
my $dt="$mday $months[$mon] $year\n";
my @taskinfo;
my @synopsis;
my @summary;
my @crresolv;
my @formattsks;
my @binarylist;
my $dtformat="$year$months[$mon]$mday$hour$min";
my 	@location;
# my $tertiodest="/u/kkdaadhi/Tertio_Dest";
#my $tertiodest="/data/releases/tertio/7.6.0/patches";
# /* Global Environment Variables ******* /
my @folders=split(/,/,$folderset);
foreach $folder(@folders)
{
  my($name,$number)=split(/:/,$folder);
}
# my $f_411='970';
# my $f_412='960';
sub main()
{
		start_ccm();
		listfolderTasks();
		ccm_stop();
}
sub listfolderTasks()
{
  ($name,$number)=@_;
	@tasks_name=`$CCM folder -show tasks '$number' -u -f "%task_number"`;
	print "Tasks in $name are => @tasks_name \n\n";
	foreach $task(@tasks_name)
	{
		$task=~ s/^\s+|\s+$//g;
		$crinfo=`$CCM task -show cr $task \-u \-f "%problem_number"`;
		print "CR corresponding to task $task is: $crinfo\n";
		push(@crs_name,$crinfo);
	}
	@uniqname = do { my %seen; grep { !$seen{$_}++ } @crs_name};
	# foreach $task(@tasks_412)
	# {
	# 	$task=~ s/^\s+|\s+$//g;
	# 	$crinfo=`$CCM task -show cr $task \-u \-f "%problem_number"`;
	# 	print "CR corresponding to task $task is: $crinfo\n";
	# 	push(@crs_412,$crinfo);
	# }
	# @uniq412 = do { my %seen; grep { !$seen{$_}++ } @crs_412};
	open OP,"<$Bin/mrnumber.txt";
	$mrnumber=<OP>;
	close OP;
	open BN,"+>$Bin/build_number.txt";
	print BN $build_number;
	close BN;
	$readmefile=~ s/^\s+|\s+$//g;
	open  FILE, "+> $Bin/$readmefile";
	print FILE "Maintenance Release : DSA $mrnumber build $build_number\n\n";
	print FILE "Created: $dt\n\n";
	print FILE "PRE-REQUISITE : $prereq\nSUPERSEDED : $supersed\n";
	undef @tasks;
	open SYNOP,"+>$Bin/$name\_synopsis.txt";
	open SUMM,"+>$Bin/$name\_summary_readme.txt";
	open CRRESOLV, "+>$Bin/$name\_crresolv.txt";
	open TASKINF,"+>$Bin/$name\_taskinfo.txt";
	open PATCHBIN, "+>$Bin/$name\_patchbinarylist.txt";
	open FORMATTASKS,"+>$Bin/$name\_formattsks.txt";
	open FOLDER,"+>$Bin/$name\_folder.txt";
	print FOLDER $f_412;
	close FOLDER;
	getTasksnReadme(@uniq412);
	close SUMM;
	close SYNOP;
	close CRRESOLV;
	close TASKINF;
	close PATCHBIN;
	close FORMATTASKS;
	open SYNOP,"+>$Bin/4.1.1_synopsis.txt";
	open SUMM,"+>$Bin/4.1.1_summary_readme.txt";
	open CRRESOLV, "+>$Bin/4.1.1_crresolv.txt";
	open TASKINF,"+>$Bin/4.1.1_taskinfo.txt";
	open PATCHBIN, "+>$Bin/4.1.1_patchbinarylist.txt";
	open FORMATTASKS,"+>$Bin/4.1.1_formattsks.txt";
	open FOLDER,"+>$Bin/4.1.1_folder.txt";
	print FOLDER $f_411;
	close FOLDER;
	#push(@uniq762a,@uniq762c);
	#getTasksnReadme(@uniq762c);
	#getTasksnReadme(@uniq762a);
	getTasksnReadme(@uniq411);
	close SUMM;
	close SYNOP;
	close CRRESOLV;
	close TASKINF;
	close PATCHBIN;
	close FORMATTASKS;
	#createReadme('4.1.2a,4.1.1c,4.1.1a');
	createReadme('4.1.2');
	createReadme('4.1.1');
	print FILE "\nTO INSTALL AND UNINSTALL:\nRefer Patch Release Notes.\n\n";
	print FILE "ISSUES: None";
	close FILE;
}

sub listfolderTasks()
{
	@tasks_411=`$CCM folder -show tasks '$f_411' -u -f "%task_number"`;
	@tasks_412=`$CCM folder -show tasks '$f_412' -u -f "%task_number"`;

	print "Tasks in 4.1.1 are => @tasks_411 \n\n";
	print "Tasks in 4.1.2 are => @tasks_412 \n\n";
	foreach $task(@tasks_411)
	{
		$task=~ s/^\s+|\s+$//g;
		$crinfo=`$CCM task -show cr $task \-u \-f "%problem_number"`;
		print "CR corresponding to task $task is: $crinfo\n";
		push(@crs_411,$crinfo);
	}
	@uniq411 = do { my %seen; grep { !$seen{$_}++ } @crs_411};
	foreach $task(@tasks_412)
	{
		$task=~ s/^\s+|\s+$//g;
		$crinfo=`$CCM task -show cr $task \-u \-f "%problem_number"`;
		print "CR corresponding to task $task is: $crinfo\n";
		push(@crs_412,$crinfo);
	}
	@uniq412 = do { my %seen; grep { !$seen{$_}++ } @crs_412};
	open OP,"<$Bin/mrnumber.txt";
	$mrnumber=<OP>;
	close OP;
	open BN,"+>$Bin/build_number.txt";
	print BN $build_number;
	close BN;
	open  FILE, "+> $Bin/FUR_4.1.0_README.txt";
	print FILE "Maintenance Release : DSA $mrnumber build $build_number\n\n";
	print FILE "Created: $dt\n\n";
	print FILE "PRE-REQUISITE : 4.1.0\nSUPERSEDED : 4.1.1\n";
	undef @tasks;
	open SYNOP,"+>$Bin/4.1.2_synopsis.txt";
	open SUMM,"+>$Bin/4.1.2_summary_readme.txt";
	open CRRESOLV, "+>$Bin/4.1.2_crresolv.txt";
	open TASKINF,"+>$Bin/4.1.2_taskinfo.txt";
	open PATCHBIN, "+>$Bin/4.1.2_patchbinarylist.txt";
	open FORMATTASKS,"+>$Bin/4.1.2_formattsks.txt";
	#push(@uniq763a,@uniq763b);
	open FOLDER,"+>$Bin/4.1.2_folder.txt";
	print FOLDER $f_412;
	close FOLDER;
	getTasksnReadme(@uniq412);
	close SUMM;
	close SYNOP;
	close CRRESOLV;
	close TASKINF;
	close PATCHBIN;
	close FORMATTASKS;
	open SYNOP,"+>$Bin/4.1.1_synopsis.txt";
	open SUMM,"+>$Bin/4.1.1_summary_readme.txt";
	open CRRESOLV, "+>$Bin/4.1.1_crresolv.txt";
	open TASKINF,"+>$Bin/4.1.1_taskinfo.txt";
	open PATCHBIN, "+>$Bin/4.1.1_patchbinarylist.txt";
	open FORMATTASKS,"+>$Bin/4.1.1_formattsks.txt";
	open FOLDER,"+>$Bin/4.1.1_folder.txt";
	print FOLDER $f_411;
	close FOLDER;
	#push(@uniq762a,@uniq762c);
	#getTasksnReadme(@uniq762c);
	#getTasksnReadme(@uniq762a);
	getTasksnReadme(@uniq411);
	close SUMM;
	close SYNOP;
	close CRRESOLV;
	close TASKINF;
	close PATCHBIN;
	close FORMATTASKS;
	#createReadme('4.1.2a,4.1.1c,4.1.1a');
	createReadme('4.1.2');
	createReadme('4.1.1');
	print FILE "\nTO INSTALL AND UNINSTALL:\nRefer Patch Release Notes.\n\n";
	print FILE "ISSUES: None";
	close FILE;
}

sub createReadme()
{
	undef @formattsks;
	undef @fformattsks;
	undef @synopsis;
	undef @summary;
	undef @crresolv;
	undef @taskinfo;
	undef @binarylist;
	undef @uniqbinlist;
	undef @uniqtasks;
	undef @uniqtsks;
	undef @formattedtsks;

  my ($deliveryname)=@_;
	$deliveryname=~ s/^\s+|\s+$//g;
	open OP,"<$Bin/$deliveryname\_formattsks.txt";
	@formattsks=<OP>;
	my @uniqtasks= do { my %seen; grep { !$seen{$_}++ } @formattsks};
	my @uniqtsks=grep(s/\s*$//g,@uniqtasks);
	my @uniqtsks=grep /\S/,@uniqtsks;
	@fformattsks=map{"$_\n"} @uniqtsks;
	$formattedtsks=join(",",@fformattsks);
	$formattedtsks =~ s/[\n\r]//g;
	close OP;
	open OP,"<$Bin/$deliveryname\_synopsis.txt";
	@synopsis=<OP>;
	close OP;
	open OP,"<$Bin/$deliveryname\_summary_readme.txt";
	@summary=<OP>;
	close OP;
	open OP,"<$Bin/$deliveryname\_crresolv.txt";
	@crresolv=<OP>;
	close OP;
	open OP,"<$Bin/$deliveryname\_taskinfo.txt";
	@taskinfo=<OP>;
	close OP;
	open OP, "< $Bin/$deliveryname\_patchbinarylist.txt";
	@binarylist=<OP>;
	close OP;
	print "Patch binary list is: @binarylist\n";
	my @uniqbinlist = do { my %seen; grep { !$seen{$_}++ } @binarylist};
	print "Uniq Binlist is: @uniqbinlist\n";
	print FILE "--";
	print FILE "\nRelease - $deliveryname\n";
	print FILE "\nTASKS:$formattedtsks\n\n";
	print FILE "FIXES:@synopsis\n\n";
	print FILE "AFFECTS: FUR 4.1.0\n";
	print FILE "@uniqbinlist\n\n";
	print FILE "SUMMARY OF CHANGES: $deliveryname\nThe following changes have been delivered in this Maintenance Release.\n@summary\n";
}
# 	print "Uniq Binlist is: @uniqbinlist\n";
# 	print FILE "--";
# 	print FILE "\nRelease - $deliveryname\n";
# 	print FILE "\nTASKS:$formattedtsks\n\n";
# 	print FILE "FIXES:@synopsis\n\n";
# 	print FILE "AFFECTS: Tertio 7.6.0\n";
# 	print FILE "@uniqbinlist\n\n";
# 	print FILE "SUMMARY OF CHANGES: $deliveryname\nThe following changes have been delivered in this Maintenance Release.\n@summary\n";
# }
sub getTasksnReadme()
{
	undef @patchbinarylist;
	undef @PatchFiles;
	undef @tasks;
	undef @formattsks;
	my @crs=@_;
	foreach $cr(@crs)
	{
		$cr=~ s/^\s+|\s+$//g;
		@task_numbers=`$CCM query "is_associated_task_of(cvtype='problem' and problem_number='$cr')" -u -f "%task_number"`;
		push(@tasks,@task_numbers);
		($mr_number)=`$CCM query "cvtype='problem' and problem_number='$cr'" -u -f "%MRnumber"`;
		($synopsis)=`$CCM query "cvtype='problem' and problem_number='$cr'" -u -f "%problem_synopsis"`;
		($requesttype)=`$CCM query "cvtype='problem' and problem_number='$cr'" -u -f "%request_type"`;
		($severity)=`$CCM query "cvtype='problem' and problem_number='$cr'" -u -f "%severity"`;
		($priority)=`$CCM query "cvtype='problem' and problem_number='$cr'" -u -f "%priority"`;
		($resolver)=`$CCM query "cvtype='problem' and problem_number='$cr'" -u -f "%resolver"`;
		foreach $task_number(@task_numbers)
		{
			$task_number=~ s/^\s+|\s+$//g;
			($task_synopsis)=`$CCM task -show info $task_number \-u \-format "%task_synopsis"`;
			($task_resolver)=`$CCM task -show info $task_number \-u \-format "%resolver"`;
			$task_synopsis=~ s/^\s+|\s+$//g;
			$task_resolver=~ s/^\s+|\s+$//g;
			print TASKINF "$task_number\^$task_synopsis\^$task_resolver\n";
		}
		$synopsis=~ s/^\s+|\s+$//g;
		$requesttype=~ s/^\s+|\s+$//g;
		$severity=~ s/^\s+|\s+$//g;
		$resolver=~ s/^\s+|\s+$//g;
		$task_synopsis=~ s/^\s+|\s+$//g;
		$task_resolver=~ s/^\s+|\s+$//g;
		$priority=~ s/^\s+|\s+$//g;
		print CRRESOLV "$cr\^$synopsis\^$requesttype\^$severity\^$resolver\^$priority\n";
		print SYNOP "CR$cr $synopsis\n";
		`$CCM query "cvtype=\'problem\' and problem_number=\'$cr\'"`;
  	$patch_number=`$CCM query -u -f %patch_number`;
  	$patch_readme=`$CCM query -u -f %patch_readme`;
  	$patch_number=~ s/^\s+|\s+$//g;
  	$patch_number =~ s/\s+/_/g;
    if(($patch_readme =~ /N\/A/) || (not defined $patch_readme))
    {
    		print "The following CR: $cr doesn't have a README \n";
    }
    else
    {
	 	open OP1,"+> $Bin/$cr_README.txt";
    		print OP1 $patch_readme;
    		close OP1;
    		`dos2unix $Bin/$cr_README.txt 2>&1 1>/dev/null`;
    		@PatchFiles=`sed -n '/AFFECTS:/,/TO/ p' $cr_README.txt  | sed '\$ d' | sed '/^\$/d' | grep -v 'AFFECTS'| sed '/^\$/d'`;
	     	push(@patchbinarylist,@PatchFiles);
      		$sumreadme=`sed -n '/CHANGES:/,/ISSUES/ p' $cr_README.txt  | sed '\$ d' | grep -v 'CHANGES' | grep -v 'ISSUES' | sed '/^\$/d'`;
      		print SUMM "CR$cr - $sumreadme\n";
    }
		}
		my @uniqbinlist = do { my %seen; grep { !$seen{$_}++ } @patchbinarylist};
		print PATCHBIN @uniqbinlist;
		$tasklist=join(",",@tasks);
		@formattsks=join("\n", map { 'DSA_' . $_ } @tasks);
		print FORMATTASKS @formattsks;
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
main();