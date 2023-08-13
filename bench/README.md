# Benchmarks

Wrapping a string a string array in a sumtype is a little faster, but it complicates further usage:

    ❯ ./bench/bench-commit-vars.vsh
     SPENT     0.451 ms in commits with array
     SPENT     0.400 ms in commits with value

Surprisingly, adding to an array, which is a map value, is faster by repeating the map lookup for each addition, than by adding items to a temporary array and then assigning the array tp the map again:

    ❯ ./bench/bench-map-array.vsh
     SPENT   182.754 ms in add to array in map directly
     SPENT   233.159 ms in add to array in map indirectly
