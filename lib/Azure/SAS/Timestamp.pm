package Azure::SAS::Timestamp;
use Moo;
use Types::Standard qw(Int Str InstanceOf);
use Time::Piece;
use Regexp::Common 'time';

has time_piece => (
    is  => 'rw',
    isa => InstanceOf['Time::Piece']
);

sub sas_time {
    ## Azure SAS requires time in UTC, but the timestamp must be "Z", not "UTC"
    my $self = shift;
    return $self->time_piece->strftime( '%FT%TZ' );
}

sub epoch {
    my $self = shift;
    return $self->time_piece->epoch;
}

around BUILDARGS => sub {
    my ( $orig, $class, @args ) = @_;

    my $arg = $args[0];

    my $time_piece;
    my $int_check = Int;
    my $str_check = Str;
    my $tp_check  = InstanceOf['Time::Piece'];
    my $dt_check  = InstanceOf['DateTime'];

    ## If the argument is an integer, assume it's an epoch stamp.
    if ( $int_check->check( $arg ) ) {
        $time_piece = Time::Piece->strptime( $arg, '%s');     
    }
    elsif ( $str_check->check( $arg ) ) {
        $time_piece = parse_timestamp_str( $arg );
    }
    elsif ( $tp_check->check( $arg ) ) {  ## If $arg is a Time::Piece object
        $time_piece = $arg;
    }
    elsif ( $dt_check->check( $arg ) ) {
        $time_piece = Time::Piece->strptime( $arg->epoch, '%s' );
    }
    else {
        die "Couldn't parse argument to Time::Piece";
    }
    
    return { time_piece => $time_piece }

};



sub parse_timestamp_str {
    my $str = shift;
   
    ## NOTE:  It looks like Time::Piece strptime will not support timezone by
    ## name, so we can't support arguments where the zone is expressed this 
    ## way (for example 2020-05-10T10:00:00CST).  It (maybe?) can parse an
    ## offset.  Also, DateTime could (of course) handle this. Of course, 
    ## DateTime will not handle parsing the string as well.  For now, we won't
    ## support alternate time zones.
    if ( $str =~ /^
            (?<timestamp>   # Start capture $1
                \d{4} - \d{2} - \d{2} T \d{2}:\d{2} # Matches YYYY-MM-DDTHH:mm
                (:\d{2})?                           # Optionally matches :SS
            )
            (?<timezone> Z|\w{3})? ## Could have timezone or literal "Z"
            $/x
      ) { 
        return Time::Piece->strptime( $1, '%FT%T' );
    }

    if ( $str =~ /^\d{4} - \d{2} - \d{2}$/) {  ## Matches YYYY-MM-DD
        return Time::Piece->strptime( $str, '%F' );
        
    }

    else { 
        die("$str does not look like an iso8601 datetime");
    }

}













1;
