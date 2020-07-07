use strict;
use warnings;

# ARGS:
#   $title: title to display to user
#   $default: default value
sub prompt_string {
  my ($title, $default) = @_;

  if ($default) {
    print $title, ' [', $default, ']', ': ';
  } else {
    print $title, ': ';
  }

  my $value = <STDIN>;
  chomp $value;
  return $value || $default || '';
}

# ARGS:
#   $title: title to display to user
#   $default: default value, 0 for no, 1 for yes
sub prompt_yes_no {
  my ($title, $default) = @_;

  if ($default == 0) {
    $title .= ' (y/N)';
  } elsif ($default == 1) {
    $title .= ' (Y/n)';
  } else {
    $title .= ' (y/n)';
  }
  my $value = uc prompt_string($title);
  if ($value eq 'Y') {
    return 1;
  } elsif ($value eq 'N') {
    return 0;
  } else {
    return $default;
  }
}

1;
