#!/usr/bin/env perl

use strict;
use warnings;
use WebService::Dropbox;

my %config = do '/secret/dropbox.config';
my %nodes = do 'nodes.txt';

#this script expects the following arguments:
#upload.pl <${WORKSPACE}/filename.ext> <${BUILD_ID}> <${NODE_NAME}>
#the ${} args are avail via jenkins script env
#when new workers are added, nodes.txt needs to be updated

print "@ARGV";

my $date;
my $os;
my $os_vers;
my $arch;
my $filename;


my $dropbox = WebService::Dropbox->new({
		key			=> $config{'_2key'},
		secret	=> $config{'_2secret'},
		});

my $access_token = $config{'_2access_token'};
my $access_secret = $config{'_2access_secret'};

# get access token
if (!$access_token or !$access_secret) {
	my $url = $dropbox->login or die $dropbox->error;
	warn "Please Access URL and press Enter: $url";
	<STDIN>;
	$dropbox->auth or die $dropbox->error;
	warn "access_token: " . $dropbox->access_token;
	warn "access_secret: " . $dropbox->access_secret;
} else {
	$dropbox->access_token($access_token);
	$dropbox->access_secret($access_secret);
}

# upload
# https://www.dropbox.com/developers/reference/api#files_put
my $fh_put = IO::File->new('nodes.txt');
#$dropbox->files_put('builds/atest.py', $fh_put) or die $dropbox->error;
$fh_put->close;
