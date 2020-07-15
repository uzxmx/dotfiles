use strict;
use warnings;

use File::Basename;
use String::ShellQuote 'shell_quote';

sub remove_path_from_env {
  my ($target) = @_;
  my @paths = split(/:/, $ENV{'PATH'});
  my @tmp = ();
  for my $path (@paths) {
    if ($path ne $target and $path ne "") {
      push @tmp, $path;
    }
  }
  $ENV{'PATH'} = join(':', @tmp);
}

sub print_and_exit {
  my ($cmdline, $code) = @_;

  open(SIGNAL, ">&=3");
  print SIGNAL shell_quote(@$cmdline);
  close(SIGNAL);
  exit $code;
}

sub run_original_if_required {
  my ($check_dash) = @_;
  if ($check_dash && scalar(@ARGV) && $ARGV[0] eq '-') {
    $ARGV[0] = basename($0);
    run_original(0);
  } elsif (!$check_dash && scalar(@ARGV)) {
    run_original();
  }
}

sub run_original {
  my ($add_program) = @_;

  if (!defined($add_program) || $add_program) {
    unshift @ARGV, basename($0);
  }
  print_and_exit(\@ARGV, 100);
}

1;
