use MooseX::Declare;

namespace JIRA::Status::Web::Model;

use JIRA::Status::Data::Db;

class ::Events with JIRA::Status::Data::Db::Role {
    use Carp qw/carp/;

    has '_scope' => (is => 'rw', isa => 'Any');
    
    method get_events_by_month() {
        # Should just get this from the MongoDB
        
        $self->_scope($self->db->new_scope);
        
        my $events = $self->get_eventset();
        return $events->as_date_hash();
    }
    
    method get_historical_events(DateTime $limit, DateTime $oldest?) {
        $self->_scope($self->db->new_scope);

        my $events = $self->get_eventset();
        
        return $events->old_events($limit) unless $oldest;
        return $events->old_events($limit, $oldest);
    }
}

1;