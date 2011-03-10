use lib 't/lib';
use Test::More;
use Test::Riak;
use Data::Dumper;


test_riak {
    my ($client, $bucket_name) = @_;

    my $bucket = $client->bucket($bucket_name);
    $bucket->allow_multiples(1);
    ok $bucket->allow_multiples, 'multiples set to 1';

    {
        my $obj = $bucket->get('foo');
        is $obj->has_siblings, 0, 'has no sibilings';
        is $obj->count_siblings, 0, 'has no sibilings';
    }
   
    for(1..5) {
        my $client = new_riak_client();
        my $bucket = $client->bucket($bucket_name);
        my $obj = $bucket->new_object('foo', [$_]);
        $obj->store;
        $obj->load;
    }

    # check we got 5 siblings
    my $obj = $bucket->get('foo');
    ok $obj->has_siblings, 'object has siblings';
    is $obj->count_siblings, 5, 'got 5 siblings';
   
    # test set/get
    my @siblings = $obj->siblings;
    my $obj3 = $obj->sibling(3);
    is_deeply $obj3->data, $obj->sibling(3)->data, 'sibling data matches';
    $obj3 = $obj->sibling(3);
    $obj3->store;
    $obj->load;
    is_deeply $obj->data, $obj3->data, 'sibling data still matches';
    $obj->delete;
}
