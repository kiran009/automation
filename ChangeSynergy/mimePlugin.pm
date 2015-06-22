#!/usr/bin/perl

package ChangeSynergy::mimePlugin;

use ChangeSynergy::csapi;

my $message='';
my $my_dict;

sub initPlugin
{	
	print "Initializing the mime plugin ...\n";

	$args = shift;
        $my_dict = $$args[0];
	return 1;

}


sub Methods
{
	my @methods = ('createEmail','insertText','mimeHeader', 'mimeStart', 'mimeStartText', 'mimeEndText', 'mimeInsertHTML','mimeEnd', 'mimeProcessImages');
	return @methods;
}

my %images;
my %imagesFiles;
my $mimeBmain = "------=_NextPart_" . &makeCID("");
my $mimeBmsg = "------=_NextPart_" . &makeCID("");

sub mimeStart 
{
  print "mimeStart\n";
  my $s = <<ENDOFSTRING
This is a multi-part message in MIME format.
                                                                                
--$mimeBmain
Content-Type: multipart/alternative;
        boundary="$mimeBmsg"
                                                                                
ENDOFSTRING
;
 	return $s;
}


sub mimeStartText 
{
  print "mimeStartText\n";
  my $s = "--$mimeBmsg\nContent-Type: text/plain;\n";
  $s .=   "charset=\"iso-8859-1\"\n\n";
  return $s;
}

sub mimeEndText 
{
  print "mimeEndText\n";
  return "--$mimeBmsg";
}

sub mimeInsertHTML 
{
  my $html = shift @_;
  print "mimeInsertHTML\n";
  my $processedHTML = &processHTML($html);
  my $s = <<ENDOFSTRING
Content-Type: text/html;
        charset="iso-8859-1"

ENDOFSTRING
;
        my $bt = ChangeSynergy::BasicTemplate->new(strip_email_comments => 1, default_undef_identifier => 1);
        # We need this so that we can at least warn about undefined values in the template
    $bt->{default_undef_identifier} = 'Undefined Attribute';
    # This makes it easy to use includes in templates ... make sure the include type is virtual
    $bt->{include_document_root} = $main::template_dir;
  #my $result = $bt->parse(\$processedHTML,\%main::dict, );
  my $result = $bt->parse(\$processedHTML,$my_dict,, );

  return "$s$result\n";
}

sub mimeEnd
{
  print "mimeEnd\n";
  return "--$mimeBmain--";
}

sub mimeHeader 
{
  my $s = <<ENDOFHEADER
MIME-Version: 1.0
Content-Type: multipart/related;
        type="multipart/alternative";
        boundary="$mimeBmain"
X-Priority: 3
X-MSMail-Priority: Normal
X-Unsent: 1
X-MimeOLE: Produced By Microsoft MimeOLE V6.00.2900.2180
ENDOFHEADER
;
	print "mimeHeader\n";
	return $s;
}

sub processHTML 
{
  my $file = shift @_;
if (open(FD,"<$main::template_dir/$file"))
{
  foreach (<FD>) 
  {
    if (/['"]([^'"]+\.(gif|jpg|jpeg|png))['"]/i) 
	{
      if (open(FDIMG,"<$main::template_dir/$1"))
	  {
        $imagesCID{uc("$1")} = &makeCID(lc("$1"));
	$images{uc("$1")} = "$1";
	close(FDIMG);
      }
    }
  }
  close(FD);
  my $tmpl = "";
  open(FD,"<$main::template_dir/$file");
  foreach (<FD>) 
  {
    if (/['"]([^'"]+\.(gif|jpg|jpeg|png))['"]/i) 
	{
      if (defined($images{uc("$1")}))
	  {
        # Found an image.  Now lets replace it with with the CID
        my $cid = $imagesCID{uc("$1")};
        s/['"]([^'"]+\.(gif|jpg|jpeg|png))['"]/"cid:$cid"/i;
      }
    }
    $tmpl .= $_;
  }
  return $tmpl;
}
else 
{
  print "HTML file not found: $file\n";
  return "";
}
}

sub makeCID
{
  my $name = shift @_;
  $name =~ s/(^.*)\.(gif|jpg|jpeg|png)/$1/i;
  my $x = rand() * 10000000000000;
  my $y = rand() * 10000000000000;
  return ("$x${y}.$name");
}

use integer;
sub old_encode_base64 ($;$)
{
    my $res = "";
    my $eol = $_[1];
    $eol = "\n" unless defined $eol;
    pos($_[0]) = 0;                          # ensure start at the beginning
                                                                                                                             
    $res = join '', map( pack('u',$_)=~ /^.(\S*)/, ($_[0]=~/(.{1,45})/gs));
                                                                                                                             
    $res =~ tr|` -_|AA-Za-z0-9+/|;               # `# help emacs
    # fix padding at the end
    my $padding = (3 - length($_[0]) % 3) % 3;
    $res =~ s/.{$padding}$/'=' x $padding/e if $padding;
    # break encoded string into lines of no more than 76 characters each
    if (length $eol) 
	{
        $res =~ s/(.{1,76})/$1$eol/g;
    }
    return $res;
}
sub mimeProcessImages
{
  my $s = "\n--$mimeBmsg--\n\n";
  foreach ( keys %images ) 
  {
    $s .= &processImage($_);
  }
  return ($s);
}

sub processImage 
{
  my $file = shift @_;
print "process64: $file\n";
  $file =~ /([^\/\\]+)\.(gif|jpg|jpeg|png)/i;
  my $name = "$1.$2";
  my $ext = $2;

  my $cid = $imagesCID{$file};
  my $filename = $images{$file};
  my $s = <<ENDOFTEXT
--$mimeBmain
Content-Type: image/$ext;
	name="$name"
Content-Transfer-Encoding: base64
Content-ID: <$cid>

ENDOFTEXT
;

  open (FILE, "<$main::template_dir/$filename");
  binmode FILE;
  while (read(FILE, $buf, 60*57)) {
       $s .= old_encode_base64($buf);
    }
  close FILE;
  return ($s);

}

sub insertText 
{
  my $file = shift @_;

  my $processedText="";

  if (open(FD,"<$main::template_dir/$file")) 
  {
   foreach (<FD>) 
   {
     $processedText .= $_;
   }
   close FD;

  }
  else 
  {
    print "Text template: $file was not found in $main::template_dir\n";
    return "";
  }
  my $bt = ChangeSynergy::BasicTemplate->new(strip_email_comments => 1, default_undef_identifier => 1);
  # We need this so that we can at least warn about undefined values in the template
  $bt->{default_undef_identifier} = 'Undefined Attribute';
  # This makes it easy to use includes in templates ... make sure the include type is virtual
  $bt->{include_document_root} = $main::template_dir;
  my $result = $bt->parse(\$processedText,$my_dict,, );
  return "$result\n";
}

sub createEmail
{
  my $text = shift;
  my $html = shift;

  my $msg;
  $msg .= &mimeHeader() . "\n\n"; 
  $msg .= &mimeStart() . "\n";
  $msg .= &mimeStartText() . "\n";
  $msg .= &insertText($text) . "\n";
  $msg .= &mimeEndText() . "\n";
  $msg .= &mimeInsertHTML($html) . "\n";
  $msg .= &mimeProcessImages() . "\n";
  $msg .= &mimeEnd() . "\n"; 
  return($msg);
}

1;

