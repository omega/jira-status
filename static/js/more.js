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
        placeHolder.load('/bigscreen?nowrap=1', function(response) {
            $(this).empty();
            $(this).html(response);
        });
    }, 10000);
});