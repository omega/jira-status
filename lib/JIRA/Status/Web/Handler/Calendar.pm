package JIRA::Status::Web::Handler::Calendar;
use base qw(JIRA::Status::Web::Handler);

use DateTime;

sub get {
    my $self = shift;
    # 201003 for instance (which is march 2010)
    my $now = DateTime->now();
    my ($y, $m) = ( ($self->request->parameters->get('month') || $now->strftime('%Y%m')) =~ m/(\d{4})(\d{2})/ );
    
    my $date = DateTime->new({ month => $m, year => $y});
    
    my $issues = $self->model->get_active_releases_by_month($date);
    
    my $args = {
        issues => $issues,
        statuses => $self->model->get_status_list,
        date => $date,
        prev => $date->clone->subtract(months => 1),
        next => $date->clone->add(months => 1),
        today => $now,
    };
    $self->render('cal.tt', $args);
}


1;