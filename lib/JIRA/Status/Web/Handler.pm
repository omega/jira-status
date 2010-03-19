package JIRA::Status::Web::Handler;
use Moose;
extends 'Tatsumaki::Handler';
__PACKAGE__->asynchronous(1);

sub model {
    return $_[0]->application->model;
}

sub uri_for {
    my($self, $path, $args) = @_;
    my $uri = $self->request->base;
    $path =~ s|^/|| if $uri =~ m|/$|;
    
    $uri->path($uri->path . $path);
    $uri->query_form($args) if $args;
    
    $uri->path_query;
}


around 'render' => sub {
    my $orig = shift;
    my $self = shift;
    my $template = shift;
    my $args = shift;
    
    $args->{c} = $self;
    
    $self->$orig($template, $args);
};

1;