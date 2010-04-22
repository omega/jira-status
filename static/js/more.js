$(document).ready(function() {
    $('.more-toggle').click(function() {
        $(this).siblings('.more').toggle();
    });
});

/* Bigscreen stuff */

var placeHolder, refreshValue = 10;

$(document).ready(function() {
    placeHolder = $("#bigscreen");
    if (!placeHolder) {
        return;
    }
    window.setInterval(function() {
        $.get('/bigscreen?nowrap=1', function(response, status, req) {
            if (req.status == 200) {
                placeHolder.empty();
                placeHolder.html(response);
                $('#timestamp').removeClass('error');
            } else {
                $('#timestamp').addClass('error');
            }
        });
    }, 10000);
});