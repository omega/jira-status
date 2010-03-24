package JIRA::Status::Web::Types;
use Template;
use JIRA::Client;
use MooseX::Types
    -declare => [qw/
        TemplateToolkit
        JIRAClient
        JIRAModel
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


class_type JIRAModel, { class => 'JIRA::Status::Web::Model::JIRA' };
coerce JIRAModel,
    from HashRef,
    via { Class::MOP::load_class('JIRA::Status::Web::Model::JIRA'); JIRA::Status::Web::Model::JIRA->new(%$_) }
;
1;
