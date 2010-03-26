use MooseX::Declare;

class JIRA::Status::Web::Model::Events::Event {
    # ABSTRACT: Handles all our event differences

    use MooseX::Types::URI qw(Uri);
    use MooseX::Types::DateTime qw(DateTime);

    has 'link' => (is => 'ro', isa => Uri, coerce => 1, required => 0);

    has 'title' => (is => 'ro', isa => 'Str', required => 1);

    has 'summary' => (is => 'ro', isa => 'Str', required => 0, predicate => 'has_summary');

    has 'datetime' => (is => 'ro', isa => DateTime, required => 1);
    
    method type() {
        my ($type) = (ref($self) =~ m/([^:]+)$/);
        return lc($type);
    }
}

class JIRA::Status::Web::Model::Events::Event::JIRA extends JIRA::Status::Web::Model::Events::Event {
    
    has 'status' => (is => 'ro', isa => 'Num', required => 1);
    
    has 'resolution' => (is => 'ro', isa => 'Maybe[Num]', required => 0, predicate => 'resolved');
}

class JIRA::Status::Web::Model::Events::Event::Timed extends JIRA::Status::Web::Model::Events::Event {
    has 'time' => (is => 'ro', isa => 'Str', required => 1);
}
1;