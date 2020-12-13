=head1 NAME

	WMS::Request

=cut

package WMS::Request;

use strict;
use warnings;

use LWP::UserAgent;
use WMS::Capabilities;
use XML::Simple;

use constant WMS_URL => "https://e-kartta.ouka.fi/TeklaOgcWeb/WMS.ashx";
use constant WMS_VERSION => "1.1.1";

sub new {
	my ($class) = @_;
	return bless {}, $class;
}

sub get_capabilities {
	my $self = shift;
	my $caps = $self->_wms_request("GetCapabilities");
	my $xml = XMLin($caps);
	return WMS::Capabilities->new($xml->{Capability});
}

sub get_map {
	my ($self, $layer_name, $width, $height, %bbox) = @_;
	my $map = $self->_wms_request(
		"GetMap",
		BBOX => "$bbox{minx},$bbox{miny},$bbox{maxx},$bbox{maxy}",
		SRS => $bbox{SRS},
		LAYERS => $layer_name,
		VERSION => WMS_VERSION,
		WIDTH => $width,
		HEIGHT => $height,
		FORMAT => "image/png",
		STYLES => "",
	);
	return $map;
}

sub _wms_request {
	my ($self, $request_name, %opts) = @_;

	# Construct GET URL.
	my %request = (
		SERVICE => "WMS",
		REQUEST => $request_name,
		%opts
	);
	my $get_url = WMS_URL . "?" . join('&', map { $_ . "=" . $request{$_} } keys %request);

	# Create a useragent.
	my $ua = LWP::UserAgent->new(timeout => 60);

	# Load proxy settings from environment variables.
	$ua->env_proxy;

	# Execute the request.
	my $response = $ua->get($get_url);

	if (! $response->is_success) {
		die $response->status_line;
	}

	return $response->decoded_content;
}

1;
