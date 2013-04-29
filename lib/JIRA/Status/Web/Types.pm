package JIRA::Status::Web::Types;
use Template;
use JIRA::Client;
use MooseX::Types
    -declare => [qw/
        TemplateToolkit
        JIRAClient JIRAClientIssue
        EventSource ArrayOfEventSources
        Event ArrayOfEvents
        Db
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
class_type EventSource, { class => 'JIRA::Status::Data::Events::EventSource' };
subtype ArrayOfEventSources, as ArrayRef[EventSource];

coerce EventSource,
    from HashRef,
    via {
        JIRA::Status::Data::Events::EventSource->instance(%$_);
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
class_type Event, { class => 'JIRA::Status::Data::Events::Event' };
subtype ArrayOfEvents, as ArrayRef[Event];


class_type Db, { class => 'JIRA::Status::Data::Db' };
coerce Db,
    from HashRef,
    via {
        Class::MOP::load_class('JIRA::Status::Data::Db');
        JIRA::Status::Data::Db->new($_);
    }
;
1;
