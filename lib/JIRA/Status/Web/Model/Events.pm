use MooseX::Declare;


class JIRA::Status::Web::Model::Events {
    use Carp qw/carp/;
    
    use JIRA::Status::Web::Types qw/ArrayOfEventSources/;
    use MooseX::Types::DateTime qw(DateTime);
    
    use JIRA::Status::Web::Model::Events::EventSet;
    use JIRA::Status::Web::Model::Events::EventSource;
    
    has 'sources' => (
        traits => [qw/Array/],
        is => 'ro',
        isa => ArrayOfEventSources,
        coerce => 1,
        default => sub {[]},
        handles => {
            'all_sources' => 'elements',
            '_grep_sources' => 'grep',
        },
    );
    method get_source(Str $name) {
        my ($source, $overflow) = $self->_grep_sources(sub { $_->name eq $name });
        # XXX: This should really use the logging shit from Plack somehow :/
        carp("You asked for a source named $name, but we got more than one result. Check your config") if $overflow;
        return $source;
    }
    method get_events_by_month() {
        my $events = JIRA::Status::Web::Model::Events::EventSet->new();

        foreach my $source ($self->all_sources) {
            
            foreach my $event ($source->events) {
                $events->add_event($event);
                
            }
            
        }
        return $events->as_date_hash();
    }
}


1;