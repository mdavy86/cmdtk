use Mojo::Base -strict;
use Test::More;
use Test::Applify;

my $t = new_ok('Test::Applify', ['./scripts/table']);

$t->help_ok
  ->documentation_ok
  ->is_option('cumulative')
  ->is_option('delimiter')
  ->is_option('id-column')
  ->is_option('read-head');

my $app = $t->app_instance;
is $app->delimiter, "\t", 'default is tab';
is $app->id_column, 0, 'default is 1';
is $app->read_head, 1, 'default to read head';

$app = $t->app_instance(qw{-delimiter}, ' ');
is $app->delimiter, ' ', 'space understood';

$app = $t->app_instance(qw{-delimiter}, ' +');
is $app->delimiter, ' +', 'wildcards ok';

$app = $t->app_instance(qw{-delimiter}, ' *');
is $app->delimiter, ' *', 'wildcards ok';

$app = $t->app_instance(qw{-id-column}, '1,2');
is $app->id_column, '1,2', 'correct';
is_deeply $app->slice, [1, 2], 'correct';

$app = $t->app_instance(qw{-id-column}, '2');
is $app->id_column, '2', 'correct';
is_deeply $app->slice, [2], 'correct';

$app = $t->app_instance(qw{-no-read-head});
is $app->read_head, 0, 'off';

open(my $oldin, "<&", \*STDIN) or die "Can't duplicate STDIN: $!";
open(STDIN, '<&', \*DATA)      or die "Can't duplicate DATA: $!";

my $pos = tell \*DATA;
sub table_ok {
  my $t = shift;
  my $tests = { @_ };
  my @test_names = keys %$tests;
  my $success = 0;
  foreach my $name (@test_names) {
    my ($args, $test_func) = @{$tests->{$name}}{qw{args test}};
    my $app = $t->app_instance(@$args);
    seek \*DATA, $pos, 0;
    my ($e, $so, $se, $r) = $t->run_instance_ok($app);
    subtest $name => sub {
      $success += $test_func->($app, $e, $so, $se, $r);
    };
  }
  is $success, @test_names, 'all subtests successful';
  return 0;
}

table_ok $t,
  cumulative => {
    args => [qw{-id-column 2 -cumulative}],
    test => sub {
      my ($app, $e, $so, $se, $r) = @_;
      is $so, <<EOF, 'table printed';
+------+-----------+------------+
| NAME | frequency | cumulative |
+------+-----------+------------+
| Jane | 3         | 3          |
| Sam  | 2         | 5          |
| John | 1         | 6          |
+------+-----------+------------+
EOF
    },
  },
  frequency => {
    args => [qw{-id-column 2}],
    test => sub {
      my ($app, $e, $so, $se, $r) = @_;
      is $so, <<EOF, 'table printed';
+------+-----------+
| NAME | frequency |
+------+-----------+
| Jane | 3         |
| Sam  | 2         |
| John | 1         |
+------+-----------+
EOF
    },
  },
  noheader => {
    args => [qw{-no-read-head -id-column 1}],
    test => sub {
      my ($app, $e, $so, $se, $r) = @_;
      is $so, <<EOF, 'table';
+--------+---+
| data   | 1 |
| fifth  | 1 |
| first  | 1 |
| fourth | 1 |
| second | 1 |
| sixth  | 1 |
| third  | 1 |
+--------+---+
EOF
    },
  }
;



done_testing;

__DATA__
id	data	NAME
1	first	John
2	second	Jane
3	third	Jane
4	fourth	Jane
5	fifth	Sam
6	sixth	Sam
