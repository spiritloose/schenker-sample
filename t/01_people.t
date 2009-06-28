use strict;
use warnings;
use Test::More tests => 11;
use HTTP::Request::Common qw(GET HEAD PUT POST DELETE);

BEGIN { require 'sample.pl' }

my $res;

$res = Schenker::run(GET 'http://localhost/people/');
ok($res->is_success);

$res = Schenker::run(POST 'http://localhost/people/', {
    'person[name]' => 'Michael Schenker',
    'person[age]'  => 54,
});
ok($res->is_redirect);
my $id = $res->header('Location') =~ m{/people/(\d+)};
ok($id);

$res = Schenker::run(GET "http://localhost/people/$id");
like($res->content, qr/Michael Schenker/);

$res = Schenker::run(GET "http://localhost/people/$id/edit");
like($res->content, qr/Michael Schenker/);

$res = Schenker::run(POST "http://localhost/people/$id", {
    _method => 'PUT',
    'person[name]' => 'Rudolf Schenker',
    'person[age]'  => 60,
});
ok($res->is_redirect);
$id = $res->header('Location') =~ m{/people/(\d+)};
ok($id);

$res = Schenker::run(GET "http://localhost/people/$id");
like($res->content, qr/Rudolf Schenker/);

$res = Schenker::run(GET 'http://localhost/people/');
like($res->content, qr/Rudolf Schenker/);

$res = Schenker::run(POST "http://localhost/people/$id", {
    _method => 'DELETE',
});
ok($res->is_redirect);

$res = Schenker::run(GET "http://localhost/people/$id");
is($res->code, 404);
