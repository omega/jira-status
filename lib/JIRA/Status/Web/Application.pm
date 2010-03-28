package JIRA::Status::Web::Application;

use Moose;
extends 'Tatsumaki::Application';
use JIRA::Status::Config;
with 'JIRA::Status::Config::Role';

use Path::Class::File;
use MooseX::Types::Path::Class;

has 'view' => (
    isa => 'Object',
    is => 'ro',
    lazy => 1,
    builder => '_build_view',
    handles => [qw/render_file/],
);

sub _build_view {
    my $self = shift;
    my $cfg = $self->config->{view};
    if (my $tt = $cfg->{'TT'}) {
        Class::MOP::load_class("JIRA::Status::Web::View::TT");
        return JIRA::Status::Web::View::TT->new(%$tt);
    }
}

sub model {
    my $self = shift;
    
    my $cfg = $self->config->{db};
    if ($cfg) {
        Class::MOP::load_class("JIRA::Status::Web::Model::Events");
        return JIRA::Status::Web::Model::Events->new(db => $cfg);
    }
}

sub _root_folder {
    return shift->config->{root_folder};
}
has '+static_path' => (default => sub { shift->_root_folder->subdir('static')->stringify;});


1;