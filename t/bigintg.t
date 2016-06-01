#!/usr/bin/perl -w

use strict;
use Test;

BEGIN 
  {
  $| = 1;
  chdir 't' if -d 't';
  unshift @INC, '../lib'; # for running manually
  plan tests => 65;
  }

# testing of Math::BigInt::GMP, primarily for interface/api and not for the
# math functionality

use Math::BigInt::GMP;

my $C = 'Math::BigInt::GMP';	# pass classname to sub's

my ($x,$y,$r,$z);

# _new and _str
$x = $C->_new(\"123"); $y = $C->_new(\"321");
ok (ref($x),'Math::GMP'); ok (${$C->_str($x)},123); ok (${$C->_str($y)},321);

# _add, _sub, _mul, _div
ok (${$C->_str($C->_add($x,$y))},444);
ok (${$C->_str($C->_sub($x,$y))},123);
print "mul\n";
ok (${$C->_str($C->_mul($x,$y))},39483);
ok (${$C->_str($C->_div($x,$y))},123);

print "x ok\n";
ok (${$C->_str($C->_mul($x,$y))},39483);
print "xy ok\n";
ok (${$C->_str($x)},39483);
ok (${$C->_str($y)},321);
$z = $C->_new(\"2");
ok (${$C->_str($C->_add($x,$z))},39485);
my ($re,$rr) = $C->_div($x,$y);

ok (${$C->_str($re)},123); ok (${$C->_str($rr)},2);

# _mod, _div in list context
$x = $C->_new(\"124"); $y = $C->_new(\"3");
ok (${$C->_str($C->_mod($x,$y))},1);

$x = $C->_new(\"124"); ($z,$r) = $C->_div($x,$y);
ok (${$C->_str($z)},41);
ok (${$C->_str($r)},1);

# is_zero, _is_one, _one, _zero
ok ($C->_is_zero($x),0);
ok ($C->_is_one($x),0);

ok ($C->_is_one($C->_one()),1); ok ($C->_is_one($C->_zero()),0);
ok ($C->_is_zero($C->_zero()),1); ok ($C->_is_zero($C->_one()),0);

# is_odd, is_even
ok ($C->_is_odd($C->_one()),1); ok ($C->_is_odd($C->_zero()),0);
ok ($C->_is_even($C->_one()),0); ok ($C->_is_even($C->_zero()),1);

# _digit
$x = $C->_new(\"123456789");
ok ($C->_digit($x,0),9);
ok ($C->_digit($x,1),8);
ok ($C->_digit($x,2),7);
ok ($C->_digit($x,-1),1);
ok ($C->_digit($x,-2),2);
ok ($C->_digit($x,-3),3);

# _acmp
$x = $C->_new(\"123456789");
$y = $C->_new(\"987654321");
ok ($C->_acmp($x,$y),-1);
ok ($C->_acmp($y,$x),1);
ok ($C->_acmp($x,$x),0);
ok ($C->_acmp($y,$y),0);

# _div
$x = $C->_new(\"3333"); $y = $C->_new(\"1111");
ok (${$C->_str( scalar $C->_div($x,$y))},3);
$x = $C->_new(\"33333"); $y = $C->_new(\"1111"); ($x,$y) = $C->_div($x,$y);
ok (${$C->_str($x)},30); ok (${$C->_str($y)},3);
$x = $C->_new(\"123"); $y = $C->_new(\"1111"); 
($x,$y) = $C->_div($x,$y); ok (${$C->_str($x)},0); ok (${$C->_str($y)},123);

# _and, _xor, _or
$x = $C->_new(\"7"); $y = $C->_new(\"5"); ok (${$C->_str($C->_and($x,$y))},5);
$x = $C->_new(\"6"); $y = $C->_new(\"1"); ok (${$C->_str($C->_or($x,$y))},7);
$x = $C->_new(\"9"); $y = $C->_new(\"6"); ok (${$C->_str($C->_xor($x,$y))},15);

# _dec, _inc
$x = $C->_new(\"7"); ok (${$C->_str($C->_inc($x))},8);
$x = $C->_new(\"7"); ok (${$C->_str($C->_dec($x))},6);

# to check bit-counts
foreach (qw/
  7:7:823543 
  31:7:27512614111 
  2:10:1024
  32:4:1048576
  64:8:281474976710656
  128:16:5192296858534827628530496329220096
  255:32:102161150204658159326162171757797299165741800222807601117528975009918212890625
  1024:64:4562440617622195218641171605700291324893228507248559930579192517899275167208677386505912811317371399778642309573594407310688704721375437998252661319722214188251994674360264950082874192246603776 /)
  {
  my ($x,$y,$r) = split /:/;
  $x = $C->_new(\$x); $y = $C->_new(\$y);
  ok (${$C->_str($C->_pow($x,$y))},$r);
  }

# _num
$x = $C->_new(\"12345"); $x = $C->_num($x); ok (ref($x)||'',''); ok ($x,12345);

# _copy
$x = $C->_new(\"123"); $y = $C->_copy($x); $z = $C->_new(\"321");
$C->_add($x,$z);
ok (${$C->_str($x)},'444');
ok (${$C->_str($y)},'123');

# _gcd
$x = $C->_new(\"128"); $y = $C->_new(\'96'); $x = $C->_gcd($x,$y);
ok (${$C->_str($x)},'32');

# _fac
$x = $C->_new(\"1"); $x = $C->_fac($x,$y); ok (${$C->_str($x)},'1');
$x = $C->_new(\"2"); $x = $C->_fac($x,$y); ok (${$C->_str($x)},'2');
$x = $C->_new(\"3"); $x = $C->_fac($x,$y); ok (${$C->_str($x)},'6');
$x = $C->_new(\"4"); $x = $C->_fac($x,$y); ok (${$C->_str($x)},'24');

# should not happen:
# $x = $C->_new(\"-2"); $y = $C->_new(\"4"); ok ($C->_acmp($x,$y),-1);

# _check
$x = $C->_new(\"123456789");
ok ($C->_check($x),0);
ok ($C->_check(123),'123 is not a reference to Math::GMP');

# done

1;

