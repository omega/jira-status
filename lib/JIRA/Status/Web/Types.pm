package JIRA::Status::Web::Types;
use Template;
use JIRA::Client;
use MooseX::Types
    -declare => [qw/
        TemplateToolkit
        JIRAClient JIRAClientIssue
        EventSource ArrayOfEventSources
        Event ArrayOfEvents
    /]
;

use MooseX::Types::Moose qw/Object HashRef ArrayRef/;


class_type TemplateToolkit, { class => 'Template' };

coerce TemplateToolkit, 
    from HashRef,
    via { Template->new(%$_); }
;
class_type JIRAClient, { class => 'JIRA::Client' };
coerce JIRAClient,
    from ArrayRef,
    via { JIRA::Client->new(@$_); }
;
class_type EventSource, { class => 'JIRA::Status::Web::Model::Events::EventSource' };
subtype ArrayOfEventSources, as ArrayRef[EventSource];

coerce EventSource,
    from HashRef,
    via {
        JIRA::Status::Web::Model::Events::EventSource->instance(%$_);
    }
;

coerce ArrayOfEventSources,
    from ArrayRef,
    via {
        map {
            $_ = to_EventSource($_);
        } @$_;
        $_;
    }
;
class_type Event, { class => 'JIRA::Status::Web::Model::Events::Event' };
subtype ArrayOfEvents, as ArrayRef[Event];

class_type JIRAClientIssue, { class => 'RemoteIssue' };
coerce Event,
    from JIRAClientIssue,
    via {
        Class::MOP::load_class('JIRA::Status::Web::Model::Events::Event');
        JIRA::Status::Web::Model::Events::Event::JIRA->new(
            title => $_->{key},
            summary => $_->{summary},
            datetime => $_->{resolution} ? $_->{updated} : $_->{duedate}, # use updated for resolved issue
            status => $_->{status}->{id},
            resolution => $_->{resolution},
            link => $_->{link},
        );
    }
;
1;
