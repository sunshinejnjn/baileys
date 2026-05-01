#!/usr/bin/perl
use strict;
use warnings;

# Patch 4: Fix websocket.js headers
my $ws_file = 'lib/Socket/Client/websocket.js';
open(my $fh, '<', $ws_file) or die "Cannot open $ws_file: $!";
my @lines = <$fh>;
close($fh);

my $content = join('', @lines);
# Remove incorrectly added headers block (lines with .sec-ch-ua.: etc.)
$content =~ s/\s*headers:\s*\{\s*\.\.\this\.config\.options\?\.\headers,\s*\.\sec-ch-ua\..,//s;

# Add proper headers after origin line
my $headers_block = qq|            origin: DEFAULT_ORIGIN,\n            headers: {\n                ...this.config.options?.headers,\n                'sec-ch-ua': '"Google Chrome";v="147", "Not.A/Brand";v="8", "Chromium";v="147"',\n                'sec-ch-ua-mobile': '?0',\n                'sec-ch-ua-platform': '"Windows"',\n                'user-agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'\n            },|;

$content =~ s/origin: DEFAULT_ORIGIN,/$headers_block/;

open($fh, '>', $ws_file) or die "Cannot write $ws_file: $!";
print $fh $content;
close($fh);
print "Patched $ws_file\n";

# Patch 5: Fix QR code in socket.js
my $sock_file = 'lib/Socket/socket.js';
open($fh, '<', $sock_file) or die "Cannot open $sock_file: $!";
@lines = <$fh>;
close($fh);

$content = join('', @lines);
$content =~ s/const qr = $$ref, noiseKeyB64, identityKeyB64, advB64$$/const qr = [ref, noiseKeyB64, identityKeyB64, advB64, '1'].join(",");/;

open($fh, '>', $sock_file) or die "Cannot write $sock_file: $!";
print $fh $content;
close($fh);
print "Patched $sock_file\n";
