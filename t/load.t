#!/usr/bin/perl -w

###############################################################################
#
# A test for Pod::Simple::Wiki.
#
# Test that the module loads.
#
# reverse('©'), August 2004, John McNamara, jmcnamara@cpan.org
#

use strict;

use Test::More tests => 2;

BEGIN { use_ok( 'Pod::Simple::Wiki' ); }

my $parser = Pod::Simple::Wiki->new;
isa_ok( $parser, 'Pod::Simple::Wiki' );
