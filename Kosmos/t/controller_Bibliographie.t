use strict;
use warnings;
use Test::More;


use Catalyst::Test 'Kosmos';
use Kosmos::Controller::Bibliographie;

ok( request('/bibliographie')->is_success, 'Request should succeed' );
done_testing();
