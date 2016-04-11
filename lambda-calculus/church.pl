#!/usr/bin/env perl

use strict;
use warnings;
use v5.014;


# 
# Utility functions
sub cprint {
  my $n = shift;

  $n->(sub { $_[0] + 1 })->(0);
}

sub cprintBool {
  my $b = shift;

  return $b->(1)->(0);
}

sub repeat {
  my ($n, $f, $x) = @_;

  return $x if $n == 0;

  $f->(repeat($n-1, $f, $x));
}

#
# Church numerals
sub c {
  my $n = shift;

  sub { my $f = shift;
    sub { my $x = shift;

      repeat($n, $f, $x);
    }
  }
}

sub cSucc {
  my $n = shift;

  sub { my $f = shift;
    sub { my $x = shift;

      $f->($n->($f)->($x));
    }
  }
}

sub cPlus {
  my $n = shift;

  sub { my $m = shift;
    sub { my $f = shift;
      sub { my $x = shift;

        ($m->($f))->(($n->($f))->($x));
      }
    }
  }
}

sub cMult {
  my $n = shift;

  sub { my $m = shift;
    sub { my $f = shift;
      sub { my $x = shift;

        ($m->($n->($f)))->($x);
      }
    }
  }
}

sub cExp {
  my $n = shift;

  sub { my $m = shift;
    sub { my $f = shift;
      sub { my $x = shift;

        (($n->($m))->($f))->($x);
      }
    }
  }
}

sub cHyp {
  my $n = shift;

  sub { my $m = shift;
    sub { my $f = shift;
      sub { my $x = shift;

        (($n->(cExp($m)))->($m))->($f)->($x);
      }
    }
  }
}

#
# Boolean functions
sub cTrue {
  my $x = shift;

  sub { my $y = shift;
    $x;
  }
}

sub cFalse {
  my $x = shift;

  sub { my $y = shift;
    $y;
  }
}

sub cIf {
  my $x = shift;
  return $x;
}

sub cIsZero {
  my $n = shift;

  $n->(sub { my $x = shift; \&cFalse })->(\&cTrue);
}

sub cEven {
  my $n = shift;

  $n->(\&cNeg)->(\&cTrue);
}

sub cNeg {
  my $p = shift;

  $p->(\&cFalse)->(\&cTrue);
}

sub cAnd {
  my $p = shift;

  sub { my $q = shift;

    $p->($q)->(\&cFalse);
  }
}

sub cOr {
  my $p = shift;

  sub { my $q = shift;

    $p->(\&cTrue)->($q);
  }
}

#
# Pairs
sub cPair {
  my $x = shift;

  sub { my $y = shift;
    sub { my $z = shift;
      $z->($x)->($y);
    }
  }
}

sub cLeft {
  my $t = shift;

  $t->(\&cTrue);
}

sub cRight {
  my $t = shift;

  $t->(\&cFalse);
}

sub cPred {
  my $n = shift;

  cRight(
    $n->(sub { my $z = shift;
      cPair(cSucc(cLeft($z)))->(cLeft($z));
    })
    ->(cPair(c(0))->(c(0)))
  );
}

sub cFact {
  my $n = shift;

  cRight(
    $n->(sub { my $z = shift;
      cPair(cSucc(cLeft($z)))->(cMult(cSucc(cLeft($z)))->(cRight($z)));
    })
    ->(cPair(c(0))->(c(1)))
  );
}

#
# Y-combinators
sub Y { # AR
  my $F = shift;
  my $wF = sub { my $x = shift; 
    $F->($x->($x)); 
  };

  $wF->($wF);
}

sub Fact { # AR
  my $f = shift;

  sub { my $n = shift;
    cIsZero($n)
      ->(c(1))
      ->(cMult($n)->($f->(cPred($n))));
  }
}

sub Y2 { # NR
  my $F = shift;
  my $wF = sub { my $x = shift;
    $F->(sub { my $y = shift;
        $x->($x)->($y);
    });
  };

  $wF->($wF);
}

sub Fact2 { # NR
  my $f = shift;

  sub { my $n = shift;
    cIsZero($n)
      ->(c(1))
      ->(sub { my $y = shift;
          cMult($n)->($f->(cPred($n)))->($y);
      });
  }
}

#
# Tests
say "\nA single num:";
say cprint(c(2));
say "\nPlus:";
say cprint(cPlus(c(2))->(c(4)));
say "\nMult:";
say cprint(cMult(c(2))->(c(4)));
say "\nExp:";
say cprint(cExp(c(2))->(c(4)));
# say "\nHyp:";
# say cprint(cHyp(c(4))->(c(2)));

# Bools
say "\nSimple bools:";
say cprint(cTrue(c(5))->(c(8)));
say cprint(cFalse(c(5))->(c(8)));

say "\nIsZero:";
say cprint(cIsZero(c(0))->(c(5))->(c(8)));
say cprint(cIsZero(c(10))->(c(5))->(c(8)));

say "\nNeg:";
say cprint(cNeg(cIsZero(c(0)))->(c(5))->(c(8)));
say cprintBool(cNeg(\&cTrue));
say cprintBool(cNeg(\&cFalse));

say "\nAnd/Or:";
say cprintBool(cAnd(\&cTrue)->(\&cFalse));
say cprintBool(cOr(\&cTrue)->(\&cFalse));
say cprintBool(cOr(\&cFalse)->(\&cFalse));

say "\nEven:";
say cprintBool(cEven(c(8)));
say cprintBool(cEven(c(11)));

say "\nPairs:";
say cprint(cLeft(cPair(c(4))->(\&cTrue)));
say cprintBool(cRight(cPair(c(4))->(\&cTrue)));

say "\nPredecessor:";
say cprint(cPred(c(10)));

say "\nFactorial:";
say cprint(cFact(c(5)));

say "\nFact w/ Y-comb:";
say cprint(Y2(\&Fact2)->(c(5)));
