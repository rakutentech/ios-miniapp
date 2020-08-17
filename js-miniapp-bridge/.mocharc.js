'use strict';

module.exports = {
    require: ['ts-node/register', './test/setup'],
    reporter: 'mocha-multi',
    reporterOptions: 'spec=-,xunit=test-results/mocha/results.xml'
};
