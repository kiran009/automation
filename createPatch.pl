#!/usr/bin/perl
# Tertio 7.X createTarfile script
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
if($hostname =~ /pesthp2/)
{
	$ENV{'PATH'}="/usr/contrib/bin:$ENV{'PATH'}";
}
my $result=GetOptions("coreproject=s"=>\$coreproject,"tertiodest=s"=>\$tertiodest);
if(!$result)
{
	print "You must supply arguments to the script\n";
	exit;
}
if(!$coreproject)
{
	print "You need to supply core project name \n";
	exit;
}
if(!$tertiodest)
{
	print "You need to supply tertio destination name \n";
	exit;
}
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
my $destdir;
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
#my $tertiodest="/u/kkdaadhi/Tertio_Dest";
#my $tertiodest="/data/releases/tertio/7.6.0/patches";
# /* Global Environment Variables ******* /
sub main()
{
		createTar();
}
sub createTar()
{
	umask 002;
	open OP,"<$Bin/patchnumber.txt";
	$patchnumber=<OP>;
	close OP;
	open LOCATION,">>$Bin/location.txt";
	$coreproject=~ s/^\s+|\s+$//g;
	$patchnumber=~ s/^\s+|\s+$//g;
	open BN,"<$Bin/build_number.txt";
	$build_number=<BN>;
	close BN;
  if($coreproject =~ /linAS5/)
  {
		$destdir="/u/kkdaadhi/Tertio_Deliverable/linAS5";
  	    chdir($destdir);
  	    copy("$Bin/$patchnumber\_README.txt",$destdir);
  	    $hostos="rhel5";
  	    $hostplatform="linAS5";
  	    my @files = <*.tar>;
        if (@files)
        {
           unlink @files or warn "Problem unlinking @files: $!";
        }
        else
        {
          warn "No files to unlink!\n";
        }
  	    `find * -type f -name "*README.txt" | xargs tar cvf tertio-$mrnumber-$hostos-build$build_number\.tar; find * -type f  \\( ! -name "*README.txt" ! -name "*.tar" \\) | xargs tar uvf tertio-$mrnumber-$hostos-build$build_number\.tar;`;
  	    print "tertio-$mrnumber-$hostos-build$build_number\.tar => $tertiodest/$hostplatform/NotTested/tertio-$mrnumber-$hostos-build$build_number\_$dtformat\.tar";
  	    copy("tertio-$mrnumber-$hostos-build$build_number\.tar","$tertiodest/$hostplatform/NotTested/tertio-$mrnumber-$hostos-build$build_number\_$dtformat\.tar") or die("Couldn't copy to destination $!");
  	    push(@location,"$tertiodest/$hostplatform/NotTested/tertio-$mrnumber-$hostos-build$build_number\_$dtformat\.tar");
  	    print LOCATION "$tertiodest/$hostplatform/NotTested/tertio-$mrnumber-$hostos-build$build_number\_$dtformat\.tar \n";
    }
	elsif($coreproject =~ /hpiav3/)
	{
		$destdir="/u/kkdaadhi/Tertio_Deliverable/hpiav3";
  	    chdir($destdir);
  	    copy("$Bin/$patchnumber\_README.txt",$destdir);
  	    $hostplatform="hpiav3";
  	    my @files = <*.tar>;
        if (@files)
        {
               unlink @files or warn "Problem unlinking @files: $!";
        }
        else
        {
              warn "No files to unlink!\n";
        }
      	`find * -type f -name "*README.txt" | xargs tar cvf tertio-$mrnumber-$hostplatform-build$build_number\.tar; find * -type f  \\( ! -name "*README.txt" ! -name "*.tar" \\) | xargs tar uvf tertio-$mrnumber-$hostplatform-build$build_number\.tar;`;
  	    print "tertio-$mrnumber-$hostplatform-build$build_number\.tar => $tertiodest/$hostplatform/NotTested/tertio-$mrnumber-$hostplatform-build$build_number\_$dtformat\.tar";
  	    copy("tertio-$mrnumber-$hostplatform-build$build_number\.tar","$tertiodest/$hostplatform/NotTested/tertio-$mrnumber-$hostplatform-build$build_number\_$dtformat\.tar") or die("Couldn't copy to destination $!");
  	    push(@location,"$tertiodest/$hostplatform/NotTested/tertio-$mrnumber-$hostplatform-build$build_number\_$dtformat\.tar");
  	    print LOCATION "$tertiodest/$hostplatform/NotTested/tertio-$mrnumber-$hostplatform-build$build_number\_$dtformat\.tar  \n";
	}
  elsif($coreproject =~ /linAS4/)
  {
		$destdir="/u/kkdaadhi/Tertio_Deliverable/linAS4";
  	    chdir($destdir);
  	    copy("$Bin/$patchnumber\_README.txt",$destdir);
  	    $hostos="rhel3";
  	    $hostplatform="linAS4";
  	    my @files = <*.tar>;
        if (@files)
        {
           unlink @files or warn "Problem unlinking @files: $!";
        }
        else
        {
              warn "No files to unlink!\n";
        }
  	    `find * -type f -name "*README.txt" | xargs tar cvf tertio-patch$patchnumber\.tar; find * -type f  \\( ! -name "*README.txt" ! -name "*.tar" \\) | xargs tar uvf tertio-patch$patchnumber\.tar;`;
  	    print "tertio-patch$patchnumber\.tar => $tertiodest/$hostplatform/NotTested/tertio-patch$patchnumber\.tar";
  	    copy("tertio-patch$patchnumber\.tar","$tertiodest/$hostplatform/NotTested/tertio-patch$patchnumber\.tar") or die("Couldn't copy to destination $!");
  	    push(@location,"$tertiodest/$hostplatform/NotTested/tertio-patch$patchnumber\.tar");
  	    print LOCATION "$tertiodest/$hostplatform/NotTested/tertio-patch$patchnumber\.tar \n";
	}
  elsif($coreproject =~ /linAS3/)
  {
		$destdir="/u/kkdaadhi/Tertio_Deliverable/linAS3";
  	    chdir($destdir);
  	    copy("$Bin/$patchnumber\_README.txt",$destdir);
  	    $hostos="rhel3";
  	    $hostplatform="linAS3";
  	    my @files = <*.tar>;
        if (@files)
        {
               unlink @files or warn "Problem unlinking @files: $!";
        }
        else
        {
              warn "No files to unlink!\n";
        }
  	    `find * -type f -name "*README.txt" | xargs tar cvf tertio-patch$patchnumber\.tar; find * -type f  \\( ! -name "*README.txt" ! -name "*.tar" \\) | xargs tar uvf tertio-patch$patchnumber\.tar;`;
  	    print "tertio-patch$patchnumber\.tar => $tertiodest/$hostplatform/NotTested/tertio-patch$patchnumber\.tar";
  	    copy("tertio-patch$patchnumber\.tar","$tertiodest/$hostplatform/NotTested/tertio-patch$patchnumber\.tar") or die("Couldn't copy to destination $!");
  	    push(@location,"$tertiodest/$hostplatform/NotTested/tertio-patch$patchnumber\.tar");
  	    print LOCATION "$tertiodest/$hostplatform/NotTested/tertio-patch$patchnumber\.tar \n";
	}
  elsif($coreproject =~ /sol9/)
  {
		$destdir="/u/kkdaadhi/Tertio_Deliverable/sol9";
  	    chdir($destdir);
  	    copy("$Bin/$patchnumber\_README.txt",$destdir);
  	    $hostplatform="sol9";
  	    my @files = <*.tar>;
        if (@files)
        {
               unlink @files or warn "Problem unlinking @files: $!";
        }
        else
        {
              warn "No files to unlink!\n";
        }
  	    `find * -type f -name "*README.txt" | xargs tar cvf tertio-patch$patchnumber\.tar;find * -type f  \\( ! -name "*README.txt" ! -name "*.tar" \\) | xargs tar uvf tertio-patch$patchnumber\.tar;`;
  	    print "tertio-patch$patchnumber\.tar => $tertiodest/$hostplatform/NotTested/tertio-patch$patchnumber\.tar";
  	    copy("tertio-patch$patchnumber\.tar","$tertiodest/$hostplatform/NotTested/tertio-patch$patchnumber\.tar") or die("Couldn't copy to destination $!");
  	    push(@location,"$tertiodest/$hostplatform/NotTested/tertio-patch$patchnumber\.tar");
  	    print LOCATION "$tertiodest/$hostplatform/NotTested/tertio-patch$patchnumber\.tar \n";
	}
  elsif($coreproject =~ /hpia/)
  {
		$destdir="/u/kkdaadhi/Tertio_Deliverable/hpia";
  	    chdir($destdir);
  	    copy("$Bin/$patchnumber\_README.txt",$destdir);
  	    $hostplatform="hpia";
  	    my @files = <*.tar>;
        if (@files)
        {
               unlink @files or warn "Problem unlinking @files: $!";
        }
        else
        {
              warn "No files to unlink!\n";
        }
  	    `find * -type f -name "*README.txt" | xargs tar cvf tertio-patch$patchnumber\.tar;find * -type f  \\( ! -name "*README.txt" ! -name "*.tar" \\) | xargs tar uvf tertio-patch$patchnumber\.tar;`;
  	    print "tertio-patch$patchnumber\.tar => $tertiodest/$hostplatform/NotTested/tertio-patch$patchnumber\.tar";
  	    copy("tertio-patch$patchnumber\.tar","$tertiodest/$hostplatform/NotTested/tertio-patch$patchnumber\.tar") or die("Couldn't copy to destination $!");
  	    push(@location,"$tertiodest/$hostplatform/NotTested/tertio-patch$patchnumber\.tar");
  	    print LOCATION "$tertiodest/$hostplatform/NotTested/tertio-patch$patchnumber\.tar \n";
	}
	elsif($coreproject =~ /sol10/)
	{
		$destdir="/u/kkdaadhi/Tertio_Deliverable/sol10";
  	    chdir($destdir);
  	    copy("$Bin/$patchnumber\_README.txt",$destdir);
  	    $hostplatform="sol10";
  	    my @files = <*.tar>;
        if (@files)
        {
               unlink @files or warn "Problem unlinking @files: $!";
        }
        else
       {
              warn "No files to unlink!\n";
        }
  	    `find * -type f -name "*README.txt" | xargs tar cvf tertio-$mrnumber-$hostplatform-build$build_number\.tar; find * -type f  \\( ! -name "*README.txt" ! -name "*.tar" \\) | xargs tar uvf tertio-$mrnumber-$hostplatform-build$build_number\.tar;`;
  	    print "tertio-$mrnumber-$hostplatform-build$build_number\.tar => $tertiodest/$hostplatform/NotTested/tertio-$mrnumber-$hostplatform-build$build_number\_$dtformat\.tar";
  	    copy("tertio-$mrnumber-$hostplatform-build$build_number\.tar","$tertiodest/$hostplatform/NotTested/tertio-$mrnumber-$hostplatform-build$build_number\_$dtformat\.tar") or die("Couldn't copy to destination $!");
    	#dummy comment.
      	push(@location,"$tertiodest/$hostplatform/NotTested/tertio-$mrnumber-$hostplatform-build$build_number\_$dtformat\.tar");
  	    print LOCATION "$tertiodest/$hostplatform/NotTested/tertio-$mrnumber-$hostplatform-build$build_number\_$dtformat\.tar  \n";
	}
	elsif($coreproject =~ /RHEL6/)
	{
		$destdir="/u/kkdaadhi/Tertio_Deliverable/rhel6";
      	chdir($destdir);
  	    copy("$Bin/$patchnumber\_README.txt",$destdir);
  	    $hostplatform="rhel6";
  	    my @files = <*.tar>;
        if (@files)
        {
               unlink @files or warn "Problem unlinking @files: $!";
        }
        else
        {
              warn "No files to unlink!\n";
        }
  	    `find * -type f -name "*README.txt" | xargs tar cvf tertio-$mrnumber-$hostplatform-build$build_number\.tar; find * -type f  \\( ! -name "*README.txt" ! -name "*.tar" \\) | xargs tar uvf tertio-$mrnumber-$hostplatform-build$build_number\.tar;`;
  	    print "tertio-$mrnumber-$hostplatform-build$build_number\.tar   => $tertiodest/$hostplatform/NotTested/tertio-$mrnumber-$hostplatform-build$build_number\_$dtformat\.tar";
  	    copy("tertio-$mrnumber-$hostplatform-build$build_number\.tar","$tertiodest/$hostplatform/NotTested/tertio-$mrnumber-$hostplatform-build$build_number\_$dtformat\.tar") or die("Couldn't copy to destination $!");
  	    push(@location,"$tertiodest/$hostplatform/NotTested/tertio-$mrnumber-$hostplatform-build$build_number\_$dtformat\.tar");
  	    print LOCATION "$tertiodest/$hostplatform/NotTested/tertio-$mrnumber-$hostplatform-build$build_number\_$dtformat\.tar  \n";
	}
  close LOCATION;
}
main();
