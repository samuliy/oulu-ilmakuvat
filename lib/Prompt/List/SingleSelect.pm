=head1 NAME

	Prompt::List::SingleSelect

=cut

package Prompt::List::SingleSelect;

use 5.32.0;
use warnings;

sub new {
	my ($class, @list) = @_;

	return bless {
		_list => \@list
	}, $class;
}

sub prompt {
	my $self = shift;

	my $list_count = 1;
	for my $list_item (@{ $self->{_list} }) {
		say "$list_count: $list_item";
		$list_count++;
	}

	my $ok = 0;
	while (! $ok) {
		my $choice = <STDIN>;
		chomp($choice);

		if ($choice =~ /^\d+$/) {
			my $index = $choice - 1;
			if (defined $self->{_list}[$index]) {
				return $self->{_list}[$index];
			}
		}
	}
}

1;
