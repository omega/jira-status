package JIRA::Status::Web::Application;

use Moose;
extends 'Tatsumaki::Application';

use Path::Class::File;
use JIRA::Status::Config;
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
    my $cfg = $self->config->{model};
    if (my $tt = $cfg->{'Events'}) {
        Class::MOP::load_class("JIRA::Status::Web::Model::Events");
        return JIRA::Status::Web::Model::Events->new(%$tt);
    }
}

has 'config' => (
    isa => 'HashRef',
    is => 'rw',
    builder => '_load_config',
    lazy => 1,
);

sub _load_config {
    
    # need to locate the damn config-file
    JIRA::Status::Config->new->config;
}

sub _root_folder {
    return shift->config->{root_folder};
}
has '+static_path' => (default => sub { shift->_root_folder->subdir('static')->stringify;});

=pod
around BUILDARGS => sub {
    my $orig = shift;
    my $class = shift;
    if (ref $_[0] eq 'ARRAY') {
        my $handlers = shift @_;
        my @rules;
        while (my($path, $handler) = splice @$handlers, 0, 2) {
            $path = qr/^$path/ unless ref $path eq 'RegExp';
            push @rules, { path => $path, handler => $handler };
        }
        my %args = (@_, _rules => \@rules);
        warn $class . "   ::::   " . dump(\%args);
        $class->$orig(%args);
    } else {
        $class->$orig(@_);
    }
};
=cut
1;