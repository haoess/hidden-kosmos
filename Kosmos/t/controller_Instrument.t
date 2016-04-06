use strict;
use warnings;
use Test::More;


use Catalyst::Test 'Kosmos';
use Kosmos::Controller::Instrument;

ok( request('/instrument')->is_success, 'Request should succeed' );
done_testing();
