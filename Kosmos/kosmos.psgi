use strict;
use warnings;

use Kosmos;

my $app = Kosmos->apply_default_middlewares(Kosmos->psgi_app);
$app;

