# RuBing

A simple Ruby interface for Microsoft Bing

## Usage

    require 'rubing'
    RuBing::Search::app_id = 'YOURAPPID'
    response = RuBing::Search.get('kittens')
    => #<RuBing::Response:0x4e05c ...>
    response.results[0].url
    => "http://en.wikipedia.org/wiki/Kitten"

You need a Bing app ID in order to use the interface. You can get one at [http://www.bing.com/developers/createapp.aspx](http://www.bing.com/developers/createapp.aspx)

Enjoy!
