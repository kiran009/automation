#!/usr/bin/perl
# Tertio 7.6 CreateReadme script
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
my $database="/data/ccmdb/provident/";
my $dbbmloc="/data/ccmbm/provident/";
my $hostname = hostname;
my $hostplatform;
if($hostname =~ /pesthp2/)
{
	$ENV{'PATH'}="/usr/contrib/bin:$ENV{'PATH'}";
}
if($hostname !~ /pesthp2/)
{
	# On HPUX, CCM client doesn't exist, ignore setting this environment there
	$ENV{'CCM_HOME'}="/opt/ccm71";
	$ENV{'PATH'}="$ENV{'CCM_HOME'}/bin:$ENV{'PATH'}";
	$CCM="$ENV{'CCM_HOME'}/bin/ccm";
}
my $result=GetOptions("coreproject=s"=>\$coreproject,"buildnumber=s"=>\$build_number);
if(!$result)
{
	print "Please provide coreprojectname \n";
	exit;
}
if(!$coreproject)
{
	print "You need to supply core project name \n";
	exit;
}
push(@projectlist,$coreproject);
my @PatchFiles;
my @files;
my $cr;
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
#my $mailto='kiran.daadhi@evolving.com hari.annamalai@evolving.com Srikanth.Bhaskar@evolving.com anand.gubbi@evolving.com shreraam.gurumoorthy@evolving.com';
#my $mailto='kiran.daadhi@evolving.com';
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
# /* Global Environment Variables ******* /
my $f_762a='1409';
my $f_762c='1413';
my $f_763a='1431';
my $f_763b='1436';
my $f_764a='1447';
my $f_764b='1447';
sub main()
{
		start_ccm();
		listfolderTasks();
		ccm_stop();
}
sub listfolderTasks()
{
	@tasks_762a=`$CCM folder -show tasks '$f_762a' -u -f "%task_number"`;
	@tasks_762c=`$CCM folder -show tasks '$f_762c' -u -f "%task_number"`;
	@tasks_763a=`$CCM folder -show tasks '$f_763a' -u -f "%task_number"`;
	@tasks_763b=`$CCM folder -show tasks '$f_763b' -u -f "%task_number"`;
	@tasks_764a=`$CCM folder -show tasks '$f_764a' -u -f "%task_number"`;
	@tasks_764b=`$CCM folder -show tasks '$f_764b' -u -f "%task_number"`;

	print "Tasks in 7.6.2.a are => @tasks_762a \n\n";
	print "Tasks in 7.6.2.c are => @tasks_762c \n\n";
	print "Tasks in 7.6.3.a are => @tasks_763a \n\n";
	print "Tasks in 7.6.3.b are => @tasks_763b \n\n";
	print "Tasks in 7.6.4.a are => @tasks_764a \n\n";
	print "Tasks in 7.6.4.b are => @tasks_764b \n\n";
	foreach $task(@tasks_762a)
	{
		$task=~ s/^\s+|\s+$//g;
		$crinfo=`$CCM task -show cr $task \-u \-f "%problem_number"`;
		print "CR corresponding to task $task is: $crinfo\n";
		push(@crs_762a,$crinfo);
	}
	@uniq762a = do { my %seen; grep { !$seen{$_}++ } @crs_762a};
	foreach $task(@tasks_762c)
	{
		$task=~ s/^\s+|\s+$//g;
		$crinfo=`$CCM task -show cr $task \-u \-f "%problem_number"`;
		print "CR corresponding to task $task is: $crinfo\n";
		push(@crs_762c,$crinfo);
	}
	@uniq762c = do { my %seen; grep { !$seen{$_}++ } @crs_762c};
	foreach $task(@tasks_763a)
	{
		$task=~ s/^\s+|\s+$//g;
		$crinfo=`$CCM task -show cr $task \-u \-f "%problem_number"`;
		print "CR corresponding to task $task is: $crinfo\n";
		push(@crs_763a,$crinfo);
	}
	@uniq763a = do { my %seen; grep { !$seen{$_}++ } @crs_763a};
	foreach $task(@tasks_763b)
	{
		$task=~ s/^\s+|\s+$//g;
		$crinfo=`$CCM task -show cr $task \-u \-f "%problem_number"`;
		print "CR corresponding to task $task is: $crinfo\n";
		push(@crs_763b,$crinfo);
	}
	@uniq763b = do { my %seen; grep { !$seen{$_}++ } @crs_763b};
	foreach $task(@tasks_764a)
	{
		$task=~ s/^\s+|\s+$//g;
		$crinfo=`$CCM task -show cr $task \-u \-f "%problem_number"`;
		print "CR corresponding to task $task is: $crinfo\n";
		push(@crs_764a,$crinfo);
	}
	@uniq764a = do { my %seen; grep { !$seen{$_}++ } @crs_764a};
	foreach $task(@tasks_764b)
	{
		$task=~ s/^\s+|\s+$//g;
		$crinfo=`$CCM task -show cr $task \-u \-f "%problem_number"`;
		print "CR corresponding to task $task is: $crinfo\n";
		push(@crs_764b,$crinfo);
	}
	@uniq764b = do { my %seen; grep { !$seen{$_}++ } @crs_764b};

	print "Uniq CRs in 7.6.2.a are: @uniq762a \nUniq CRs in 7.6.2.c are: @uniq762c \nUniq CRs in 7.6.3.a are: @uniq763a\nUniq CRs in 7.6.3.a are: @uniq763b\n Uniq CRs in 7.6.4.a are: @uniq764a";
	open OP,"<$Bin/mrnumber.txt";
	$mrnumber=<OP>;
	close OP;
	open BN,"+>$Bin/build_number.txt";
	print BN $build_number;
	close BN;
	open  FILE, "+> $Bin/tertio_7.6_README.txt";
	print FILE "Maintenance Release : Tertio $mrnumber build $build_number\n\n";
	print FILE "Created: $dt\n\n";
	print FILE "PRE-REQUISITE : 7.6.0\nSUPERSEDED : 7.6.3\n";
	undef @tasks;
	open SYNOP,"+>$Bin/7.6.4_synopsis.txt";
	open SUMM,"+>$Bin/7.6.4_summary_readme.txt";
	open CRRESOLV, "+>$Bin/7.6.4_crresolv.txt";
	open TASKINF,"+>$Bin/7.6.4_taskinfo.txt";
	open PATCHBIN, "+>$Bin/7.6.4_patchbinarylist.txt";
	open FORMATTASKS,"+>$Bin/7.6.4_formattsks.txt";
	push(@uniq764a,@uniq764b);
	getTasksnReadme(@uniq764a);
	close SUMM;
	close SYNOP;
	close CRRESOLV;
	close TASKINF;
	close PATCHBIN;
	close FORMATTASKS;

	open SYNOP,"+>$Bin/7.6.3_synopsis.txt";
	open SUMM,"+>$Bin/7.6.3_summary_readme.txt";
	open CRRESOLV, "+>$Bin/7.6.3_crresolv.txt";
	open TASKINF,"+>$Bin/7.6.3_taskinfo.txt";
	open PATCHBIN, "+>$Bin/7.6.3_patchbinarylist.txt";
	open FORMATTASKS,"+>$Bin/7.6.3_formattsks.txt";
	push(@uniq763a,@uniq763b);
	getTasksnReadme(@uniq763a);
	close SUMM;
	close SYNOP;
	close CRRESOLV;
	close TASKINF;
	close PATCHBIN;
	close FORMATTASKS;
	open SYNOP,"+>$Bin/7.6.2_synopsis.txt";
	open SUMM,"+>$Bin/7.6.2_summary_readme.txt";
	open CRRESOLV, "+>$Bin/7.6.2_crresolv.txt";
	open TASKINF,"+>$Bin/7.6.2_taskinfo.txt";
	open PATCHBIN, "+>$Bin/7.6.2_patchbinarylist.txt";
	open FORMATTASKS,"+>$Bin/7.6.2_formattsks.txt";
	push(@uniq762a,@uniq762c);
	#getTasksnReadme(@uniq762c);
	#getTasksnReadme(@uniq762a);
	getTasksnReadme(@uniq762a);
	close SUMM;
	close SYNOP;
	close CRRESOLV;
	close TASKINF;
	close PATCHBIN;
	close FORMATTASKS;
	#createReadme('7.6.3a,7.6.2c,7.6.2a');
	createReadme('7.6.4');
	createReadme('7.6.3');
	createReadme('7.6.2');
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
	print FILE "AFFECTS: Tertio 7.6.0\n";
	print FILE "@uniqbinlist\n\n";
	print FILE "SUMMARY OF CHANGES: $deliveryname\nThe following changes have been delivered in this Maintenance Release.\n@summary\n";
}
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
			print TASKINF "$task_number#$task_synopsis#$task_resolver\n";
		}
		$synopsis=~ s/^\s+|\s+$//g;
		$requesttype=~ s/^\s+|\s+$//g;
		$severity=~ s/^\s+|\s+$//g;
		$resolver=~ s/^\s+|\s+$//g;
		$task_synopsis=~ s/^\s+|\s+$//g;
		$task_resolver=~ s/^\s+|\s+$//g;
		$priority=~ s/^\s+|\s+$//g;
		print CRRESOLV "$cr#$synopsis#$requesttype#$severity#$resolver#$priority\n";
		if($synopsis !~ m/^BM/)
    {
		    print SYNOP "CR$cr $synopsis\n";
    }
		#print SYNOP "CR$cr $synopsis\n";
		`$CCM query "cvtype=\'problem\' and problem_number=\'$cr\'"`;
  	#$cr=`$CCM query -u -f %patch_number`;
  	$patch_readme=`$CCM query -u -f %patch_readme`;
  	#$cr=~ s/^\s+|\s+$//g;
  	#$cr =~ s/\s+/_/g;
    if(($patch_readme =~ /N\/A/) || (not defined $patch_readme))
    {
    		print "The following CR: $cr doesn't have a README \n";
    }
    else
    {
	 			if(($cr =~ /4291/) || ($cr =~ /4493/) || ($cr =~ /4500/) || ($cr =~ /4505/) || ($cr =~ /4596/) || ($cr =~ /4606/) || ($cr =~ /4609/) || ($cr =~ /4291/) || ($cr =~ /4493/) || ($cr =~ /4500/) || ($cr =~ /4505/) || ($cr =~ /4388/) || ($cr =~ /4491/) )
    		{
    			open OP1,"+> $Bin/$cr\_README.txt";
    			print OP1 $patch_readme;
    			close OP1;
    			`dos2unix $Bin/$cr\_README.txt 2>&1 1>/dev/null`;
    			@PatchFiles=`sed -n '/AFFECTS:/,/TO/ p' $cr\_README.txt  | sed '\$ d' | sed '/^\$/d' | grep -v 'AFFECTS'`;
    			push(@patchbinarylist,@PatchFiles);
    			$sumreadme=`sed -n '/AFFECTED:/,/ISSUES/ p' $cr\_README.txt  | sed '\$ d' | grep -v 'AFFECTED' | grep -v 'ISSUES' | sed '/^\$/d'`;
    			print SUMM "CR$cr - $sumreadme\n";
    		}
    		else
    		{
     				open OP1,"+> $Bin/$cr\_README.txt";
    				print OP1 $patch_readme;
    				close OP1;
    				`dos2unix $Bin/$cr\_README.txt 2>&1 1>/dev/null`;
    				@PatchFiles=`sed -n '/AFFECTS:/,/TO/ p' $cr\_README.txt  | sed '\$ d' | sed '/^\$/d' | grep -v 'AFFECTS'| sed '/^\$/d'`;
	     		 	push(@patchbinarylist,@PatchFiles);
      			$sumreadme=`sed -n '/CHANGES:/,/ISSUES/ p' $cr\_README.txt  | sed '\$ d' | grep -v 'CHANGES' | grep -v 'ISSUES' | sed '/^\$/d'`;
      			print SUMM "CR$cr - $sumreadme\n";
    			}
    		}
		}
		my @uniqbinlist = do { my %seen; grep { !$seen{$_}++ } @patchbinarylist};
		print PATCHBIN @uniqbinlist;
		$tasklist=join(",",@tasks);
		@formattsks=join("\n", map { 'PROV_' . $_ } @tasks);
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
