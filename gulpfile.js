var elixir = require('laravel-elixir');

/*
 |----------------------------------------------------------------
 | Have a Drink!
 |----------------------------------------------------------------
 |
 | Elixir provides a clean, fluent API for defining some basic
 | Gulp tasks for your Laravel application. Elixir supports
 | several common CSS, JavaScript and even testing tools!
 |
 */

elixir(function(mix) {
    mix
        .less("application.less")
        .styles(["css/application.css"])
        .coffee()
        .scripts([
            "../components/jquery/dist/jquery.min.js",
            "../components/underscore/underscore-min.js",
            "../components/backbone/backbone.js",
            "../components/lawnchair/src/Lawnchair.js",
            "../components/lawnchair/src/adapters/dom.js",
            "../components/lawnchair/src/adapters/indexed-db.js",
            "../components/lawnchair/src/adapters/webkit-sqlite.js",
            "../components/backbone-lawnchair/backbone.lawnchair.js",
            "../components/numeral/min/numeral.min.js",
            "../components/notifyjs/dist/notify-combined.min.js",
            "../components/lil-uuid/uuid.min.js",
            "js/application.js"
        ])
        .version(["css/all.css", "js/all.js"])
        .routes()
        .events()
        .phpUnit();
});
