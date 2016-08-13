/*
 * Vector
 */
var Vector = function (x, y) {
  this.x = x
  this.y = y
}

Vector.prototype.plus = function (other) {
  return new Vector(this.x + other.x, this.y + other.y)
}


/*
 * Grid
 */
var Grid = function (width, height) {
  this.space = new Array(width * height)
  this.width = width
  this.height = height
}

Grid.prototype.isInside = function (vector) {
  return vector.x >= 0 && vector.x < this.width &&
         vector.y >= 0 && vector.y < this.height
}

Grid.prototype.get = function (vector) {
  return this.space[vector.x + vector.y * this.width]
}

Grid.prototype.set = function (vector, val) {
  this.space[vector.x + vector.y * this.width] = val
}

Grid.prototype.forEach = function (f, ctx) {
  for (var y = 0; y < this.height; y++) {
    for (var x = 0; x < this.width; x++) {
      var val = this.space[x + y * this.width]
      if (val !== null) {
        f.call(ctx, val, new Vector(x, y))
      }
    }
  }
}


/*
 * Critter
 */
var randomElement = function (arr) {
  return arr[Math.floor(Math.random() * arr.length)]
}

var directions = {
  'n':  new Vector( 0, -1),
  'ne': new Vector( 1, -1),
  'e':  new Vector( 1,  0),
  'se': new Vector( 1,  1),
  's':  new Vector( 0,  1),
  'sw': new Vector(-1,  1),
  'w':  new Vector(-1,  0),
  'nw': new Vector(-1, -1)
}

var directionNames = 'n ne e se s sw w nw'.split(' ')

var BouncingCritter = function () {
  this.direction = randomElement(directionNames)
}

BouncingCritter.prototype.act = function (view) {
  if (view.look(this.direction) !== ' ') {
    this.direction = view.find(' ') || 's'
  }
  return { type: 'move', direction: this.direction }
}

/*
 * Wall Following Critter
 */
var dirPlus = function (dir, n) {
  var idx = directionNames.indexOf(dir)
  return directionNames[(idx + n + 8) % 8]
}

var WallFollowingCritter = function () {
  this.dir = 's'
}

WallFollowingCritter.prototype.act = function (view) {
  var start = this.dir
  if (view.look(dirPlus(this.dir, -3)) !== ' ') {
    start = dirPlus(this.dir, -2)
  }
  while (view.look(this.dir) !== ' ') {
    this.dir = dirPlus(this.dir, 1)
    if (this.dir === start) break
  }
  return { type: 'move', direction: this.dir }
}


/*
 * World
 */
var elementFromChar = function (legend, ch) {
  if (ch === ' ') return null

  var elem = new legend[ch]()
  elem.originChar = ch
  return elem
}

var charFromElement = function (elem) {
  if (elem === null) return ' '
  else return elem.originChar
}

var World = function (map, legend) {
  var grid = new Grid(map[0].length, map.length)
  this.grid = grid
  this.legend = legend

  map.forEach(function (line, y) {
    for (var x = 0; x < line.length; x++) {
      grid.set(new Vector(x, y), elementFromChar(legend, line[x]))
    }
  })
}

World.prototype.toString = function () {
  var out = '';
  for (var y = 0; y < this.grid.height; y++) {
    for (var x = 0; x < this.grid.width; x++) {
      var elem = this.grid.get(new Vector(x, y))
      out += charFromElement(elem)
    }
    out += '\n'
  }
  return out
}

World.prototype.turn = function () {
  var acted = []
  this.grid.forEach(function (val, vect) {
    if (val.act && acted.indexOf(val) === -1) {
      acted.push(val)
      this.letAct(val, vect)
    }
  }, this)
}

World.prototype.letAct = function (critter, vector) {
  var action = critter.act(new View(this, vector))
  if (action && action.type === 'move') {
    var dest = this.checkDestination(action, vector)
    if (dest && this.grid.get(dest) === null) {
      this.grid.set(vector, null)
      this.grid.set(dest, critter)
    }
  }
}

World.prototype.checkDestination = function (action, vector) {
  if (directions.hasOwnProperty(action.direction)) {
    var dest = vector.plus(directions[action.direction])
    if (this.grid.isInside(dest)) {
      return dest
    }
  }
}

var Wall = function () {}


/*
 * View
 */
var View = function (world, vector) {
  this.world = world
  this.vector = vector
}

View.prototype.look = function (dir) {
  var target = this.vector.plus(directions[dir])
  if (this.world.grid.isInside(target)) {
    return charFromElement(this.world.grid.get(target))
  } else {
    return '#'
  }
}

View.prototype.findAll = function (ch) {
  var found = []
  for (var dir in directions) {
    if (this.look(dir) === ch) {
      found.push(dir)
    }
  }
  return found
}

View.prototype.find = function (ch) {
  var found = this.findAll(ch)
  if (found.length === 0) return null
  return randomElement(found)
}


/*
 * plan
 */
var plan = ['############################',
            '#      #    #      o      ##',
            '#           ~          ~   #',
            '#          #####           #',
            '##     ~   #   #    ##     #',
            '###           ##     #     #',
            '#           ###      #     #',
            '#   ####               ~   #',
            '#   ##  ~    o             #',
            '# o  #         o       ### #',
            '#    #                     #',
            '############################'];

var wallFollowingPlan = ['############',
                         '#     #    #',
                         '#   ~    ~ #',
                         '#  ##      #',
                         '#  ##  o####',
                         '#          #',
                         '############']

var world = new World(plan, {
  '#': Wall,
  '~': WallFollowingCritter,
  'o': BouncingCritter
})

setInterval(function () {
  document.getElementById('scene').innerHTML = world.toString()
  world.turn()
}, 100)
