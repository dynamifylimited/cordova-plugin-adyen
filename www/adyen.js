
var exec = require('cordova/exec');

var adyenExport = {};


adyenExport.setOptions =
    function(options, successCallback, failureCallback) {
        if(typeof options === 'object'
            && typeof options.applicationId === 'string'
            && options.applicationId.length > 0) {
            return exec(
                successCallback,
                failureCallback,
                'Adyen',
                'setOptions',
                [options]
            );
        } else {
            if(typeof failureCallback === 'function') {
                failureCallback('options.applicationId should be specified.');
            }
        }
    };

adyenExport.requestCharge =
    function(options, successCallback, failureCallback) {
        return exec(
            successCallback,
            failureCallback,
            'Adyen',
            'requestCharge',
            [ options ]
        );
    };


module.exports = adyenExport;
