use MooseX::Declare;
namespace JIRA::Status::Data;

class ::Db extends KiokuX::Model {
    use MongoDB::Connection; # Need to do this, since the MongoDB-backend isn't doing it yet

    use JIRA::Status::Data::Events::Event;
    use JIRA::Status::Data::Events::EventSource;
    use JIRA::Status::Data::Events::EventSet;

    # Just something

    # Now we need to have something for colecting and storing in

    method store_eventset(JIRA::Status::Data::Events::EventSet $set) {
        $self->txn_do(sub {
            $self->delete('event_set');
            $self->store('event_set' => $set);

        });

    }

    # This is for reading, not sure I like mixing it in here, but oh well
    method get_eventset() {
        $self->lookup('event_set');
    }
}

role ::Db::Role {
    use JIRA::Status::Web::Types qw/Db/;

    has 'db' => (
        is => 'ro',
        isa => Db,
        handles => [qw/get_eventset/],
        coerce => 1,
        builder => '_get_db',
        lazy => 1,
    );

    method _get_db() {
        JIRA::Status::Data::Db->new($self->config->{db});
    }

}

1;
