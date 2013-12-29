#!/usr/bin/env perl

use strict;
use warnings;
use WebService::Dropbox;
use File::Basename;

my %config = do '/secret/dropbox.config';
my %nodes = do '/secret/nodes.txt';

#this script expects the following arguments:
#upload.pl /tmp/$build_number/$node <${BUILD_ID}> <${NODE_NAME}>
#the ${} args are avail via jenkins script env
#when new workers are added, nodes.txt needs to be updated

my $path=$ARGV[0];
my $date=$ARGV[1]; #aka ${BUILD_ID}
my $node=$ARGV[2];


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

my @files = glob ($path.'/*');

foreach my $file (@files){
	my $fh_put = IO::File->new($file);

	my $filename = basename($file);

	$dropbox->files_put('builds/'.$date.'/'.$nodes{$node}.'/'.$filename, $fh_put) or die $dropbox->error;
	$fh_put->close;
}
