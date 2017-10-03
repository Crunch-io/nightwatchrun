module.exports = {
  'Demo test Google' : function (client) {
    client
      .url(client.launchUrl)
      .waitForElementVisible('body', 1000)
      .assert.title('Crunch')
      .pause(1000)
      .assert.containsText('div.intro-message h3',
        'A modern platform')
      .assert.containsText('div.intro-message h3 + h3', 
        'for analytics')
      .end();
  }
};
