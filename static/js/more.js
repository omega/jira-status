$(document).ready(function() {
    $('.more-toggle').click(function() {
        $(this).siblings('.more').toggle();
    });
});

/* Bigscreen stuff */

var placeHolder, timer;

function refreshCal() {
    $.ajax({
        cache: false,
        url: '/bigscreen?nowrap=1', 
        success: function(response, status, req) {
            if (req.status == 200) {
                placeHolder.empty();
                placeHolder.html(response);
                $('#timestamp').removeClass('error');
            } else {
                $('#timestamp').addClass('error');
            }
        },
        error: function(req, status) {
            $('#timestamp').addClass('error');
        }
    });
}
$(document).ready(function() {
    placeHolder = $("#bigscreen");
    if (!placeHolder) {
        return;
    }
    //timer = window.setInterval(refreshCal, 10000);
    
    $('#timestamp').live('click', function() {
        if ($(this).hasClass('stopped')) {
            // We should 
            $(this).removeClass('stopped');
            timer = window.setInterval(refreshCal, 10000);
        } else {
            window.clearInterval(timer);
            $(this).addClass('stopped');
        }
    });
});