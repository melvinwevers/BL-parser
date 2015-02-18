package xmlParser::EventHandler::TDT2TXT;

# Input is a file with several <DOC>...</DOC>'s
# One day per file
# Output is one file per <DOC>...</DOC> written to a directory

# NOTE that you have to tweak the xmlParser.pl script to take account of a
# output directory parameter.

# Constructor
sub new {
  my ($class, %hOptions) = @_;

  my $self = \%hOptions;
  bless $self, $class;

  die("ERROR: No OUTPUT_DIR specified.\n") if( ! $self->{sOutputDir} );

  # Chop of trailing (back)slashes
  $self->{sOutputDir} =~ s/[\\\/]+$//;

  # Initialise something?!?
  $self->{bInDocNoTag} = undef;
  $self->{bInTextTag} = undef;
  $self->{sDocNo} = '';
  $self->{sText} = '';

  return $self;
}

sub atStartOfFile {
  my ($self) = @_;

  # print ">> At start of file\n";
}

# This one is called when a tag has been read completely
sub atTag {
  my ($self, $hrTag) = @_;
  if( $hrTag->{sTagName} eq 'DOCNO' ) {
    $self->{bInDocNoTag} = 1;
  }
  elsif( $hrTag->{sTagName} eq '/DOCNO' ) {
    $self->{bInDocNoTag} = undef;
  }
  elsif( $hrTag->{sTagName} eq 'TEXT' ) {
    $self->{bInTextTag} = 1;
  }
  elsif( $hrTag->{sTagName} eq '/TEXT' ) {
    $self->{bInTextTag} = undef;
  }
  elsif( $hrTag->{sTagName} eq '/DOC' ) {
    # End of oducment. Write to output file.
    # We might as well have done this at '</TEXT>' but well...
    my $sOutputFile = $self->{sOutputDir} . "/" . $self->{sDocNo} . ".txt";
    open(FH_OUT, "> $sOutputFile") or 
      die("ERROR: Couldn't open $sOutputFile for writing: $!\n");
    print FH_OUT $self->{sText};
    close(FH_OUT);
  }
}

# Gets called when some text has been read
sub atText {
  my ($self, $hrText) = @_;

#  print "Text: '$hrText->{sText}'\n";
  if($self->{bInDocNoTag} ) {
    $self->{sDocNo} = $hrText->{sText};
    # Chop off leading/trailing spaces
    $self->{sDocNo} =~ s/^\s+//;
    $self->{sDocNo} =~ s/\s+$//;
  }
  elsif($self->{bInTextTag}) {
    $self->{sText} = $hrText->{sText};
  }
}

#sub setOutputFileHandle {
#  my ($self, $fhOut) = @_;

#  $self->{fhOut} = $fhOut;
#}

sub atEndOfFile {
  my ($self) = @_;

  #print ">> At end of file\n";
}

1;
