use strict;
use warnings FATAL => 'all';

use Test::More;
use if $ENV{AUTHOR_TESTING}, 'Test::Warnings';
use Test::DZil;

my $tzil = Builder->from_config(
    { dist_root => 't/does_not_exist' },
    {
        add_files => {
            'source/dist.ini' => simple_ini(
                [ GatherDir => ],
                [ 'MungeFile::WithData' => { finder => ':MainModule', house => 'maison' } ],
            ),
            'source/lib/Module.pm' => <<'MODULE'
package Module;

my $string = {{
'"our list of items are: '
. join(', ', split(' ', $DATA))   # awk-style emulation
. "\n" . 'And that\'s just great!\n"'
}};
my ${{ $house }} = 'my castle';
1;
__DATA__
dog
cat
pony
__END__
This is content that should not be in the DATA section.
MODULE
        },
    },
);

$tzil->build;

my $content = $tzil->slurp_file('build/lib/Module.pm');

is(
    $content,
    <<'NEW_MODULE',
package Module;

my $string = "our list of items are: dog, cat, pony
And that's just great!\n";
my $maison = 'my castle';
1;
__DATA__
dog
cat
pony
__END__
This is content that should not be in the DATA section.
NEW_MODULE
    'module content is transformed',
);

done_testing;

