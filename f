<!DOCTYPE HTML>
<html>
<head>
<script src="js/raphael-min.js" type="text/javascript" charset="utf-8"></script>
<link href="bootstrap/css/bootstrap.min.css" rel="stylesheet" media="screen">
<link rel="stylesheet" href="styles.css" type="text/css" media="screen">
<script src="js/jquery.min.js"></script>
<script src="js/lodash.min.js" type="text/javascript" charset="utf-9"></script>
<script type="text/javascript" src="jremix.js"></script> 
<title> Tokyo Tune Train</title>
</head>
<body>
<div id="wrap" class="navbar navbar-inverse">
  <div class="navbar-inner">
    <div class="container">
      <a class="btn btn-navbar" data-toggle="collapse" data-target=".nav-collapse">
        <span class="icon-bar"></span>
        <span class="icon-bar"></span>
        <span class="icon-bar"></span>
      </a>
      <a id='show-search' class="brand">Tokyo Tune Train</a>
      <div class="nav-collapse collapse">
        <ul class="nav">
          <li class="active"><a id='show-main'  href="index.html">Main</a></li>
          <li><a id='show-gallery'  href="gallery.html">New Game</a></li>
          <li class="pull-right"><a id='show-about' href="about.html">About</a></li>
        </ul>
      </div>
    </div>
  </div>
</div>

<div id='info-div'>
<span id='info'> </span> 
<span id='tweet-span'> 
    <a href="https://twitter.com/share" id='tweet' class="twitter-share-button" data-lang="en" data-count='none'>Tweet</a>
    <script>!function(d,s,id){var
    js,fjs=d.getElementsByTagName(s)[0];if(!d.getElementById(id)){js=d.createElement(s);js.id=id;js.src="https://platform.twitter.com/widgets.js";fjs.parentNode.insertBefore(js,fjs);}}(document,"script","twitter-wjs");</script>
</span>
</div>

<div id='error'> </div> 
<div id="hero">
    <div id="stats">
        <!--
        <button class="btn btn-small" id='reset'>Reset</button>
        <button class="btn btn-small" id='play'>Play</button>
        <button class="btn btn-small" id='autobot'>Autobot</button>
        -->
        <span id="big-numbers"> 
            <!--Miles: <span class='nval' id='tile'> 1 </span>  -->
            Score: <span class='nval' id='score'>1</span> 
            <span id='message'> </span> 
        </span>
    <div id='tiles'></div>
        <span id='title'> </span> 
        <span id="numbers"> Train Speed (MPH): <span class='nval' id='speed'> 100 </span>
         <span > Headlights: <span class='nval' id='headlights'> high </span> </span>
        </span>
    </div>
</div>
<div id="help" class="hero-unit">
  <div class="container">
        Drive the tune train with arrow keys. Get to the end of the line fastest for highest points.
        <br>
        Controls:
        <ul>
            <li> <b>space</b> - starts the train running
            <li> <b> arrows or w/a/s/d</b> - steer the train
            <li> <b> &lt; &gt; ?</b> - controls the speed of the train
            <li> <b> h </b> - adjusts the headlights
        </ul>
        See 'about' for more info
  </div>
</div>


</body>
<script src="bootstrap/js/bootstrap.min.js"></script>

<script type="text/javascript">

  var _gaq = _gaq || [];
  _gaq.push(['_setAccount', 'UA-3675615-27']);
  _gaq.push(['_trackPageview']);

  (function() {
    var ga = document.createElement('script'); ga.type =
'text/javascript'; ga.async = true;
    ga.src = ('https:' == document.location.protocol ? 'https://ssl' :
'http://www') + '.google-analytics.com/ga.js';
    var s = document.getElementsByTagName('script')[0];
s.parentNode.insertBefore(ga, s);
  })();

</script>

<script type="text/javascript">

var remixer;
var player;
var driver;
var track;

var paper;
var tiles = [];
var tileWidth = 30;
var tileHeight = 20;
var maxHeight = 25;
var maxWidth = 40;
var grid;
var headlampLookahead = 2;
var maxHeadlampLookahead = 3;
var curScore = 0;
var trainColor = "#99ff99";
var pad = 12;
var bgColor ="#126";
var headlampText = [ "Off", "Low Beams", "High beams", "Halogen" ];

var mazes = [
    { name: 'maze 4', size: 993, js:'m4.js' },
    { name: 'maze 5', size: 999, js:'m5.js' },
    { name: 'music hack', size: 903, js:'m6.js' },
    { name: 'music hack', size: 984, js:'m7.js' },
    { name: 'music hack', size: 710, js:'m8.js' },
    { name: 'music hack', size: 863, js:'m9.js' },
    { name: 'music hack', size: 958, js:'m10.js' },
    { name: 'music hack', size: 1000, js:'m11.js' },
    { name: 'music hack', size: 1000, js:'m12.js' },
    { name: 'music hack', size: 1000, js:'m13.js' },
    { name: 'music hack', size: 929, js:'m14.js' },
    { name: 'music hack', size: 828, js:'m15.js' },
];

var minMaze = 1000;

// From Crockford, Douglas (2008-12-17). JavaScript: The Good Parts (Kindle Locations 734-736). Yahoo Press.

if (typeof Object.create !== 'function') { 
    Object.create = function (o) { 
        var F = function () {};
        F.prototype = o; 
        return new F(); 
    }; 
}

function info(s) {
    $("#info").text(s);
}

function error(s) {
    if (s.length == 0) {
        $("#error").hide();
    } else {
        $("#error").text(s);
        $("#error").show();
    }
}

function message(s) {
    if (s.length == 0) {
        $("#message").text("");
        //$("#message").hide();
    } else {
        $("#message").text(s);
        //$("#message").show();
    }
}

function emessage(s) {
    message(s);
    setTimeout(function() {
        console.log('tmo');
        message("");
    }, 2000);
}

function stop() {
    player.stop();
    player = remixer.getPlayer();
}

function extractTitle(url) {
    var lastSlash = url.lastIndexOf('/');
    if (lastSlash >= 0 && lastSlash < url.length - 1) {
        var res =  url.substring(lastSlash + 1, url.length - 4);
        return res;
    } else {
        return url;
    }
}

function getTitle(title, artist, url) {
    if (title == undefined || title.length == 0 || title === '(unknown title)' || title == 'undefined') {
        if (url) {
            title = extractTitle(url);
        } else {
            title = null;
        }
    } else {
        if (artist !== '(unknown artist)') {
            title = title + ' by ' + artist;
        } 
    }
    return title;
}

function loadTrack(trid) {
    fetchAnalysis(trid);
}

function setDisplayMode(playMode) {
    if (playMode) {
        //$("#help").hide();
        $("#hero").show();
        $("#play").show();
        $("#tweet-span").show();
    } else {
        //$("#help").show();
        $("#hero").hide();
        $("#play").hide();
        $("#tweet-span").hide();
    } 
}


function showTrackTitle(t) {
    $("#title").text('Train line: ' + t.title + ' by ' + t.artist);
}


function trackReady(t) {
    t.fixedTitle = getTitle(t.title, t.artist, t.info.url);
    document.title = 'Tokyo Tune Train' + t.fixedTitle;
    // $("#song-title").text(t.fixedTitle);
}

function readyToPlay(t) {
    if (t.status === 'ok') {
        trackReady(t);
        info("");
        setDisplayMode(true);
        normalizeColor();
        createMazePanel();
        showTrackTitle(t);
        tweetSetup(t, 0);
    } else {
        info(t.status);
    }
}

function gotTheAnalysis(profile) {
    var status = get_status(profile);
    if (status == 'complete') {
        info("Loading track ...");
        remixer.remixTrack(profile.response.track, function(state, t, percent) {
            track = t;
            if (state == 1) {
                info("Here we go ...");
                setTimeout( function() { readyToPlay(t); }, 10);
            } else if (state == 0) {
                if (percent >= 99) {
                    info("Here we go ...");
                } else {
                    info( percent  + "% of track loaded ");
                }
            } else {
                info('Trouble  ' + t.status);
            }
        });
    } else if (status == 'error') {
        info("Sorry, couldn't analyze that track");
    }
}


function fetchAnalysis(trid) {
    var url = 'http://static.echonest.com/infinite_jukebox_data/' + trid + '.json';
    info('Fetching the analysis');
    // showPlotPage(trid);
    $.getJSON(url, function(data) { gotTheAnalysis(data); } )
        .error( function() { 
            info("Sorry, can't find info for that track");
        });
}

function get_status(data) {
    if (data.response.status.code == 0) {
        return data.response.track.status;
    } else {
        return 'error';
    }
}



var tilePrototype = {
    normalColor:"#333",

    move: function(x,y)  {
        this.rect.attr( { x:x, y:y});
        this.x = x;
        this.y = y;
    },

    amove: function(x,y, time, delay, easing, callback)  {
        if (time === undefined) {
            time = 500;
        }

        if (delay === undefined) {
            delay = 0;
        }

        if (easing === undefined) {
            easing = 'linear';
        }
        var anim = Raphael.animation({cx: 10, cy: 20}, 800);
        var ranimator = Raphael.animation({ x:x, y: y}, time, easing, callback);

        this.rect.animate(ranimator.delay(delay));
    },

    play:function(force) {
        if (force) {
            this.playStyle();
            player.play(this.q);
        } else {
            this.selectStyle();
        }
    },


    pos: function() {
        return {
            x: this.x,
            y: this.y
        }
    },

    selectStyle: function() {
        this.rect.attr("fill", "#333");
    },

    queueStyle: function() {
        this.rect.attr("fill", "#aFF");
    },

    playStyle: function() {
        this.rect.attr("fill", "#FF9");
    },

    doneStyle: function() {
        this.rect.attr("fill", "#22F");
    },

    normal: function() {
        this.rect.attr("fill", this.normalColor);
    },

    highlight: function() {
        this.rect.attr("fill", "#FFFFFF");
    },

    init:function() {
        var that = this;
    }
}


function getQuantumColor(q) {
    if (isSegment(q)) {
        return getSegmentColor(q);
    } else {
        q = getQuantumSegment(q);
        if (q != null) {
            return getSegmentColor(q);
        } else {
            return "#565";
        }
    }
}

function getQuantumSegment(q) {
    while (! isSegment(q) ) {
        if ('children' in q && q.children.length > 0) {
            q = q.children[0]
        } else {
            break;
        }
    }

    if (isSegment(q)) {
        return q;
    } else {
        return null;
    }
}


function isSegment(q) {
    return 'timbre' in q;
}

function getSegmentColor(seg) {
    return getColor(seg);
}

function drawLine(x1, y1, x2, y2) {
    var line = paper.path( ["M", x1, y1, "L", x2, y2]);
    line.attr('stroke', trainColor);
    return line;
}

function getSection(q) {
    while (q.parent) {
        q = q.parent;
    }
    return q.which;
}

var lineColors = [];

function getLineColor(tile) {
    if (! (tile.section in lineColors)) {
        lineColors[tile.section] = Raphael.getColor(.95);
    }
    return lineColors[tile.section];
}

function createTile(which, q, gridPoint, callback) {
    var tile = Object.create(tilePrototype);
    tile.which = which;
    tile.normalColor = getQuantumColor(q);
    tile.x = gridPoint[0];
    tile.y = gridPoint[1];
    var x = tile.x * tileWidth + pad;
    var y = tile.y * tileHeight + pad;
    //tile.rect = paper.rect(x, y, tileWidth - 1, tileHeight -1);
    tile.rect = paper.rect(0, 0, tileWidth - 1, tileHeight -1);
    tile.rect.attr("stroke", bgColor);
    tile.rect.tile = tile;
    tile.section = getSection(q);
    tile.normal();
    tile.q = q;
    tile.done = false;
    tile.init();
    grid[gridPoint[0]][gridPoint[1]] = tile;
    tile.amove(x, y, 500, which * 2, callback);
    return tile;
}


function pickMaze(len) {
    var smazes = _.shuffle(mazes);
    for (var i = 0; i < smazes.length; i++) {
        if (smazes[i].size >= len) {
            return smazes[i];
        }
    }
    return null;
}

function fetchMaze(maze, callback) {
    $.getJSON(maze.js, callback);
}

function transformMaze(maze) {

}

function createMazePanel() {
    var qlist = track.analysis.tatums;
    if (qlist.length > minMaze) {
        qlist = track.analysis.beats;
        if (qlist.length > minMaze) {
            qlist = track.analysis.bars;
        }
    }
    if (qlist.length > minMaze) {
        error("That song is too long for the Tune Train");
    } else {
        var maze = pickMaze(qlist.length);
        if (maze) {
            fetchMaze(maze, function(mazeData) {
                drawMaze(qlist, mazeData);
            });
        } else {
            error ("Can't find a right-sized maze");
        }
    }
}

function connectTiles(t1, t2) {
    if (t1 && t2 && !t2.line) {
        var sx = t1.rect.getBBox().x + tileWidth/2;
        var sy = t1.rect.getBBox().y + tileHeight/2;
        var ex = t2.rect.getBBox().x + tileWidth/2;
        var ey = t2.rect.getBBox().y + tileHeight/2;
        t2.line = drawLine(sx, sy, ex, ey);
        t2.line.attr('stroke', getLineColor(t2));
        t2.line.attr('stroke-width', 4);
        t2.line.attr('stroke-linejoin', 'miter');
    }
}

function drawMaze(qlist, mazeData) {
    var completer = function() {
        var first = tiles[0];
        var last = tiles[tiles.length - 1];
        first.rect.toFront();
        first.rect.attr('stroke', 'green');
        first.rect.attr('stroke-width', 4);
        first.rect.glow({color:"#f88", width:100, fill:true, opacity:1});
        last.rect.glow({color:"#F88", width:100, fill:true, opacity:1});
        connectAll();
    };

    _.each(qlist, function(q, i) {
        var callback = i == qlist.length - 1 ? completer : null;
        var tile = createTile(i, qlist[i], mazeData[i], callback);
        tiles.push(tile);
    });
    return tiles;
}

function resetMaze() {
    _.each(tiles, function(tile) {
        tile.normal();
        if (tile.line) {
            tile.line.remove();
            tile.line = null;
        }
        tile.done = false;
    });
}

function connectAll() {
    _.each(tiles, function(tile, i) {
        if (i < tiles.length -1) {
            var next = tiles[i + 1];
            connectTiles(tile, next);
        }
    });
}


function normalizeColor() {
    cmin = [100,100,100];
    cmax = [-100,-100,-100];

    var qlist = track.analysis.segments;
    for (var i = 0; i < qlist.length; i++) {
        for (var j = 0; j < 3; j++) {
            var t = qlist[i].timbre[j];

            if (t < cmin[j]) {
                cmin[j] = t;
            }
            if (t > cmax[j]) {
                cmax[j] = t;
            }
        }
    }
}

function getColor(seg) {
    var results = [0,0,0];
    for (var i = 0; i < 3; i++) {
        var t = seg.timbre[i];
        var norm = (t - cmin[i]) / (cmax[i] - cmin[i]);
        results[i] = norm * 100 + 20;
    }
    return to_rgb(results[0], results[1], results[2]);
}

function convert(value) { 
    var integer = Math.round(value);
    var str = Number(integer).toString(16); 
    return str.length == 1 ? "0" + str : str; 
};

function to_rgb(r, g, b) { 
    return "#" + convert(r) + convert(g) + convert(b); 
}


function keydown(evt) {

    console.log('key', evt.which);
    if (evt.which == 39 || evt.which == 68) {  // right arrow
        driver.setDeltaX(1);
        driver.setDeltaY(0);
        evt.preventDefault();
    }

    if (evt.which == 37 || evt.which == 65) {  // left arrow
        driver.setDeltaX(-1);
        driver.setDeltaY(0);
        evt.preventDefault();
    }

    if (evt.which ==38 || evt.which == 87) {  // up arrow
        driver.setDeltaX(0);
        driver.setDeltaY(-1);
        evt.preventDefault();
    }

    if (evt.which == 40  || evt.which == 83 ) {  // down arrow
        driver.setDeltaX(0);
        driver.setDeltaY(1);
        evt.preventDefault();
    }

    if (evt.which ==  84 ) {  // down arrow
        driver.teleport( tiles.length - 20);
    }

    if (evt.which == 72 ) {  // headlamp adjustment
        if (--headlampLookahead < 0) {
            headlampLookahead = maxHeadlampLookahead;
        }
        $("#headlights").text(headlampText[headlampLookahead]);
    }

    if (evt.which == 188  ) {  // . slower
        var factor = player.getSpeedFactor() + .01;
        setSpeedFactor(factor)
        evt.preventDefault();
    }

    if (evt.which == 190  ) {  // , faster
        var factor = player.getSpeedFactor() - .01;
        if (factor < 0) {
            factor = 0;
        }
        setSpeedFactor(factor)
        evt.preventDefault();
    }

    if (evt.which == 191  ) {  // / reset
        setSpeedFactor(1)
        evt.preventDefault();
    }

    if (evt.which == 81  ) {  // q
        driver.toggleAutobot();
        evt.preventDefault();
    }

    if (evt.which == 32) {
        evt.preventDefault();
        if (driver.isRunning()) {
            driver.stop();
        } else {
            driver.start();
        }
    }
}

function urldecode(str) {
   return decodeURIComponent((str+'').replace(/\+/g, '%20'));
}

function getAudioContext() {
    if (window.webkitAudioContext) {
        return new webkitAudioContext();
    } else {
        return new AudioContext();
    }
}

function init() {
    jQuery.ajaxSettings.traditional = true;  
    setDisplayMode(false);

    window.oncontextmenu = function(event) {
        event.preventDefault();
        event.stopPropagation();
        return false;
    };

    document.ondblclick = function DoubleClick(event) {
        event.preventDefault();
        event.stopPropagation();
        return false;
    }

    $("#error").hide();

    $("#play").click(
        function() {
            if (driver.isRunning()) {
                driver.stop();
            } else {
                driver.setAutobot(false);
                driver.start();
            }
        }
    );


    initGrid(maxWidth, maxHeight);
    paper = Raphael("tiles", tileWidth * maxWidth + pad * 2, tileHeight * maxHeight + pad * 2);
    paper.canvas.style.backgroundColor = bgColor;



    $(document).keydown(keydown);


    if (window.webkitAudioContext === undefined && window.AudioContext === undefined) {
        error("Sorry, this app needs advanced web audio. Your browser doesn't"
            + " support it. Try the latest version of Chrome, Firefox (nightly)  or Safari");

        hideAll();

    } else {
        // var context = new webkitAudioContext();
        var context = getAudioContext();
        remixer = createJRemixer(context, $);
        player = remixer.getPlayer();
        driver = Driver(player)
        processParams();
    }
}


function showPlotPage(trid) {
    var url = location.protocol + "//" + 
                location.host + location.pathname + "?trid=" + trid;
    location.href = url;
}

function analyzeAudio(audio, tag, callback) {
    var url = 'http://labs.echonest.com/Uploader/qanalyze?callback=?'
    $.getJSON(url, { url:audio, tag:tag}, function(data) {
        if (data.status === 'done' || data.status === 'error') {
            callback(data);
        } else {
            info(data.status + ' - ready in about ' + data.estimated_wait + ' secs. ');
            setTimeout(function() { analyzeAudio(audio, tag, callback); }, 5000);
        } 
    });
}

function setURL(score) {
    if (track) {
        var p = '?trid=' + track.id;
    }

    history.replaceState({}, document.title, p);
    tweetSetup(track, score);
}

function tweetSetup(t, score) {
    $(".twitter-share-button").remove();
    var tweet = $('<a>')
        .attr('href', "https://twitter.com/share")
        .attr('id', "tweet")
        .attr('class', "twitter-share-button")
        .attr('data-lang', "en")
        .attr('data-count', "none")
        .text('Tweet');

    $("#tweet-span").prepend(tweet);
    if (t) {
        tweet.attr('data-text',  "I scored " + score + " points riding the #TokyoTuneTrain to " + t.fixedTitle);
        tweet.attr('data-url', document.URL);
    } 
    // twitter can be troublesome. If it is not there, don't bother loading it
    if ('twttr' in window) {
        twttr.widgets.load();
    }
}

function setSpeedFactor(factor) {
    player.setSpeedFactor(factor)
    if (factor > 0 ) {
        $("#speed").text(Math.round(100 / factor));
    } else {
        $("#speed").text(Math.round(640));
    }
}

function initGrid(width, height) {
    grid = new Array(width);
    for (var i = 0; i < grid.length; i++) {
        grid[i] = new Array(height);
    }

    for (var x = 0; x < width; x++) {
        for (var y = 0; y < height; y++) {
            grid[x][y] = null;
        }
    }
}

function processParams() {
    var params = {};
    var q = document.URL.split('?')[1];
    if(q != undefined){
        q = q.split('&');
        for(var i = 0; i < q.length; i++){
            var pv = q[i].split('=');
            var p = pv[0];
            var v = pv[1];
            params[p] = v;
        }
    }

    if ('trid' in params) {
        var trid = params['trid'];
        fetchAnalysis(trid);
    } else if ('key' in params) {
        var url = 'http://' + params['bucket'] + '/' + urldecode(params['key']);
        info("analyzing audio");
        $("#select-track").hide();
        analyzeAudio(url, 'tag', 
            function(data) {
                if (data.status === 'done') {
                    showPlotPage(data.trid);
                } else {
                    info("Trouble analyzing that track " + data.message);
                }
            }
        );
    }
    else {
        setDisplayMode(false);
    }
}

function gget(x, y) {
    if (x >= 0 && x < grid.length && y >=0 && y < grid[0].length) {
        return grid[x][y];
    } else {
        return null;
    }
}

function getNextTile(tile) {
    var nindex = tile.q.which + 1;
    if (nindex < tiles.length) {
        return tiles[nindex];
    }
    return null;
}

function getPrevTile(tile) {
    var nindex = tile.q.which - 1;
    if (nindex >= 0) {
        return tiles[nindex];
    }
    return null;
}

function Driver(player) {
    var curTile = null;
    var curOp = null;
    var tileDiv = $("#tile");
    var scoreDiv = $("#score");
    var xDelta = 1;
    var yDelta = 0;
    var autoBot = false;
    var lastCompleteTile = null;
    var score = 0;
    var lastTile = null;
    var consecutive = 0;

    function next() {
        if (curTile == null || curTile == undefined) {
            var tile = tiles[0];
            var ntile = tiles[1];
            xDelta = ntile.x - tile.x;
            yDelta = ntile.y - tile.y;
            return tile;
        } else if (autoBot) {
            var which = curTile.which;
            var next = which + 1;
            if (next >= tiles.length) {
                return null;
            } else if (next < 0) {
                return curTile;
            } else {
                return tiles[next];
            }
        } else {
            var x = curTile.x + xDelta;
            var y = curTile.y + yDelta;
            var nextTile = gget(x,y);
            if (nextTile) {
                return nextTile;
            } else {
                return curTile;
            }
        }
    }


    function stop () {
        curOp = null;
        curTile = null;
        player.stop();
        connectAll();
        $("#play").text("Play");
        setURL(score);
        $("#tweet-span").show();
    }

    function gameOver() {
        console.log('game over');
        var completionBonus = tiles.length * 10;
        score += completionBonus;
        message("Game Over!");
        stop();
    }

    function process() {
        if (curTile !== null && curTile !== undefined) {
            if (curTile.done) {
                curTile.doneStyle();
            } else {
                curTile.normal();
            }
        }

        if (curOp) {
            curTile = curOp();
            var lampSpeedGain = maxHeadlampLookahead - headlampLookahead;
            lampSpeedGain = lampSpeedGain * lampSpeedGain;
            var scoreSpeedGain = 1 / player.getSpeedFactor();
            var scoreGain = scoreSpeedGain * lampSpeedGain;
            if (curTile !== null) {
                var delay = player.play(0, curTile.q);
                setTimeout( function () { process(); }, 1000 * delay);
                curTile.playStyle();
                tileDiv.text(curTile.which);
                if (lastCompleteTile == null && curTile.q.which == 0) {
                    lastCompleteTile = curTile;
                } else if (lastCompleteTile && curTile.q.which == lastCompleteTile.q.which + 1) {
                    lastCompleteTile = curTile;
                    penalty = 0;
                    score += Math.round(curTile.q.duration * 100 * scoreGain);
                    consecutive++;
                    if (consecutive % 20 == 0) {
                        var bonus = consecutive * 100;
                        emessage(bonus + " point good driver bonus!");
                        score += bonus;
                    }
                } else {
                    score -= Math.round(curTile.q.duration * 100 * Math.max(1, scoreGain));
                    consecutive = 0;;
                }
                if (lastCompleteTile) {
                    if (!lastCompleteTile.done) {
                        var which = lastCompleteTile.q.which;
                        var thisTile = lastCompleteTile;
                        var prevTile = getPrevTile(thisTile);
                        connectTiles(prevTile, thisTile);
                        for (var i = 0; i < headlampLookahead; i++) {
                            var nextTile = getNextTile(thisTile);
                            if (nextTile) {
                                connectTiles(thisTile, nextTile);
                                thisTile = nextTile;
                            } else {
                                break;
                            }
                        }
                        lastCompleteTile.done = true;
                        if (lastCompleteTile == lastTile) {
                            gameOver();
                        }
                    }
                }
            } else {
                stop();
            }
        }
        scoreDiv.text(score);
    }

    var interface = {
        start: function() {
            lastTile = tiles[tiles.length - 1];
            xDelta = 1;
            yDelta = 0;
            autoBot = false;
            lastCompleteTile = null;
            score = 0;
            resetMaze();
            lastCompleteTile = null;
            setSpeedFactor(1);
            headlampLookahead = 2;
            consecutive = 0;
            curTile = null;
            curOp = next;
            process();
            $("#play").text("Stop");
            $("#tweet-span").hide();
            setURL(score);
        },

        stop: stop,

        isRunning: function() {
            return curOp !== null;
        },

        setDeltaX: function(delta) {
            xDelta = delta;
        }, 

        setDeltaY: function(delta) {
            yDelta = delta;
        }, 

        toggleAutobot: function() {
            autoBot = !autoBot;
        },

        teleport: function(which) {
            lastCompleteTile = tiles[which - 1];
            curTile = tiles[which - 1];
        }
    }
    return interface;
}


window.onload = init;

function ga_track(page, action, id) {
    _gaq.push(['_trackEvent', page, action, id]);
}
</script>

