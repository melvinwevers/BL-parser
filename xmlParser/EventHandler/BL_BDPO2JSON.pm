use strict;
use HTML::Entities;
use JSON;

package xmlParser::EventHandler::BL_BDPO2JSON;

use Data::Dumper;

# Input is an XML file in BL format

# Constructor
sub new {
  my ($class, %hOptions) = @_;

  my $self = \%hOptions;
  bless $self, $class;

  # Initialise something
  $self->{bInTitleTag} = undef;
  $self->{bInNormalisedDate} = undef;
  $self->{bInPageText} = undef;
  $self->{bInPageWord} = undef;
  $self->{bInPageImageFile} = undef;
  $self->{bInPlaceofPublication} = undef;
  $self->{bInSubCollection} = undef;
  $self->{bInTypeofPublication} = undef;



  return $self;
}

sub atStartOfFile {
  my ($self) = @_;

  # print ">> At start of file\n";
  print "["; # Start of an array
}

# This one is called when a tag has been read completely
sub atTag {
  my ($self, $hrTag) = @_;

  if( $hrTag->{sTagName} eq 'BL_newspaper' ) {
    $self->{hrNewspaperData} = {};
    $self->{arText} = ();
  }
  elsif( $hrTag->{sTagName} eq '/BL_newspaper' ) {
    # Prepare the text
    $self->{hrNewspaperData}->{text_content} = join(' ', @{$self->{arText}});

    # print everything we have as JSON
    print JSON::to_json( $self->{hrNewspaperData}, { utf8 => 1, pretty => 1 } );
  }
  elsif( $hrTag->{sTagName} eq 'title' ) {
    $self->{bInTitleTag} = 1;
  }
  elsif( $hrTag->{sTagName} eq '/title' ) {
    $self->{bInTitleTag} = undef;
  }
  elsif( $hrTag->{sTagName} eq 'subCollection' ) {
    $self->{bInSubCollection} = 1;
  }
  elsif( $hrTag->{sTagName} eq '/subCollection' ) {
    $self->{bInSubCollection} = undef;
  }
    elsif( $hrTag->{sTagName} eq 'typeOfPublication' ) {
    $self->{bInTypeofPublication} = 1;
  }
  elsif( $hrTag->{sTagName} eq '/typeOfPublication' ) {
    $self->{bInTypeofPublication} = undef;
  }
  elsif( $hrTag->{sTagName} eq 'placeOfPublication' ) {
    $self->{bInPlaceofPublication} = 1;
  }
  elsif( $hrTag->{sTagName} eq '/placeOfPublication' ) {
    $self->{bInPlaceofPublication} = undef;
  }
  elsif( $hrTag->{sTagName} eq 'normalisedDate' ) {
    $self->{bInNormalisedDate} = 1;
  }
  elsif( $hrTag->{sTagName} eq '/normalisedDate' ) {
    $self->{bInNormalisedDate} = undef;
  }
  elsif( $hrTag->{sTagName} eq 'pageText' ) {
    $self->{bInPageText} = 1;
  }
  elsif( $hrTag->{sTagName} eq '/pageText' ) {
    $self->{bInPageText} = undef;
  }
  elsif( $hrTag->{sTagName} eq 'pageImageFile' ) {
    $self->{bInPageImageFile} = 1;
  }
  elsif( $hrTag->{sTagName} eq '/pageImageFile' ) {
    $self->{bInPageImageFile} = undef;
  }
  elsif( $hrTag->{sTagName} eq 'pageWord' ) {
    if ( $self->{bInPageText} ) {
      $self->{bInPageWord} = 1;
    }
  }
  elsif( $hrTag->{sTagName} eq '/pageWord' ) {
    $self->{bInPageWord} = undef;
  }
}

# Gets called when some text has been read
sub atText {
  my ($self, $hrText) = @_;

  if($self->{bInTitleTag} ) {
    $self->{hrNewspaperData}->{paper_dc_title} = $hrText->{sText};
    $self->{hrNewspaperData}->{article_dc_title} = $hrText->{sText};
  }
  elsif($self->{bInNormalisedDate}) {
    $self->{hrNewspaperData}->{paper_dc_date} = $hrText->{sText};
    $self->{hrNewspaperData}->{paper_dc_date} =~ s/\./-/g;
  }
  elsif($self->{bInTypeofPublication}) {
    $self->{hrNewspaperData}->{article_dc_subject} = $hrText->{sText};
  }
  elsif($self->{bInSubCollection}) {
    $self->{hrNewspaperData}->{paper_dcterms_spatial} = $hrText->{sText};
    $self->{hrNewspaperData}->{paper_dcterms_temporal} = $hrText->{sText};
  }
  elsif($self->{bInPlaceofPublication}) {
    $self->{hrNewspaperData}->{paper_dcterms_spatial_creation} = $hrText->{sText};
  }
  if($self->{bInPageImageFile} ) {
    # Is er een apart veld voor het plaatje?
    $self->{hrNewspaperData}->{paper_dc_identifier_resolver} = $hrText->{sText};

    # Dit is ook wel een goed iets - maar dan zonder .tif aan het eind - als
    # identifier.
    $self->{hrNewspaperData}->{identifier} = $hrText->{sText};
    $self->{hrNewspaperData}->{identifier} =~ s/\.[^\.]+$//;
  }
  elsif($self->{bInPageWord}) {
    push(@{$self->{arText}}, HTML::Entities::decode_entities($hrText->{sText}))
  }
}

sub atEndOfFile {
  my ($self) = @_;

  #print ">> At end of file\n";
  print "]" #End of the array
}

1;
