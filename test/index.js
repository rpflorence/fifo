var page = require('webpage').create()
var complete = false

page.onConsoleMessage = function (msg) {
    console.log(msg)
    if (-1 !== msg.indexOf('RESULT')) {
        var exit = 0
        if (-1 !== msg.indexOf('not ok')) {
            exit = 1
        }
        phantom.exit(exit)  
    }
}
page.open('test/test.html', function (status) {
    
    if (status !== 'success') {
        console.log('FAIL to load test file')
        phantom.exit(1)
    }
})
