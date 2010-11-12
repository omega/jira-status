package JIRA::Status::Web::Handler::Bigscreen;
use Moose;

extends 'JIRA::Status::Web::Handler::Calendar';

around 'get_args' => sub {
    my $orig = shift;
    my $self = shift;
    my $orig_args = $self->$orig(@_);

    my $args = {};
    $args->{iframe} = $self->config->{'iframe'};
    foreach (qw(today events)) {
        $args->{$_} = $orig_args->{$_};
    }

    $args->{date} = $orig_args->{date}->subtract({weeks => 2});
    $args->{months} = [];

    push(@{ $args->{months}}, {
        date => $orig_args->{date},
    });

    # Add next_month and next_month+1 as well
    for (1..2) {
        my $date = $orig_args->{date}->clone->add(months => $_);
        push(@{ $args->{months}}, {
            date => $date,
        });

    }
    my $oldest = $args->{today}->clone->subtract({ weeks => 2 });
    #$args->{old_events} = $self->model->get_historical_events($args->{today},$oldest);

    $args->{bigscreen} = 1;
    if ($self->request->parameters->get('nowrap')) {
        $args->{nowrap} = $self->request->parameters->get('nowrap');
    }
    $args;
};

override 'get' => sub {
    my $self = shift;
    $self->render('bigscreen.tt', $self->get_args);
};

1;
