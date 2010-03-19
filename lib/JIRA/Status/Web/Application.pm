package JIRA::Status::Web::Application;

use Moose;
extends 'Tatsumaki::Application';

use Config::JFDI;

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
    my $cfg = $self->config->{model};
    if (my $tt = $cfg->{'JIRA'}) {
        Class::MOP::load_class("JIRA::Status::Web::Model::JIRA");
        return JIRA::Status::Web::Model::JIRA->new(%$tt);
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
    
    my $root = shift->_root_folder;
    Config::JFDI->open(name => 'config', path => $root->stringify, path_to => $root->stringify)
        or croak("Could not load config file");
}

has '_root_folder' => (
    isa => 'Path::Class::Dir',
    coerce => 1,
    is => 'ro',
    builder => '_locate_root_folder'
);

sub _locate_root_folder {
    my $pkg = __PACKAGE__;
    $pkg =~ s|::|/|g;
    $pkg .= ".pm";
    my $pm_file = $INC{$pkg};
    die "Could not locate PM-file: $pm_file" unless ($pm_file and -f $pm_file);
    my $dir = Path::Class::File->new($pm_file)->parent;
    my $root_folder;
    while ($dir->parent and $dir->parent ne $dir) {
        if (-d $dir->subdir('lib') and -d $dir->subdir('static')) {
            $root_folder = $dir;
            last;
        }
        $dir = $dir->parent;
    }
   $dir; 
}
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