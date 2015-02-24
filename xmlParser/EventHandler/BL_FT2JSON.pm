package xmlParser::EventHandler::BL_FT2JSON;

use strict;
use HTML::Entities;
use JSON;
use Data::Dumper;

# Input is an XML file of the Financial Times, in BL format

# Constructor
sub new {
  my ($class, %hOptions) = @_;

  my $self = \%hOptions;
  bless $self, $class;

  # Initialise something
  $self->{hrTagsToFollow} = {issue => 1, pf => 1, article => 1, ti => 1,
                             text => 1, 'text.cr' => 1, wd => 1, id => 1};

  for my $sTag (keys(@{$self->{arTagsToFollow}})) {
    $self->{'b_in_' . $sTag} = undef;
  }

  $self->{sSeparator} = "";

  $self->init();

  return $self;
}

sub atStartOfFile {
  my ($self) = @_;

  print "["; # Start of an array
}

sub init {
  my ($self) = @_;

  $self->{arText} = [];

  # Save the date (if we have it)
  my $sTmpDate = undef;
  if( exists($self->{hrNewspaperData}->{paper_dc_date})) {
    $sTmpDate = $self->{hrNewspaperData}->{paper_dc_date};
  }
  $self->{hrNewspaperData} = {};
  if( defined($sTmpDate) ) {
    $self->{hrNewspaperData}->{paper_dc_date} = $sTmpDate
  }

  # This is hard-coded...
  $self->{hrNewspaperData}->{paper_dc_title} = "The Financial Times";
  $self->{hrNewspaperData}->{paper_dcterms_spatial} = "National";
  $self->{hrNewspaperData}->{paper_dcterms_temporal} = "Daily";
}

# This one is called when a tag has been read completely
sub atTag {
  my ($self, $hrTag) = @_;

  if( exists($self->{hrTagsToFollow}->{$hrTag->{sTagName}}) ) {
    $self->{'b_in_' . $hrTag->{sTagName}} = 1;
  }
  elsif( (substr($hrTag->{sTagName}, 0, 1) eq '/') &&
         (exists($self->{hrTagsToFollow}->{substr($hrTag->{sTagName}, 1)})) ) {
    $self->{'b_in_' . substr($hrTag->{sTagName}, 1)} = undef;
  }

  if( $hrTag->{sTagName} eq 'article') {
    $self->{hrNewspaperData}->{article_dc_subject} =
      $hrTag->{hrAttributes}->{type};
  }
  elsif( $hrTag->{sTagName} eq '/article') { # At the end of an article
    # Prepare the text
    $self->{hrNewspaperData}->{text_content} = join(' ', @{$self->{arText}});

    # print everything we have as JSON
    print $self->{sSeparator} . JSON::to_json( $self->{hrNewspaperData},
                                               { utf8 => 1, pretty => 1 } );
    # After we printed the first entry we prefix every entry with a comma
    $self->{sSeparator} = ",";

    # Start afresh
    $self->init();
  }
}

# Gets called when some text has been read
sub atText {
  my ($self, $hrText) = @_;

  if($self->{b_in_issue} ) {
    if ($self->{b_in_pf} ) {
      # Convert date: 19910301 -> 01-03-1991
      $self->{hrNewspaperData}->{paper_dc_date} =
        substr($hrText->{sText}, 0, 4) . "-" .
          substr($hrText->{sText}, 4, 2) . "-" .
            substr($hrText->{sText}, 6, 2);
    }
    elsif ($self->{b_in_article} ) {
      if ( $self->{b_in_id} ) {
        # Copy the id
        $self->{hrNewspaperData}->{_id} = $hrText->{sText};
        # However, Texcavator can not deal with dashes, so we replace these by
        # underscores
        $self->{hrNewspaperData}->{_id} =~ s/-/_/g;
      }
      elsif( $self->{b_in_ti} ) {
        $self->{hrNewspaperData}->{article_dc_title} = 
          HTML::Entities::decode_entities($hrText->{sText});
      }
      elsif($self->{'b_in_text.cr'} && $self->{b_in_wd} ) {
        push(@{$self->{arText}}, 
             HTML::Entities::decode_entities($hrText->{sText}));
      }
    }
  }
}

sub atEndOfFile {
  my ($self) = @_;

  print "]" # End of the array
}

1;
