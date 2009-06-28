#!/usr/bin/env perl
package Sample::Schema;
use strict;
use warnings;
use base qw(DBIx::Class::Schema::Loader);

__PACKAGE__->loader_options(
    moniker_map => { people => 'Person' },
);

package Sample::Server;
use Schenker;

configure sub {
    my $file = options->root->subdir('db')->file(options->environment . '.db');
    my @dsn = ("dbi:SQLite:$file", '', '', { unicode => 1 });
    Sample::Schema->connection(@dsn);
    tt_options WRAPPER => 'layouts/people.tt';
};

configure production => sub {
    disable 'static';
    set server => 'FCGI' if options->server ne 'ModPerl';
};

define_error PersonNotFound => sub {
    status 404;
    content_type 'text/plain';
    body 'No such person';
};

sub Person() {
    Sample::Schema->connect->resultset('Person');
}

get '/' => sub {
    redirect '/people/';
};

# list
get '/people/' => sub {
    my $people = Person->search({}, { order_by => 'id' });
    tt 'people/index';
};

# edit
get '/people/:id/edit' => sub {
    my $args = shift;
    my $person = Person->find($args->{id}) or raise PersonNotFound;
    tt 'people/edit';
};

# new
get '/people/new' => sub {
    tt 'people/new';
};

# show
get '/people/:id' => sub {
    my $args = shift;
    my $person = Person->find($args->{id}) or raise PersonNotFound;
    tt 'people/show';
};

# create
post '/people/' => sub {
    my $person = Person->create(param('person'));
    redirect '/people/' . $person->id;
};

# put
put '/people/:id' => sub {
    my $args = shift;
    my $person = Person->find($args->{id}) or raise PersonNotFound;
    $person->update(param('person'));
    redirect '/people/' . $person->id;
};

# delete
Delete '/people/:id' => sub {
    my $args = shift;
    my $person = Person->find($args->{id}) or raise PersonNotFound;
    $person->delete;
    redirect '/people/';
};

