use MooseX::Declare;

class JIRA::Status::Web::Model::Events::EventSet {
    use JIRA::Status::Web::Types qw/Event ArrayOfEvents/;
    
    has '_events' => (
        traits => [qw/Array/],
        is => 'ro', isa => ArrayOfEvents,
        default => sub { [ ] },
        handles => {
            '_add_event' => 'push',
            'events' => 'elements',
        },
    );
    # We can't just delegate because we want coercion
    method add_event(Event $event is coerce) {
        $self->_add_event($event);
    }
    
    method as_date_hash() {
        my $date_hash = {};
        foreach ($self->events) {
            push(@{ $date_hash->{ $_->datetime->ymd } }, $_);
        }
        
        return $date_hash;
    }
}
1;
