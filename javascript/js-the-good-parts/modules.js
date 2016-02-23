var serial_maker = function () {
  var prefix = '';
  var seq = 0;

  return {
    set_prefix: function (p) {
      prefix = String(p);
    },
    set_seq: function (s) {
      seq = s;
    },
    gensym: function () {
      var result = prefix + seq;
      seq += 1;
      return result;
    }
  };
};

var seqer = serial_maker();
seqer.set_prefix('Q');
seqer.set_seq(1000);
document.writeln(seqer.gensym()); // Q1000
document.writeln(seqer.gensym()); // Q1001
