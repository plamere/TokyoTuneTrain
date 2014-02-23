
var canvasWidth = 1000;
var canvasHeight = 1000;
var pathToSpaceRatio = .2;

var rows = 0;
var cols = 0;
var paddingX = 2;
var paddingY = 2;
var bWidth = 0;
var bHeight = 0;
var grid = null;
var mixUpChance = .0;
var curDir = null;

function initRace(qlist) {
    var targetBlockCount = qlist.length / pathToSpaceRatio;
    rows = Math.ceil(Math.sqrt(targetBlockCount));
    cols = Math.ceil(Math.sqrt(targetBlockCount));
    bWidth = Math.floor(canvasWidth / rows) - paddingX;
    bHeight = Math.floor(canvasHeight / cols) - paddingY;
    initGrid(rows, cols);
    buildMaze(qlist);
}

function initGrid(rows, cols) {
    grid = new Array(cols);
    for (var i = 0; i < grid.length; i++) {
        grid[i] = new Array(rows);
    }

    for (var r = 0; r < rows; r++) {
        for (var c = 0; c < cols; c++) {
            grid[r][c] = null;
        }
    }
}

function showGrid() {
    for (var r = 0; r < rows; r++) {
        var line = "";
        for (var c = 0; c < cols; c++) {
            if (grid[r][c]) {
                line += '*';
            } else {
                line += '.';
            }
        }
        console.log(line)
    }
}

function now() {
    return new Date().getTime();
}

function buildMaze(qlist) {
    var start = newSpot(Math.floor(rows/2), Math.floor(cols/2));
    var q = qlist[0];
    q.spot = start;
    gset(q.spot, q);
    var start = now();
    if (!expandMaze(q)) {
        console.log("can't build the maze");
    }
    console.log("Maze built in ", now() - start, 'ms');
}

function gget(spot) {
    return grid[spot.row][spot.col];
}

function gset(spot, val) {
    grid[spot.row][spot.col] = val;
}

function expandMaze(q) {
    if (q.next) {
        var neighbors = getNeighbors(q);
        for (var i = 0; i < neighbors.length; i++) {
            var cSpot = neighbors[i];
            q.next.spot = cSpot;
            gset(cSpot, q.next);
            if (expandMaze(q.next)) {
                return true;
            } else {
                gset(cSpot, null);
                q.next.spot = null;
            }
        }
        return false;
    } else {
        return true;
    }
}

function newSpot(r,c) {
    return {row:r, col:c};
}

function up(spot) {
    if (spot.row > 1) {
        return newSpot(spot.row -1, spot.col);
    }
    return null;
}

function down(spot) {
    if (spot.row < grid.length - 1) {
        return newSpot(spot.row + 1, spot.col);
    }
    return null;
}

function left(spot) {
    if (spot.col > 1) {
        return newSpot(spot.row, spot.col - 1);
    }
    return null;
}

function right(spot) {
    if (spot.col < grid[0].length - 1) {
        return newSpot(spot.row, spot.col + 1);
    }
    return null;
}

var dirs = [right, up, down, left];

var d1 = [right, down, up, left];
var d2 = [left, down, up, right];
var d3 = [down, right, left, up];
var d4 = [up, right, left, down];

function getNeighbors(q) {
    var neighbors = [];
    for (var i = 0; i < dirs.length; i++) {
        var nspot = dirs[i](q.spot);
        if (nspot && gget(nspot) == null) {
            neighbors.push(nspot);
        }
    }

    if (_.random() < mixUpChance) {
        dirs = _.shuffle(dirs);
    }
    neighbors = _.shuffle(neighbors);
    return neighbors;
}

var hilbert = (function() {
  // From Mike Bostock: http://bl.ocks.org/597287
  // Adapted from Nick Johnson: http://bit.ly/biWkkq
  var pairs = [
    [[0, 3], [1, 0], [3, 1], [2, 0]],
    [[2, 1], [1, 1], [3, 0], [0, 2]],
    [[2, 2], [3, 3], [1, 2], [0, 1]],
    [[0, 0], [3, 2], [1, 3], [2, 3]]
  ];
  // d2xy and rot are from:
  // http://en.wikipedia.org/wiki/Hilbert_curve#Applications_and_mapping_algorithms
  function rot(n, x, y, rx, ry) {
    if (ry === 0) {
      if (rx === 1) {
        x = n - 1 - x;
        y = n - 1 - y;
      }
      return [y, x];
    }
    return [x, y];
  }
  return {
    xy2d: function(x, y, z) {
      var quad = 0,
          pair,
          i = 0;
      while (--z >= 0) {
        pair = pairs[quad][(x & (1 << z) ? 2 : 0) | (y & (1 << z) ? 1 : 0)];
        i = (i << 2) | pair[0];
        quad = pair[1];
      }
      return i;
    },
    d2xy: function(z, t) {
      var n = 1 << z,
          x = 0,
          y = 0;
      for (var s = 1; s < n; s *= 2) {
        var rx = 1 & (t / 2),
            ry = 1 & (t ^ rx);
        var xy = rot(s, x, y, rx, ry);
        x = xy[0] + s * rx;
        y = xy[1] + s * ry;
        t /= 4;
      }
      return [x, y];
    }
  };
})();

function hilbertCurve(level) {
  return d3.range(1 << (level * 2)).map(
    function(i) { return hilbert.d2xy(level, i);
  });
}

