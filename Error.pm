# Error.pm
#
# Copyright (c) 1997 Graham Barr <gbarr@ti.com>. All rights reserved.
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.

package Error;

use Carp;
use strict;
use overload
	'""' => \&stringify,
	'0+' => sub { shift->{"num"} },
	fallback => 1;

use vars qw($VERSION);

$VERSION = "0.02";

$Error::Depth = 0;
$Error::Debug = 0;

sub new {
    my($pkg,$num,$str,$prev) = @_;

    my $i = $Error::Depth;
    my(@caller,@a);

    push(@caller, [ @a ])
	while (@a = caller($i++) );

    my $err = bless {
	"num"	 => 0 + $num,
	"str"	 => "$str",
	"caller" => \@caller
    }, $pkg;

    $err->{"prev"} = $prev
	if defined $prev;

    if($Error::Debug) {
	local $Carp::CarpLevel = $Error::Depth;
	$err->{"backtrace"} = Carp::longmess($str);
    }

    $err;
}

sub stringify {
    my $err = shift;
    my $str = $err->{"str"};

    $str .= ", " . $err->{"prev"}->stringify
	if(exists $err->{"prev"});

    $str;
}

sub previous {
    my $err = shift;
    $err->{"prev"} || undef;
}

sub root {
    my $err = shift;
    $err = $err->{"prev"}
	while defined $err->{"prev"};
    $err;
}

sub backtrace {
    my $err = shift;

    carp "Set \$Error::Debug to 1 to enable backtrace"
	unless defined $err->{backtrace};

    $err->{"backtrace"} || "";
}

sub caller {
    my $err = shift;
    my $i = shift || 0;

    return defined $err->{"caller"}[$i]
	? @{$err->{"caller"}[$i]}
	: ();
}

package Error::Source;

use Carp;

my %error;

sub createError {
    my $self = shift; # ignored;

    new Error @_;
}

sub setError {
    my $self = shift;
    my $error = shift;

    my $pkg = caller($Error::Depth);

    if(ref($self)) {
	if($self->isa('HASH')) {
	    $self->{'__Error__'} = $error;
	}
	elsif($self->isa('GLOB')) {
	    ${*$self}{'__Error__'} = $error;
        }
	$self = ref($self);
    }

    $@ = $error{$self} = $error{$pkg} = $error;

    return;
}

sub getError {
    my $self = shift;

    if(ref($self)) {
	if($self->isa('HASH')) {
	    return defined $self->{'__Error__'}
		? $self->{'__Error__'}
		: undef;
	}
	elsif($self->isa('GLOB')) {
	    return defined ${*$self}{'__Error__'}
		? ${*$self}{'__Error__'}
		: undef;
	}

	$self = ref($self);
    }

    return defined $error{$self}
	? $error{$self}
	: undef;
}

sub Error {
    my $self = shift;

    return $self->getError
	unless @_;

    local $Error::Depth = $Error::Depth + 2;

    my $err = $self->createError(@_);

    $Error::Depth--;

    $self->setError($err);
}

sub carpError {
    my $self = shift;
    local $Error::Depth = $Error::Depth + 1;

    $self->Error(@_);
    carp $@
	if $^W && @_;

    return;
}

1;

=head1 NAME

Error - An error object package

=head1 SYNOPSIS

    use Error;

    package MyPackage;

    @ISA = qw(Error::Methods);

    sub new {
	...
	...
	$obj = some_function() or
	    return MyPackage->Error(100,"Construction failed");
    }

=head1 DESCRIPTION

The C<Error> package provides an object which can be used to pass details
about errors back to the user, without actually having to return the
error object.

The use of C<Error> also defines a second package C<Error::Methods>. This
package defines methods, that can be inherited by other object packages, to
ease the creation of C<Error> objects.

There are three ways in which an previous error can be obtained.

=over 4

=item $obj->Error

Calling the Error method on an object with no arguments will return the
last error that was raised on that object.

=item Package->Error

Calling Error as a method on a package will return the last error
raised on an object blessed into that package,or rasied by a method
within that package.

=item $@

C<$@> will contain the last error raised by the Error package providing
no other event has happened to cause perl to overwrite C<$@>.

=back

=head1 EXAMPLES

    my $obj = new SomeObject or
	die SomeObject->Error;

=head1 CONSTRUCTOR

=head1 AUTHOR

Graham Barr <gbarr@ti.com>

=head1 COPYRIGHT

Copyright (c) 1997 Graham Barr. All rights reserved.
This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
