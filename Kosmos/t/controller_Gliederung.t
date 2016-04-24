use strict;
use warnings;
use Test::More;


use Catalyst::Test 'Kosmos';
use Kosmos::Controller::Gliederung;

ok( request('/gliederung')->is_success, 'Request should succeed' );
done_testing();
