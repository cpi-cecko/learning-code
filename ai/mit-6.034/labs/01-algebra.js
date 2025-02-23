var simplifyIfPossible = function (term) {
  if (term instanceof Sum || term instanceof Product) {
    return term.simplify()
  } else {
    return term
  }
}

var multiply = function (expr1, expr2) {
  if (expr1 instanceof Sum === false || term instanceof Product === false) {
    expr1 = new Product([expr1])
  }
  if (expr2 instanceof Sum === false || term instanceof Product === false) {
    expr2 = new Product([expr2])
  }
  return doMultiply(expr1, expr2)
}

var doMultiply = function (expr1, expr2) {
  var result
  if (expr1 instanceof Sum && expr2 instanceof Sum) {
    var terms = []
    expr1.terms.forEach((termOne) => {
      expr2.terms.forEach((termTwo) => {
        terms.push(new Product([termOne, termTwo]))
      })
    })
    result = new Sum(terms)
  }
  else if (expr1 instanceof Sum && expr2 instanceof Product) {
    var terms = []
    expr1.terms.forEach((term) => {
      terms.push(new Product([term, expr2]))
    })
    result = new Sum(terms)
  }
  else if (expr1 instanceof Product && expr2 instanceof Sum) {
    var terms = []
    expr2.terms.forEach((term) => {
      terms.push(new Product([term, expr1]))
    })
    result = new Sum(terms)
  }
  else {
    result = new Product([expr1, expr2])
  }

  return result.flatten()
}

function Sum (terms) {
  this.terms = terms
}

Sum.prototype.simplify = function () {
  // Remove unnecessary nesting
  var flatSum = this.flatten()

  // Apply associative law
  if (flatSum.terms.length === 1) {
    return simplifyIfPossible(flatSum.terms[0])
  } else {
    var simplified = new Sum(flatSum.terms.map((term) => simplifyIfPossible(term)))
    return simplified.flatten()
  }
}

Sum.prototype.flatten = function () {
  var terms = []
  this.terms.forEach(function (term) {
    if (term instanceof Sum) {
      terms = terms.concat(term.terms)
    } else {
      terms.push(term)
    }
  })
  return new Sum(terms)
}

function Product (factors) {
  this.factors = factors
}

Product.prototype.simplify = function () {
  var flatProd = this.flatten()
  
  var result = new Product([1])  
  this.factors.forEach(function (factor) {
    result = multiply(result, simplifyIfPossible(factor))
  })

  return result.flatten()
}

Product.prototype.flatten = function () {
  var factors = []
  this.factors.forEach(function (factor) {
    if (factor instanceof Product) {
      factors = factors.concat(factor.factors)
    } else {
      factors.push(factor)
    }
  })
  return new Product(factors)
}


var expr = new Sum([
  1,
  new Sum([2, 3]),
  new Product([new Product([1, 2]), new Product([3, 4])]),
  3,
  new Sum([
    new Product([1, 2])
  ]),
  new Sum([new Sum([1, 2]), new Sum([3, 4])]),
  new Product([3, 4])
])
console.log('before', expr)
expr = expr.simplify()
console.log('after', JSON.stringify(expr))
