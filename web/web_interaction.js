
document.addEventListener('DOMContentLoaded', function() {
    document.addEventListener('contextmenu', function(e) {
        // Disable context menu on all input and textarea elements
        if (e.target.tagName === 'INPUT' || e.target.tagName === 'TEXTAREA') {
            e.preventDefault();
        }
    });

    document.addEventListener('cut', function(e) {
        // Disable cut on all input and textarea elements
        if (e.target.tagName === 'INPUT' || e.target.tagName === 'TEXTAREA') {
            e.preventDefault();
        }
    });

    document.addEventListener('copy', function(e) {
        // Disable copy on all input and textarea elements
        if (e.target.tagName === 'INPUT' || e.target.tagName === 'TEXTAREA') {
            e.preventDefault();
        }
    });

    document.addEventListener('paste', function(e) {
        // Disable paste on all input and textarea elements
        if (e.target.tagName === 'INPUT' || e.target.tagName === 'TEXTAREA') {
            e.preventDefault();
        }
    });
});