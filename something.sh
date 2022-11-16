function make_policy_chunk() {
    local i=$1
    for j in {$((i*10))..$((i*10 + 10))}
    do
    echo '    - !variable'" secret_${j}"
    done
}

function print_policy() {
    local i=$1
    echo '
- !policy
  id: BenchmarkSecrets
  body:
'
make_policy_chunk $i

echo ""
}

for i in {0..2}
do

    print_policy $i | docker-compose exec ...
done


