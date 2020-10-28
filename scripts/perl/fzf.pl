use strict;
use warnings;

use IPC::Open2;

sub fzf_select {
  my ($fzf_options, $input, $exit_when_empty) = @_;

  open2 my $out, my $in, 'fzf', @$fzf_options or die $!;

  if (ref($input) eq 'ARRAY') {
    print $in "$_\n" for @$input;
    close($in);
  }

  my @result = ();
  while (<$out>) {
    chomp $_;
    push @result, $_;
  }
  close($out);

  if ((!defined($exit_when_empty) || $exit_when_empty) && scalar(@result) == 0) {
    exit;
  }

  return @result;
}

1;
