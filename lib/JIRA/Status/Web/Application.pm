package JIRA::Status::Web::Application;

use Moose;
extends 'Tatsumaki::Application';

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
    if (my $tt = $cfg->{'JIRA'}) {
        Class::MOP::load_class("JIRA::Status::Web::Model::JIRA");
        return JIRA::Status::Web::Model::JIRA->new(%$tt);
    }
}

has 'config' => (
    isa => 'HashRef',
    is => 'rw',
);

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