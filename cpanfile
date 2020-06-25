requires 'perl', '5.008001';
requires 'Moo';
requires 'Types::Standard';
requires 'Time::Piece';
requires 'Regexp::Common';
requires 'Regexp::Common::time';


on 'test' => sub {
    requires 'Test::More', '0.98';
    requires 'DateTime'
};

