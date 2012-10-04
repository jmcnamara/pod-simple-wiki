package Pod::Simple::Wiki::UseMod;

###############################################################################
#
# Pod::Simple::Wiki::UseMod - A class for creating Pod to UseMod filters.
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
            '<b>'    => '<b>',
            '</b>'   => '</b>',
            '<i>'    => '<i>',
            '</i>'   => '</i>',
            '<tt>'   => '<tt>',
            '</tt>'  => '</tt>',
            '<pre>'  => "\n<pre>\n",
            '</pre>' => "\n</pre>\n\n",

            '<h1>'   => "\n= ",
            '</h1>'  => " =\n\n",
            '<h2>'   => "\n== ",
            '</h2>'  => " ==\n\n",
            '<h3>'   => "\n=== ",
            '</h3>'  => " ===\n",
            '<h4>'   => "\n==== ",
            '</h4>'  => " ====\n\n",
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
    return $self;
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
         $self->_append('*' x $indent_level);
    }
    elsif ($item_type eq 'number') {
         $self->_append('#' x $indent_level);
    }
    elsif ($item_type eq 'text') {
         $self->_append(';' x $indent_level);
    }
}


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

    # Split the text into tokens but maintain the whitespace
    my @tokens = split /(\s+)/, $text;

    # Escape any tokens here.

    # Rejoin the tokens and whitespace.
    $self->{_wiki_text} .= join '', @tokens;
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
sub _end_item_text     {$_[0]->_output(':')}


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
        $self->_append(":" x $indent_level);
    }
}


1;


__END__


=head1 NAME

Pod::Simple::Wiki::UseMod - A class for creating Pod to UseMod wiki filters.

=head1 SYNOPSIS

This module isn't used directly. Instead it is called via C<Pod::Simple::Wiki>:

    #!/usr/bin/perl -w

    use strict;
    use Pod::Simple::Wiki;


    my $parser = Pod::Simple::Wiki->new('UseMod');

    ...


Convert Pod to a UseMod wiki format using the installed C<pod2wiki> utility:

    pod2wiki --style UseMod file.pod > file.wiki


=head1 DESCRIPTION

The C<Pod::Simple::Wiki::UseMod> module is used for converting Pod text to Wiki text.

Pod (Plain Old Documentation) is a simple markup language used for writing Perl documentation.

For an introduction to UseMod see: http://www.usemod.com/cgi-bin/wiki.pl

This module isn't generally invoked directly. Instead it is called via C<Pod::Simple::Wiki>. See the L<Pod::Simple::Wiki> and L<pod2wiki> documentation for more information.


=head1 METHODS

Pod::Simple::Wiki::UseMod inherits all of the methods of C<Pod::Simple> and C<Pod::Simple::Wiki>. See L<Pod::Simple> and L<Pod::Simple::Wiki> for more details.


=head1 SEE ALSO

This module also installs a C<pod2wiki> command line utility. See C<pod2wiki --help> for details.


=head1 ACKNOWLEDGEMENTS

Submit a bugfix or test and your name will go here.


=head1 DISCLAIMER OF WARRANTY

Please refer to the DISCLAIMER OF WARRANTY in L<Pod::Simple::Wiki>.


=head1 AUTHORS

John McNamara jmcnamara@cpan.org


=head1 COPYRIGHT

� MMIII-MMVIII, John McNamara.

All Rights Reserved. This module is free software. It may be used, redistributed and/or modified under the same terms as Perl itself.
