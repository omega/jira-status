package JIRA::Status::Web::View::TT;
use Moose;

use JIRA::Status::Web::Types qw/TemplateToolkit/;

has 'template' => (
    isa => TemplateToolkit, 
    is => 'ro', 
    coerce => 1,
);

sub render_file {
    my ($self, $template, $args) = @_;
    
    my $output;
    unless ($self->template->process( $template, $args, \$output ) ) {
        return $self->template->error;
    } else {
        return JIRA::Status::Web::View::TT::AsString->new( content => $output );
    }
    
}

package JIRA::Status::Web::View::TT::AsString;

use Moose;

has 'content' => (is => 'ro', isa => 'Str');

sub as_string { return $_[0]->content; }
1;