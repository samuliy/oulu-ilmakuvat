#!/usr/bin/perl

use 5.32.0;
use warnings;
use lib 'lib';

# Dependencies:
# perl-libwww
# perl-lwp-protocol-https
# perl-xml-simple

use WMS::Request;
use Prompt::List::SingleSelect;

my $request = WMS::Request->new();
my $caps = $request->get_capabilities();

my %layers = $caps->get_layers();

my $aerial_photos = $layers{Ilmakuvat};
my %aerial_photos_layers = $aerial_photos->get_layers();

my $layer_prompt = Prompt::List::SingleSelect->new(
	sort keys %aerial_photos_layers
);
my $layer_pick = $aerial_photos_layers{ $layer_prompt->prompt() };

my $bbox_prompt = Prompt::List::SingleSelect->new(
	sort map { $_->{SRS} } @{ $layer_pick->{BoundingBox} }
);
my $bbox_pick = $bbox_prompt->prompt();
$bbox_pick = (grep { $_->{SRS} eq $bbox_pick } @{ $layer_pick->{BoundingBox} })[0];

my $map = $request->get_map(
	$layer_pick->{Name},
	4096,
	4096,
	%{ $bbox_pick }
);

open my $fh, '>', 'map.png';
print $fh $map;
close $fh;

system "eog map.png";
