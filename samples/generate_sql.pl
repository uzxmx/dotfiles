#!/usr/bin/env perl

srand;

open(WORDS, "<", "/usr/share/dict/words") or die $!;
open(DEST, ">>", "/tmp/test.sql") or die $!;

chomp(my @lines = <WORDS>);
my $words_count = scalar(@lines);

my $i = 0;
while ($i++ < 100000) {
  my $name = $lines[int(rand($words_count))];
  my $gender = int(rand(2));
  my $description = $lines[int(rand($words_count))];

  print DEST "insert into pets values ('$name', $gender, '$description');\n";
}

close(WORDS);
close(DEST);

print "Generated succefully.\n"
