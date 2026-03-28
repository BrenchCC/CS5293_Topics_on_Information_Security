#!/usr/bin/env perl

use strict;
use warnings;
use Fcntl qw(SEEK_SET);

my $file = shift @ARGV or die "Usage: patch_execstack.pl <elf-file>\n";

open my $fh, "+<", $file or die "Cannot open $file: $!\n";
binmode $fh;

seek($fh, 28, SEEK_SET);
read($fh, my $buf, 4) == 4 or die "Failed to read program header offset\n";
my $program_header_offset = unpack("V", $buf);

seek($fh, 42, SEEK_SET);
read($fh, $buf, 2) == 2 or die "Failed to read program header entry size\n";
my $program_header_entry_size = unpack("v", $buf);
read($fh, $buf, 2) == 2 or die "Failed to read program header count\n";
my $program_header_count = unpack("v", $buf);

my $patched = 0;
for my $index (0 .. $program_header_count - 1) {
    my $entry_offset = $program_header_offset + $index * $program_header_entry_size;

    seek($fh, $entry_offset, SEEK_SET);
    read($fh, $buf, 4) == 4 or die "Failed to read program header type\n";
    my $type = unpack("V", $buf);

    next unless $type == 0x6474e551;    # PT_GNU_STACK

    seek($fh, $entry_offset + 24, SEEK_SET);
    print {$fh} pack("V", 7);           # PF_R | PF_W | PF_X
    $patched = 1;
    last;
}

close $fh;

die "PT_GNU_STACK not found in $file\n" unless $patched;
