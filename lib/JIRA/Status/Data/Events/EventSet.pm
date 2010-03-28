use MooseX::Declare;
namespace JIRA::Status::Data::Events;

class ::EventSet {
    use JIRA::Status::Web::Types qw/Event ArrayOfEvents/;
    
    has '_events' => (
        traits => [qw/Array/],
        is => 'ro', isa => ArrayOfEvents,
        default => sub { [ ] },
        handles => {
            'add_event' => 'push',
            'events' => 'elements',
        },
    );
    
    method as_date_hash() {
        my $date_hash = {};
        foreach ($self->events) {
            push(@{ $date_hash->{ $_->datetime->ymd } }, $_);
        }
        
        return $date_hash;
    }
    
}
1;
