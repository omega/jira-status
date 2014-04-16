use MooseX::Declare;
namespace JIRA::Status::Data::Events;
#PODNAME: JIRA::Status::Data::Events::Event

class ::Event {
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

class ::Event::JIRA extends ::Event
{

    has 'status' => (is => 'ro', isa => 'Num', required => 1);

    has 'resolution' => (is => 'ro', isa => 'Maybe[Num]', required => 0, predicate => 'resolved');

    has 'project' => (is => 'ro', isa => 'Maybe[Str]', required => 0);
    has 'team' => (is => 'ro', isa => 'Str', required => 1);
}

class ::Event::Timed extends ::Event {
    has 'time' => (is => 'ro', isa => 'Str', required => 1);
}
class ::Event::Fullday extends ::Event {
}
1;
