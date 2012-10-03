package Pod::Simple::Wiki::MediaWiki;

###############################################################################
#
# Pod::Simple::Wiki::MediaWiki - A class for creating Pod to MediaWiki filters.
#
#
# Copyright 2003-2008, John McNamara, jmcnamara@cpan.org
#
# Documentation after __END__
#

use Pod::Simple::Wiki;
use strict;
use vars qw(@ISA $VERSION);


@ISA     = qw(Pod::Simple::Wiki);
$VERSION = '0.08';


###############################################################################
#
# The tag to wiki mappings.
#
my $tags = {
            '<b>'    => "'''",
            '</b>'   => "'''",
            '<i>'    => "''",
            '</i>'   => "''",
            '<tt>'   => '<tt>',
            '</tt>'  => '</tt>',
            '<pre>'  => "<code>\n",
            '</pre>' => "\n</code>\n",

            '<h1>'   => '==',
            '</h1>'  => "==\n",
            '<h2>'   => '===',
            '</h2>'  => "===\n",
            '<h3>'   => '====',
            '</h3>'  => "====\n",
            '<h4>'   => '=====',
            '</h4>'  => "=====\n",
           };


###############################################################################
#
# new()
#
# Simple constructor inheriting from Pod::Simple::Wiki.
#
sub new {

    my $class                   = shift;
    my $self                    = Pod::Simple::Wiki->new('Wiki', @_);
       $self->{_tags}           = $tags;

    bless  $self, $class;

    $self->accept_targets('MediaWiki');
    $self->nbsp_for_S(1);

    return $self;
}


###############################################################################
#
# _append()
#
# Appends some text to the buffered Wiki text.
#
sub _append {

    my $self = shift;

    if ($self->{_indent_text}) {
      $self->{_wiki_text} .= $self->{_indent_text};
      $self->{_indent_text} = '';
    }

    $self->{_wiki_text} .= $_[0];
}


###############################################################################
#
# _indent_item()
#
# Indents an "over-item" to the correct level.
#
sub _indent_item {

    my $self         = shift;
    my $item_type    = $_[0];
    my $item_param   = $_[1];
    my $indent_level = $self->{_item_indent};

    if    ($item_type eq 'bullet') {
         $self->_append('*' x $indent_level . ' ');
    }
    elsif ($item_type eq 'number') {
         $self->_append('#' x $indent_level . ' ');
    }
    elsif ($item_type eq 'text') {
         $self->_append(':' x ($indent_level-1) . '; ');
    }
}


###############################################################################
#
# Functions to deal with links.

sub _start_L {
  my ($self, $attr) = @_;

  unless ($self->_skip_headings) {
    $self->_append('');         # In case we have _indent_text pending
    $self->_output; # Flush the text buffer, so it will contain only the link text
    $self->{_link_attr} = $attr; # Save for later
  } # end unless skipping formatting because in heading
} # end _start_L

sub _end_L {
  my $self = $_[0];

  my $attr = delete $self->{_link_attr};

  if ($attr and my $method = $self->can('_format_link')) {
    $self->{_wiki_text} = $method->($self, $self->{_wiki_text}, $attr);
  } # end if link to be processed
} # end _end_L


###############################################################################
#
# _format_link

sub _format_link {
  my ($self, $text, $attr) = @_;

  if ($attr->{type} eq 'url') {
    my $link = $attr->{to};

    return $link if $attr->{'content-implicit'};
    return "[$link $text]";
  } # end if hyperlink to URL

  # Manpage:
  if ($attr->{type} eq 'man') {
    # FIXME link to http://www.linuxmanpages.com?
    return "<tt>$text</tt>" if $attr->{'content-implicit'};
    return "$text (<tt>$attr->{to}</tt>)";
  } # end if manpage

  die "Unknown link type $attr->{type}" unless $attr->{type} eq 'pod';

  # Handle a link within this page:
  return "[[#$attr->{section}|$text]]" unless defined $attr->{to};

  # Handle a link to a specific section in another page:
  return "[[$attr->{to}#$attr->{section}|$text]]" if defined $attr->{section};

  return "[[$attr->{to}]]" if $attr->{'content-implicit'};

  return "[[$attr->{to}|$text]]";
} # end _format_link


###############################################################################
#
# _handle_text()
#
# Perform any necessary transforms on the text. This is mainly used to escape
# inadvertent CamelCase words.
#
sub _handle_text {

    my $self = shift;
    my $text = $_[0];

    unless ($self->{_in_Data}) {
      # Escape colons in definition lists:
      if ($self->{_in_item_text}) {
        $text =~ s/:/&#58;/g;   # A colon would end the item
      }

      # Escape empty lines in verbatim sections:
      if ($self->{_in_Verbatim}) {
        $text =~ s/^$/ /mg;    # An empty line would split the section
      }

      $text =~ s/\xA0/&nbsp;/g; # Convert non-breaking spaces to entities

      $text =~ s/''/'&#39;/g;   # It's not a formatting code
    } # end unless in data paragraph

    $self->_append($text);
}


###############################################################################
#
# Functions to deal with =over ... =back regions for
#
# Bulleted lists
# Numbered lists
# Text     lists
# Block    lists
#
sub _end_item_text     { }      # _start_Para will insert the :


###############################################################################
#
# _start_Para()
#
# Special handling for paragraphs that are part of an "over" block.
#
sub _start_Para {

    my $self         = shift;
    my $indent_level = $self->{_item_indent};

    if ($self->{_in_over_block}) {
      $self->{_indent_text} = (':' x $indent_level);
    }

    if ($self->{_in_over_text}) {
      $self->{_indent_text} = "\n" . (':' x $indent_level);
    }
}

######################################################################
#
# _end_Data
#
# Special handling for data paragraphs

sub _end_Data { $_[0]->_output("\n\n") }

1;


__END__


=head1 NAME

Pod::Simple::Wiki::MediaWiki - A class for creating Pod to MediaWiki wiki filters.

=head1 SYNOPSIS

This module isn't used directly. Instead it is called via C<Pod::Simple::Wiki>:

    #!/usr/bin/perl -w

    use strict;
    use Pod::Simple::Wiki;


    my $parser = Pod::Simple::Wiki->new('MediaWiki');

    ...


Convert Pod to a Mediawiki wiki format using the installed C<pod2wiki> utility:

    pod2wiki --style MediaWiki file.pod > file.wiki


=head1 DESCRIPTION

The C<Pod::Simple::Wiki::MediaWiki> module is used for converting Pod text to Wiki text.

Pod (Plain Old Documentation) is a simple markup language used for writing Perl documentation.

For an introduction to MediaWiki see: http://www.mediawiki.org/wiki/MediaWiki

This module isn't generally invoked directly. Instead it is called via C<Pod::Simple::Wiki>. See the L<Pod::Simple::Wiki> and L<pod2wiki> documentation for more information.


=head1 METHODS

Pod::Simple::Wiki::MediaWiki inherits all of the methods of C<Pod::Simple> and C<Pod::Simple::Wiki>. See L<Pod::Simple> and L<Pod::Simple::Wiki> for more details.


=head1 SEE ALSO

This module also installs a C<pod2wiki> command line utility. See C<pod2wiki --help> for details.


=head1 ACKNOWLEDGEMENTS

Thanks Tony Sidaway for initial Wikipedia/MediaWiki support. Christopher J. Madsen for several major additions and tests.


=head1 DISCLAIMER OF WARRANTY

Please refer to the DISCLAIMER OF WARRANTY in L<Pod::Simple::Wiki>.


=head1 AUTHORS

John McNamara jmcnamara@cpan.org

Christopher J. Madsen perl@cjmweb.net


=head1 COPYRIGHT

© MMIII-MMVIII, John McNamara.

All Rights Reserved. This module is free software. It may be used, redistributed and/or modified under the same terms as Perl itself.
