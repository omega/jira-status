package JIRA::Status::Web::Handler::Calendar;
use Moose;
extends 'JIRA::Status::Web::Handler';

use DateTime;


sub get {
    my $self = shift;
    $self->render('cal.tt', $self->get_args);
}


sub get_args {
    my $self = shift;
    my $now = DateTime->now( time_zone => 'Europe/Oslo');
    # 201003 for instance (which is march 2010)
    my ($y, $m) = ( ($self->request->parameters->get('month') || $now->strftime('%Y%m')) =~ m/(\d{4})(\d{2})/ );
    
    my $date = DateTime->new({ month => $m, year => $y});
    
    my $events = $self->model->get_events_by_month();
    
    {
        events => $events,
        date => $date,
        prev => $date->clone->subtract(months => 1),
        next => $date->clone->add(months => 1),
        today => $now,
    };
    
}

1;