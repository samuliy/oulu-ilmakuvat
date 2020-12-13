=head1 NAME

	WMS::Layer

=cut

package WMS::Layer;

use strict;
use warnings;

sub new {
	my ($class, $xml_hashref) = @_;
	return bless $xml_hashref, $class;
}

sub get_layers {
	my $self = shift;
	my %layers;
	for my $layer (@{ $self->{Layer} }) {
		$layers{ $layer->{Name} } = WMS::Layer->new($layer);
	}
	return %layers;
}

1;
