#!/usr/bin/env raku

my @tokens;

sub read_file($filename) {
    my $data = slurp "$filename";
    return $data;
}

sub lex($filecontents) {
    my $tok = "";
    my $state = 0;
    my $string = "";
    my @filecontents = $filecontents.comb;
    for @filecontents -> $char {
        $tok ~= $char;
        if $tok eq " " {
            if $state == 0 {
                $tok = "";
            }
            else {
                $tok = " ";
            }
        }
        elsif $tok eq "\n" {
            $tok = "";
        }
        elsif $tok eq "spurt" {
            @tokens.push: "spurt";
            $tok = "";
        }
        elsif $tok eq "gobble" {
            @tokens.push: "GOBBLE";
            $tok = ""
        }
        elsif $tok eq "\"" {
            if $state == 0 {
                $state = 1;
            }
            elsif $state == 1 {
                @tokens.push: "STRING$string\""; 
                $string = "";
                $state = 0;
                $tok = "";
            }
        }
        elsif $tok eq "'" {
            if $state == 0 {
                $state = 1;
            }
            elsif $state == 1 {
                @tokens.push: "INTEGER$string'"; 
                $string = "";
                $state = 0;
                $tok = "";
            }
        }
        elsif $state == 1 {
            $string ~= $tok;
            $tok = "";
        }
    }
    return @tokens;
}

sub parse(@toks) {
    say @toks;
    while @toks {
        my $token = @toks.shift;
        given $token {
            when $token eq "spurt" {
                if @toks[0] ~~ /^GOBBLE$/ {
                @toks.shift;
                if @toks[0] ~~ /^STRING:(.*)$/ {
                    my $gobble_value = @toks.shift;
                    my $gobble = prompt "{$gobble_value.subst(/^STRING:/, '').trim}: ";

                    say $gobble;
                } elsif @toks[0] ~~ /^INTEGER:(.*)$/ {
                    my $gobble_value = @toks.shift;
                    my $gobble = prompt "{$gobble_value.subst(/^INTEGER:/, '').trim}: ";

                    say $gobble;
                } else {
                    say "Expecting value after 'gobble'";
                }
            }
                elsif @toks[0] ~~ /^STRING:(.*)$/ {
                    my $value = @toks.shift;
                    say $value.subst(/^STRING:/, '').trim;
                }
                elsif @toks[0] ~~ /^INTEGER:(.*)$/ {
                    my $value = @toks.shift;
                    say $value.subst(/^INTEGER:/, '').trim;
                }
                else {
                    say "Expecting value after 'spurt'";
                }                
            }
        }
    }
}

multi sub MAIN(:$RUN!) {
    my $data = read_file($RUN);
    my @toks = lex($data);
    parse(@toks);
}